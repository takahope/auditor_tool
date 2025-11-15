# Wrapper App - Google Apps Script 移動端登入解決方案

這是一個輕量級的 Wrapper 應用程式,用於解決 Google Apps Script (GAS) Web App 在移動端的登入體驗問題。

## 📋 目錄

- [問題背景](#問題背景)
- [解決方案](#解決方案)
- [功能特色](#功能特色)
- [技術架構](#技術架構)
- [部署指南](#部署指南)
- [設定說明](#設定說明)
- [使用方式](#使用方式)
- [故障排除](#故障排除)

---

## 🎯 問題背景

### 核心問題

當移動端使用者（特別是 Google Workspace 用戶）嘗試訪問 GAS 網頁應用的 `.../exec` 網址時,會被強制導向 Google 的「帳號選擇」頁面。

### 導致的痛點

1. **錯誤的帳號登入**: 使用者的手機瀏覽器可能預設登入的是個人 Gmail 帳號,容易選錯帳號導致權限不足錯誤
2. **混亂的 UX**: 反覆的登入、切換帳號、重新載入頁面,讓使用者感到挫折
3. **缺乏品牌一致性**: Google 的登入頁面無法客製化,破壞了企業應用的整體品牌形象

---

## 💡 解決方案

### 使用者流程

1. 使用者在移動端瀏覽器打開 Wrapper App 網址 (例如 `app.your-company.com`)
2. 頁面顯示「使用 Google 帳號登入」的按鈕 (由 Google Identity Services 提供)
3. 使用者點擊按鈕,觸發 Google 登入彈窗
4. 使用者選擇帳號並授權
5. **[核心邏輯]** Wrapper App 收到回呼,取得使用者的 Email
6. **[驗證]** 系統檢查 Email 的網域是否為 `@your-company.com`
   - **IF (是)**: 驗證通過,系統載入 GAS 應用程式 (使用 iframe)
   - **IF (否)**: 驗證失敗,頁面顯示錯誤訊息

---

## ✨ 功能特色

### 身份驗證

- ✅ 整合 Google Identity Services (GSI)
- ✅ 支援 Email 網域白名單驗證
- ✅ 自動 Session 管理 (24 小時有效期)
- ✅ 清晰的錯誤提示訊息

### 使用者體驗

- ✅ 響應式設計 (RWD),支援桌面與移動裝置
- ✅ 客製化品牌介面 (Logo、顏色、公司名稱)
- ✅ 使用 iframe 無縫載入 GAS 應用
- ✅ 頂部導航欄顯示使用者資訊
- ✅ 一鍵登出功能

### 安全性

- ✅ Email 網域白名單驗證
- ✅ Session 過期機制
- ✅ HTTPS 強制使用 (由 Firebase Hosting 提供)
- ✅ Content Security Policy 標頭

---

## 🏗️ 技術架構

### 前端技術

- **HTML5 + Vanilla JavaScript**: 無框架,輕量級實作
- **Google Identity Services (GSI)**: Google 官方的登入解決方案
- **CSS3**: 響應式設計,支援各種螢幕尺寸

### 託管平台

- **Firebase Hosting**:
  - 免費額度高
  - 全球 CDN 速度快
  - 自動 HTTPS
  - 易於部署
  - 可綁定自訂網域

### 整合

- **GAS Web App**: 使用 iframe 方式載入現有的 GAS 應用
- **Session Storage**: 儲存使用者登入狀態 (瀏覽器端)

---

## 🚀 部署指南

### 前置準備

1. **Google Cloud Platform (GCP) 帳號**
   - 用於建立 OAuth 2.0 Client ID

2. **Firebase 專案**
   - 用於託管 Wrapper App

3. **GAS Web App 已部署**
   - 確保您的 GAS 應用已部署並取得 `.../exec` 網址

4. **Node.js 和 npm** (選用)
   - 用於安裝 Firebase CLI

---

### 步驟 1: 建立 Google OAuth Client ID

#### 1.1 前往 Google Cloud Console

訪問 [Google Cloud Console](https://console.cloud.google.com)

#### 1.2 選擇或建立專案

- 如果您已有專案,選擇該專案
- 如果沒有,點選「建立專案」

#### 1.3 啟用 Google Identity Services API

1. 前往「API 和服務」→「資料庫」
2. 搜尋「Google Identity Services」
3. 點選「啟用」

#### 1.4 建立 OAuth 2.0 憑證

1. 前往「API 和服務」→「憑證」
2. 點選「建立憑證」→「OAuth 2.0 用戶端 ID」
3. 應用程式類型選擇「網頁應用程式」
4. 名稱填寫:「Wrapper App」(或任意名稱)
5. **授權的 JavaScript 來源**:
   ```
   https://your-project-id.web.app
   https://your-project-id.firebaseapp.com
   https://app.your-company.com  (如果您有自訂網域)
   ```
6. **授權的重新導向 URI**: (可留空)
7. 點選「建立」
8. **複製 Client ID** (格式: `xxxxx.apps.googleusercontent.com`)

---

### 步驟 2: 設定 Firebase 專案

#### 2.1 安裝 Firebase CLI

```bash
npm install -g firebase-tools
```

#### 2.2 登入 Firebase

```bash
firebase login
```

#### 2.3 初始化 Firebase 專案

在 `wrapper-app` 目錄中執行:

```bash
cd wrapper-app
firebase init
```

選擇:
- ✅ Hosting: Configure files for Firebase Hosting
- 選擇您的 Firebase 專案 (或建立新專案)
- Public directory: `public`
- Configure as a single-page app: `No`
- Set up automatic builds and deploys with GitHub: `No`

#### 2.4 更新 `.firebaserc`

編輯 `.firebaserc` 檔案,將 `your-firebase-project-id` 替換為您的 Firebase 專案 ID:

```json
{
  "projects": {
    "default": "your-actual-firebase-project-id"
  }
}
```

---

### 步驟 3: 設定 Wrapper App

#### 3.1 編輯 `public/config.js`

打開 `public/config.js`,設定以下參數:

```javascript
const CONFIG = {
  // 貼上您在步驟 1.4 取得的 Client ID
  GOOGLE_CLIENT_ID: 'xxxxx.apps.googleusercontent.com',

  // 允許登入的 Email 網域 (只填寫網域名稱,不含 @)
  ALLOWED_DOMAINS: ['your-company.com'],

  // 您的 GAS Web App 的 .../exec 網址
  GAS_APP_URL: 'https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec',

  // 應用程式名稱
  APP_NAME: '電腦軟體版本更新稽核紀錄系統',

  // 公司或組織名稱
  COMPANY_NAME: '您的公司名稱',

  // 其他設定...
};
```

#### 3.2 確認 GAS 應用支援 iframe

確保您的 GAS `code.js` 檔案中的 `doGet()` 函式包含以下設定:

```javascript
function doGet(e) {
  const htmlOutput = HtmlService.createHtmlOutputFromFile('Index')
    .setTitle('電腦軟體版本更新稽核紀錄');

  // ✅ 重要: 允許在 iframe 中載入
  htmlOutput.setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);

  return htmlOutput;
}
```

**注意**: 如果您查看了本專案的 `code.js`,此設定已經存在於第 29 行,無需修改。

---

### 步驟 4: 部署到 Firebase

#### 4.1 預覽 (本機測試)

```bash
firebase serve
```

在瀏覽器開啟 `http://localhost:5000` 測試。

**注意**: 本機測試時 Google Sign-In 可能無法正常運作,因為 OAuth Client ID 的授權來源只包含正式網址。

#### 4.2 部署到 Firebase

```bash
firebase deploy
```

部署成功後,您會看到類似以下訊息:

```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/your-project-id/overview
Hosting URL: https://your-project-id.web.app
```

---

### 步驟 5: 綁定自訂網域 (選用)

#### 5.1 前往 Firebase Console

訪問 [Firebase Console](https://console.firebase.google.com)

#### 5.2 新增自訂網域

1. 選擇您的專案
2. 前往「Hosting」
3. 點選「新增自訂網域」
4. 輸入您的網域 (例如: `app.your-company.com`)
5. 依照指示設定 DNS 記錄 (A 記錄或 TXT 記錄)
6. 等待驗證完成 (通常需要數分鐘到數小時)

#### 5.3 更新 OAuth Client ID

回到 Google Cloud Console,更新 OAuth 2.0 Client ID 的「授權的 JavaScript 來源」:

```
https://app.your-company.com
```

---

## ⚙️ 設定說明

### `config.js` 參數說明

| 參數 | 說明 | 範例 |
|------|------|------|
| `GOOGLE_CLIENT_ID` | Google OAuth 2.0 Client ID | `12345-abc.apps.googleusercontent.com` |
| `ALLOWED_DOMAINS` | 允許登入的 Email 網域白名單 (陣列) | `['company.com', 'subsidiary.com']` |
| `GAS_APP_URL` | GAS Web App 的完整網址 | `https://script.google.com/.../exec` |
| `APP_NAME` | 應用程式名稱 (顯示在頁面上) | `電腦軟體版本更新稽核紀錄系統` |
| `COMPANY_NAME` | 公司或組織名稱 | `ABC 科技公司` |
| `SESSION_KEY` | Session Storage 的 Key (一般不需修改) | `auditor_tool_auth_session` |
| `DEBUG_MODE` | 是否啟用除錯模式 (開發時使用) | `true` 或 `false` |

---

## 📱 使用方式

### 使用者操作流程

1. **訪問 Wrapper App**
   - 在瀏覽器中開啟 `https://app.your-company.com`

2. **點選「使用 Google 帳號登入」**
   - 系統會顯示 Google 登入彈窗

3. **選擇正確的 Google Workspace 帳號**
   - 選擇您公司的 Google Workspace 帳號 (例如: `yourname@company.com`)
   - **重要**: 不要選擇個人 Gmail 帳號

4. **授權**
   - 點選「允許」授予權限

5. **使用應用程式**
   - 驗證成功後,系統會自動載入 GAS 應用程式
   - 您可以開始使用表單填寫功能

6. **登出**
   - 點選右上角的「登出」按鈕即可登出

### Session 管理

- **有效期**: 登入狀態會保留 24 小時
- **儲存位置**: Session Storage (瀏覽器關閉後清除)
- **自動登入**: 24 小時內重新訪問無需再次登入

---

## 🔧 故障排除

### 問題 1: 點選登入按鈕後沒有反應

**可能原因**:
- Google Client ID 設定錯誤
- 瀏覽器封鎖彈窗
- Google Identity Services Library 載入失敗

**解決方法**:
1. 檢查 `config.js` 中的 `GOOGLE_CLIENT_ID` 是否正確
2. 確認瀏覽器允許彈窗 (檢查瀏覽器網址列右側是否有彈窗圖示)
3. 開啟瀏覽器開發者工具 (F12),查看 Console 是否有錯誤訊息
4. 確認網頁是透過 HTTPS 訪問 (不是 HTTP)

---

### 問題 2: 登入後顯示「網域不在允許名單」錯誤

**可能原因**:
- 使用了個人 Gmail 帳號
- `ALLOWED_DOMAINS` 設定錯誤

**解決方法**:
1. 確認您使用的是公司的 Google Workspace 帳號,不是個人 Gmail
2. 檢查 `config.js` 中的 `ALLOWED_DOMAINS` 設定:
   ```javascript
   ALLOWED_DOMAINS: ['company.com'],  // ✅ 正確 (不含 @)
   ALLOWED_DOMAINS: ['@company.com'], // ❌ 錯誤 (不應包含 @)
   ```
3. 確認網域名稱拼寫正確 (區分大小寫)

---

### 問題 3: iframe 無法載入 GAS 應用

**可能原因**:
- GAS App URL 設定錯誤
- GAS 應用未設定 `setXFrameOptionsMode`
- 網路連線問題

**解決方法**:
1. 檢查 `config.js` 中的 `GAS_APP_URL` 是否正確
2. 確認 GAS 應用的 `doGet()` 函式包含:
   ```javascript
   htmlOutput.setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
   ```
3. 嘗試直接在瀏覽器訪問 GAS App URL,確認應用正常運作
4. 開啟瀏覽器開發者工具 (F12),查看 Network 分頁是否有載入錯誤

---

### 問題 4: OAuth Client ID 授權來源錯誤

**錯誤訊息**:
```
Error: origin_mismatch
```

**解決方法**:
1. 前往 [Google Cloud Console](https://console.cloud.google.com)
2. 選擇「API 和服務」→「憑證」
3. 點選您的 OAuth 2.0 Client ID
4. 在「授權的 JavaScript 來源」中,確認包含您的網址:
   ```
   https://your-project-id.web.app
   https://app.your-company.com
   ```
5. 儲存後等待幾分鐘讓設定生效

---

### 問題 5: 部署後頁面顯示 404

**可能原因**:
- Firebase 部署失敗
- 檔案結構不正確

**解決方法**:
1. 確認 `firebase.json` 中的 `public` 設定為 `"public"`
2. 確認所有檔案都在 `public/` 目錄下:
   ```
   public/
   ├── index.html
   ├── app.html
   ├── config.js
   ├── auth.js
   └── app.js
   ```
3. 重新部署:
   ```bash
   firebase deploy
   ```

---

## 📂 檔案結構

```
wrapper-app/
├── public/               # 網站公開目錄
│   ├── index.html       # 登入頁面
│   ├── app.html         # 應用程式主頁 (載入 GAS iframe)
│   ├── config.js        # 設定檔
│   ├── auth.js          # 登入邏輯
│   └── app.js           # 應用程式邏輯
├── docs/                # 文件目錄 (選用)
├── firebase.json        # Firebase Hosting 設定
├── .firebaserc          # Firebase 專案設定
├── .gitignore           # Git 忽略檔案
└── README.md            # 本說明文件
```

---

## 🔐 安全性考量

### 實作的安全措施

1. **Email 網域白名單**: 只允許特定網域的帳號登入
2. **Session 過期機制**: 24 小時後自動失效
3. **HTTPS 強制使用**: Firebase Hosting 自動提供 HTTPS
4. **Content Security Policy**: 透過 Firebase Hosting 設定安全標頭
5. **JWT Token 驗證**: 驗證 Google 回傳的 ID Token

### 注意事項

- **不要將 `config.js` 中的敏感資訊 commit 到公開的 Git Repository**
- **定期檢查 OAuth Client ID 的授權來源列表**
- **監控 Firebase Hosting 的存取日誌**

---

## 📞 支援與聯繫

如有問題或需要協助,請聯繫:

- **IT 支援部門**: support@your-company.com
- **系統管理員**: admin@your-company.com

---

## 📄 授權

此專案僅供內部使用,未經授權不得對外分享或商業使用。

---

## 🎉 完成!

恭喜您完成 Wrapper App 的部署!現在您的使用者可以透過統一的登入介面,使用正確的 Google Workspace 帳號訪問 GAS 應用程式了。

如果您覺得這個解決方案有幫助,歡迎分享給其他團隊成員!
