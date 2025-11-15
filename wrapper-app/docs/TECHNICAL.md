# 技術文件

本文件詳細說明 Wrapper App 的技術實作細節,供開發人員和系統管理員參考。

## 目錄

- [架構概述](#架構概述)
- [核心模組](#核心模組)
- [資料流程](#資料流程)
- [安全性實作](#安全性實作)
- [效能優化](#效能優化)
- [擴展性考量](#擴展性考量)

---

## 架構概述

### 整體架構圖

```
┌─────────────┐
│   使用者    │
└──────┬──────┘
       │
       │ HTTPS
       ▼
┌─────────────────────────────────────┐
│   Firebase Hosting (CDN)            │
│   ┌─────────────────────────────┐   │
│   │  Wrapper App (靜態網頁)     │   │
│   │  ├── index.html (登入頁)    │   │
│   │  ├── app.html (主頁)        │   │
│   │  ├── auth.js (驗證邏輯)     │   │
│   │  └── app.js (應用邏輯)      │   │
│   └─────────────────────────────┘   │
└───────────┬─────────────────────────┘
            │
            │ OAuth 2.0
            ▼
┌─────────────────────────────────────┐
│  Google Identity Services (GSI)     │
│  - 身份驗證                         │
│  - ID Token 簽發                    │
└───────────┬─────────────────────────┘
            │
            │ JWT Token
            ▼
┌─────────────────────────────────────┐
│  Wrapper App (Client-side)          │
│  - 解析 JWT Token                   │
│  - 驗證 Email 網域                  │
│  - 儲存 Session                     │
└───────────┬─────────────────────────┘
            │
            │ 驗證通過
            ▼
┌─────────────────────────────────────┐
│  GAS Web App (iframe)               │
│  - 表單顯示                         │
│  - 資料處理                         │
│  - Google Sheets 整合               │
└─────────────────────────────────────┘
```

### 技術堆疊

| 層級 | 技術 | 用途 |
|------|------|------|
| **前端** | HTML5 + CSS3 + Vanilla JS | 使用者介面 |
| **身份驗證** | Google Identity Services (GSI) | OAuth 2.0 登入 |
| **託管** | Firebase Hosting | 靜態網站託管 + CDN |
| **應用整合** | iframe | 載入 GAS Web App |
| **狀態管理** | Session Storage | 使用者登入狀態 |

---

## 核心模組

### 1. 登入模組 (`auth.js`)

#### 功能

- 初始化 Google Identity Services
- 處理使用者登入回調
- 驗證 Email 網域
- 管理 Session Storage

#### 關鍵函式

##### `initializeGoogleSignIn()`

```javascript
function initializeGoogleSignIn() {
  google.accounts.id.initialize({
    client_id: CONFIG.GOOGLE_CLIENT_ID,
    callback: handleCredentialResponse,
    auto_select: false,
    cancel_on_tap_outside: true
  });

  google.accounts.id.renderButton(
    document.getElementById('google-signin-button'),
    { theme: 'outline', size: 'large', ... }
  );
}
```

**說明**:
- `client_id`: OAuth 2.0 Client ID
- `callback`: 登入成功後的回調函式
- `auto_select`: 是否自動選擇帳號 (設為 false 讓使用者手動選擇)
- `cancel_on_tap_outside`: 點擊外部時關閉彈窗

##### `handleCredentialResponse(response)`

```javascript
function handleCredentialResponse(response) {
  const credential = response.credential;
  const payload = parseJwt(credential);

  const userData = {
    email: payload.email,
    name: payload.name,
    picture: payload.picture,
    emailVerified: payload.email_verified
  };

  // 驗證 Email 網域
  if (!validateEmailDomain(userData.email)) {
    showError('網域不在允許名單');
    return;
  }

  // 儲存 Session 並導向主頁
  saveSession(userData);
  window.location.href = 'app.html';
}
```

**流程**:
1. 接收 Google 回傳的 JWT Token
2. 解析 Token 取得使用者資訊
3. 驗證 Email 是否已驗證
4. 驗證 Email 網域是否在白名單
5. 儲存 Session
6. 重新導向到應用程式主頁

##### `validateEmailDomain(email)`

```javascript
function validateEmailDomain(email) {
  const domain = extractDomain(email);
  return CONFIG.ALLOWED_DOMAINS.some(
    allowedDomain => domain === allowedDomain.toLowerCase()
  );
}
```

**驗證邏輯**:
- 從 Email 提取網域 (例如: `user@company.com` → `company.com`)
- 比對 `ALLOWED_DOMAINS` 白名單
- 不區分大小寫

---

### 2. 應用模組 (`app.js`)

#### 功能

- 檢查使用者登入狀態
- 載入 GAS Web App (iframe)
- 顯示使用者資訊
- 處理登出

#### 關鍵函式

##### `initializeApp()`

```javascript
function initializeApp() {
  // 檢查登入狀態
  const session = loadSession();
  if (!session) {
    window.location.href = 'index.html';
    return;
  }

  // 顯示使用者資訊
  displayUserInfo(session);

  // 載入 GAS 應用
  loadGasApp();
}
```

##### `loadGasApp()`

```javascript
function loadGasApp() {
  const iframe = document.getElementById('gas-app-iframe');

  // 載入完成事件
  iframe.addEventListener('load', () => hideLoading());

  // 錯誤處理
  iframe.addEventListener('error', () => showError('載入失敗'));

  // 超時檢查 (30 秒)
  setTimeout(() => {
    if (loading) showError('載入超時');
  }, 30000);

  // 設定 src 開始載入
  iframe.src = CONFIG.GAS_APP_URL;
}
```

**安全性考量**:
- 使用 `sandbox` 屬性限制 iframe 權限
- 允許的權限: `allow-same-origin`, `allow-scripts`, `allow-forms`, `allow-popups`, `allow-modals`

---

### 3. Session 管理

#### 儲存格式

```javascript
{
  "email": "user@company.com",
  "name": "User Name",
  "picture": "https://...",
  "timestamp": 1234567890000
}
```

#### 有效期檢查

```javascript
function loadSession() {
  const sessionData = sessionStorage.getItem(CONFIG.SESSION_KEY);
  const userData = JSON.parse(sessionData);

  const sessionAge = Date.now() - userData.timestamp;
  const maxAge = 24 * 60 * 60 * 1000; // 24 小時

  if (sessionAge > maxAge) {
    clearSession();
    return null;
  }

  return userData;
}
```

**優點**:
- 使用 Session Storage (分頁關閉後自動清除)
- 包含時間戳記,可實作過期機制
- 純 Client-side,無需後端支援

**缺點**:
- 每個分頁獨立 (不同分頁需要重新登入)
- 可被 JavaScript 存取 (XSS 風險)

**改進建議**:
- 使用 `httpOnly` Cookie (需要後端支援)
- 使用 Local Storage 實現跨分頁 Session

---

## 資料流程

### 登入流程

```
┌─────────┐
│ 使用者  │
└────┬────┘
     │
     │ 1. 訪問 index.html
     ▼
┌──────────────────┐
│  Wrapper App     │
│  (登入頁面)      │
└────┬─────────────┘
     │
     │ 2. 點選「使用 Google 登入」
     ▼
┌──────────────────┐
│  Google (GSI)    │
│  登入彈窗        │
└────┬─────────────┘
     │
     │ 3. 選擇帳號並授權
     ▼
┌──────────────────┐
│  GSI Callback    │
│  回傳 JWT Token  │
└────┬─────────────┘
     │
     │ 4. handleCredentialResponse()
     ▼
┌──────────────────┐
│  解析 JWT Token  │
│  提取使用者資訊  │
└────┬─────────────┘
     │
     │ 5. validateEmailDomain()
     ▼
┌──────────────────┐      ❌ 網域不符
│  驗證 Email 網域 ├────────────────┐
└────┬─────────────┘                │
     │ ✅ 驗證通過                  │
     │                              ▼
     │ 6. saveSession()      ┌──────────────┐
     ▼                       │  顯示錯誤    │
┌──────────────────┐        │  訊息        │
│  儲存 Session    │        └──────────────┘
└────┬─────────────┘
     │
     │ 7. window.location.href = 'app.html'
     ▼
┌──────────────────┐
│  應用程式主頁    │
│  (app.html)      │
└──────────────────┘
```

---

### GAS App 載入流程

```
┌─────────┐
│ 使用者  │
└────┬────┘
     │
     │ 1. 訪問 app.html
     ▼
┌──────────────────┐
│  app.js          │
│  initializeApp() │
└────┬─────────────┘
     │
     │ 2. loadSession()
     ▼
┌──────────────────┐      ❌ Session 不存在 / 過期
│  檢查 Session    ├────────────────────────┐
└────┬─────────────┘                        │
     │ ✅ Session 有效                      ▼
     │                              ┌───────────────┐
     │ 3. displayUserInfo()         │  重新導向到   │
     ▼                              │  index.html   │
┌──────────────────┐                └───────────────┘
│  顯示使用者資訊  │
└────┬─────────────┘
     │
     │ 4. loadGasApp()
     ▼
┌──────────────────┐
│  設定 iframe src │
│  = GAS_APP_URL   │
└────┬─────────────┘
     │
     │ 5. 瀏覽器載入 iframe
     ▼
┌──────────────────┐
│  GAS Web App     │
│  (在 iframe 中)  │
└────┬─────────────┘
     │
     │ 6. iframe 'load' event
     ▼
┌──────────────────┐
│  hideLoading()   │
│  顯示應用程式    │
└──────────────────┘
```

---

## 安全性實作

### 1. Email 網域白名單

**實作位置**: `auth.js` - `validateEmailDomain()`

**原理**:
```javascript
const domain = email.split('@')[1].toLowerCase();
const isAllowed = CONFIG.ALLOWED_DOMAINS.includes(domain);
```

**優點**:
- 簡單有效
- Client-side 驗證,無需後端
- 防止非授權網域登入

**限制**:
- Client-side 驗證可被繞過 (需搭配 GAS 後端驗證)
- 無法控制個人帳號的細緻權限

**改進建議**:
- 在 GAS 後端也實作相同的網域驗證
- 使用 Google Workspace Admin API 檢查使用者是否在組織內

---

### 2. JWT Token 驗證

**實作位置**: `auth.js` - `parseJwt()`

**原理**:
```javascript
function parseJwt(token) {
  const base64Url = token.split('.')[1];
  const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
  const jsonPayload = decodeURIComponent(
    atob(base64)
      .split('')
      .map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
      .join('')
  );
  return JSON.parse(jsonPayload);
}
```

**說明**:
- JWT Token 格式: `header.payload.signature`
- 我們只解析 `payload` 部分 (包含使用者資訊)
- **不驗證簽章** (因為 Google GSI 已在 Client Library 中驗證)

**安全性考量**:
- Google GSI Library 已驗證 Token 的簽章和有效期
- 我們只需要提取其中的使用者資訊
- Token 不會被儲存,只在登入時使用

---

### 3. Session 安全

**實作位置**: `auth.js` 和 `app.js`

**安全措施**:

1. **有效期限制** (24 小時):
   ```javascript
   const sessionAge = Date.now() - userData.timestamp;
   if (sessionAge > maxAge) {
     clearSession();
     return null;
   }
   ```

2. **Session Storage** (自動清除):
   - 分頁關閉後自動清除
   - 不會跨分頁共享
   - 不會在瀏覽器重啟後保留

3. **不儲存敏感資訊**:
   - 只儲存 Email, Name, Picture
   - 不儲存 Access Token 或密碼

**風險**:
- XSS 攻擊可讀取 Session Storage
- 不適合儲存高敏感資訊

**改進建議**:
- 使用 `httpOnly` Cookie (需後端支援)
- 實作 CSRF Token
- 定期 Session 續期機制

---

### 4. Content Security Policy (CSP)

**實作位置**: `firebase.json`

```json
{
  "headers": [
    {
      "key": "X-Content-Type-Options",
      "value": "nosniff"
    },
    {
      "key": "X-Frame-Options",
      "value": "DENY"
    },
    {
      "key": "X-XSS-Protection",
      "value": "1; mode=block"
    }
  ]
}
```

**說明**:
- `X-Content-Type-Options: nosniff` - 防止 MIME 類型嗅探
- `X-Frame-Options: DENY` - 防止被嵌入 iframe (Clickjacking 攻擊)
- `X-XSS-Protection` - 啟用瀏覽器 XSS 過濾器

---

### 5. iframe Sandbox

**實作位置**: `app.html`

```html
<iframe
  id="gas-app-iframe"
  src="..."
  sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-modals"
></iframe>
```

**sandbox 屬性說明**:
- `allow-same-origin` - 允許存取同源資源
- `allow-scripts` - 允許執行 JavaScript
- `allow-forms` - 允許表單提交
- `allow-popups` - 允許彈窗 (GAS 可能需要)
- `allow-modals` - 允許模態對話框

**未允許的權限** (預設禁止):
- `allow-top-navigation` - 禁止導航頂層視窗
- `allow-pointer-lock` - 禁止指標鎖定
- `allow-downloads` - 禁止下載檔案

---

## 效能優化

### 1. 靜態資源快取

**實作位置**: `firebase.json`

```json
{
  "headers": [
    {
      "source": "**/*.@(js|css|html)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "max-age=3600"
        }
      ]
    }
  ]
}
```

**效果**:
- JS, CSS, HTML 檔案快取 1 小時
- 減少重複載入時間
- Firebase CDN 全球加速

---

### 2. 延遲載入 GSI Library

**實作位置**: `index.html`

```html
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

**說明**:
- `async` - 非同步載入,不阻塞頁面渲染
- `defer` - DOM 載入後執行
- 搭配 `initializeGoogleSignIn()` 中的重試機制

---

### 3. iframe 預載入

**實作位置**: `app.html`

```html
<iframe id="gas-app-iframe" src="" ...></iframe>
```

**策略**:
- 先渲染 iframe 元素 (src 為空)
- 顯示載入動畫
- JavaScript 設定 src 後開始載入
- 載入完成後隱藏動畫

**優點**:
- 使用者可立即看到頁面結構
- 改善感知載入速度

---

### 4. 最小化 HTTP 請求

**實作方式**:
- 使用 Vanilla JavaScript (不引入 jQuery, React 等大型 Library)
- CSS 內嵌在 HTML 中 (減少 CSS 檔案請求)
- 圖片使用 Emoji (不需載入圖片檔案)

**效果**:
- 首次載入只需 3-4 個 HTTP 請求
- 頁面大小 < 50KB
- First Contentful Paint (FCP) < 1.5 秒

---

## 擴展性考量

### 1. 多語言支援

**目前狀態**: 僅支援繁體中文

**擴展方式**:

1. 建立語言檔案:
   ```javascript
   // public/i18n/zh-TW.js
   const LANG_ZH_TW = {
     login: {
       title: '電腦軟體版本更新稽核紀錄系統',
       button: '使用 Google 帳號登入',
       ...
     }
   };

   // public/i18n/en-US.js
   const LANG_EN_US = {
     login: {
       title: 'Computer Software Audit System',
       button: 'Sign in with Google',
       ...
     }
   };
   ```

2. 在 `config.js` 中新增語言設定:
   ```javascript
   DEFAULT_LANGUAGE: 'zh-TW',
   SUPPORTED_LANGUAGES: ['zh-TW', 'en-US']
   ```

3. 建立語言切換函式:
   ```javascript
   function setLanguage(lang) {
     const translations = LANGUAGES[lang];
     document.querySelectorAll('[data-i18n]').forEach(el => {
       const key = el.getAttribute('data-i18n');
       el.textContent = translations[key];
     });
   }
   ```

---

### 2. 多網域支援

**目前狀態**: 支援 (已實作)

**使用方式**:
```javascript
ALLOWED_DOMAINS: ['company.com', 'subsidiary.com', 'partner.org']
```

**進階需求** - 不同網域不同權限:

```javascript
const DOMAIN_PERMISSIONS = {
  'company.com': { role: 'admin', features: ['all'] },
  'subsidiary.com': { role: 'user', features: ['read', 'write'] },
  'partner.org': { role: 'guest', features: ['read'] }
};

function getUserPermissions(email) {
  const domain = extractDomain(email);
  return DOMAIN_PERMISSIONS[domain] || null;
}
```

---

### 3. 後端 API 整合

**目前狀態**: 純 Client-side,無後端

**擴展場景**:
- 需要儲存使用者偏好設定
- 需要記錄登入日誌
- 需要更複雜的權限管理

**實作方式**:

1. 建立 Firebase Functions:
   ```javascript
   // functions/index.js
   const functions = require('firebase-functions');

   exports.validateUser = functions.https.onCall((data, context) => {
     const email = data.email;
     const domain = extractDomain(email);

     // 檢查白名單
     if (!ALLOWED_DOMAINS.includes(domain)) {
       throw new functions.https.HttpsError('permission-denied', '網域不在允許名單');
     }

     // 記錄登入日誌
     admin.firestore().collection('login_logs').add({
       email: email,
       timestamp: admin.firestore.FieldValue.serverTimestamp()
     });

     return { success: true };
   });
   ```

2. 前端呼叫:
   ```javascript
   const validateUser = firebase.functions().httpsCallable('validateUser');
   validateUser({ email: userData.email })
     .then(result => console.log(result.data))
     .catch(error => console.error(error));
   ```

---

### 4. 進階 Session 管理

**目前狀態**: Session Storage (24 小時)

**擴展需求** - 「記住我」功能:

```javascript
function saveSession(userData, rememberMe = false) {
  const sessionData = {
    ...userData,
    timestamp: Date.now()
  };

  if (rememberMe) {
    // 使用 Local Storage (永久保存)
    localStorage.setItem(CONFIG.SESSION_KEY, JSON.stringify(sessionData));
  } else {
    // 使用 Session Storage (分頁關閉後清除)
    sessionStorage.setItem(CONFIG.SESSION_KEY, JSON.stringify(sessionData));
  }
}
```

---

## 維護與監控

### 日誌記錄

**啟用除錯模式**:
```javascript
// config.js
DEBUG_MODE: true
```

**查看日誌**:
1. 開啟瀏覽器開發者工具 (F12)
2. 切換到 Console 分頁
3. 查看 `[AUTH]` 和 `[APP]` 前綴的日誌

---

### Firebase Hosting 監控

**查看流量統計**:
```bash
firebase hosting:logs
```

**在 Firebase Console 查看**:
1. 訪問 [Firebase Console](https://console.firebase.google.com)
2. 選擇專案
3. 前往「Hosting」→「使用情況」

---

### 常見問題診斷

| 問題 | 可能原因 | 診斷方式 |
|------|----------|----------|
| 登入按鈕沒反應 | GSI Library 未載入 | 檢查 Console 是否有 `google is not defined` |
| 網域驗證失敗 | `ALLOWED_DOMAINS` 設定錯誤 | 檢查 Console 的網域驗證日誌 |
| iframe 空白 | GAS App URL 錯誤 | 檢查 Network 分頁的 iframe 請求 |
| Session 無效 | 超過 24 小時 | 檢查 Session timestamp |

---

## 總結

Wrapper App 是一個輕量級、高效能的解決方案,透過 Google Identity Services 實現企業級的身份驗證,並使用 iframe 無縫整合現有的 GAS Web App。

**關鍵優勢**:
- ✅ 無需後端 (純 Client-side)
- ✅ 快速部署 (< 10 分鐘)
- ✅ 免費託管 (Firebase Hosting)
- ✅ 全球 CDN 加速
- ✅ 易於維護和擴展

**適用場景**:
- ✅ Google Workspace 組織
- ✅ 內部企業應用
- ✅ 中小型使用者規模 (< 10,000 人)

**不適用場景**:
- ❌ 需要複雜的權限管理
- ❌ 需要儲存大量使用者資料
- ❌ 需要跨平台 SSO (Single Sign-On)
