# 快速開始指南

這是一個精簡版的設定和部署指南，讓您可以快速啟動 Wrapper App。

## 📋 檢查清單

在開始之前，請確認您已準備好以下資訊：

- [ ] Google Cloud Platform 帳號
- [ ] Firebase 專案 (或準備建立新專案)
- [ ] GAS Web App 已部署 (`.../exec` 網址)
- [ ] 公司 Google Workspace 網域名稱 (例如: `company.com`)

---

## ⚡ 5 分鐘快速設定

### 1️⃣ 建立 Google OAuth Client ID (3 分鐘)

1. 訪問 [Google Cloud Console](https://console.cloud.google.com)
2. 選擇或建立專案
3. 前往「API 和服務」→「憑證」
4. 建立「OAuth 2.0 用戶端 ID」(類型: 網頁應用程式)
5. 授權的 JavaScript 來源:
   ```
   https://your-project-id.web.app
   https://your-project-id.firebaseapp.com
   ```
6. **複製 Client ID**

---

### 2️⃣ 設定 Firebase (1 分鐘)

```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 登入
firebase login

# 在 wrapper-app 目錄中初始化
cd wrapper-app
firebase init hosting
```

選擇:
- Public directory: `public`
- Single-page app: `No`

---

### 3️⃣ 編輯 `public/config.js` (1 分鐘)

```javascript
const CONFIG = {
  // 步驟 1 取得的 Client ID
  GOOGLE_CLIENT_ID: 'YOUR_CLIENT_ID.apps.googleusercontent.com',

  // 公司網域 (不含 @)
  ALLOWED_DOMAINS: ['your-company.com'],

  // GAS Web App URL
  GAS_APP_URL: 'https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec',

  // 應用程式名稱
  APP_NAME: '電腦軟體版本更新稽核紀錄系統',

  // 公司名稱
  COMPANY_NAME: '您的公司名稱',
};
```

---

### 4️⃣ 部署 (30 秒)

```bash
firebase deploy
```

完成！訪問 `https://your-project-id.web.app` 測試。

---

## 🔍 驗證設定

### 測試登入流程

1. 開啟 `https://your-project-id.web.app`
2. 點選「使用 Google 帳號登入」
3. 選擇您的 Google Workspace 帳號
4. 應該成功載入 GAS 應用程式

### 如果遇到問題

**登入按鈕沒反應**:
- 檢查 `GOOGLE_CLIENT_ID` 是否正確
- 確認網址使用 HTTPS

**顯示網域錯誤**:
- 檢查 `ALLOWED_DOMAINS` 設定
- 確認使用的是 Workspace 帳號,不是個人 Gmail

**iframe 無法載入**:
- 檢查 `GAS_APP_URL` 是否正確
- 確認 GAS code.js 有 `setXFrameOptionsMode(ALLOWALL)`

---

## 📚 詳細文件

完整的設定說明、故障排除和安全性考量，請參閱 [README.md](README.md)

---

## 🎯 下一步

### 綁定自訂網域 (選用)

1. 前往 [Firebase Console](https://console.firebase.google.com)
2. 選擇「Hosting」→「新增自訂網域」
3. 輸入 `app.your-company.com`
4. 依照指示設定 DNS 記錄
5. 更新 OAuth Client ID 的授權來源

### 自訂品牌

編輯 `public/index.html` 和 `public/app.html`:
- 修改 Logo (搜尋 `📋` 表情符號)
- 調整顏色 (搜尋 `#673ab7`)
- 更新文字內容

### 啟用除錯模式

在 `public/config.js` 中設定:
```javascript
DEBUG_MODE: true
```

然後開啟瀏覽器開發者工具 (F12) 查看詳細日誌。

---

## 💡 常見問題

**Q: 需要付費嗎？**
A: Firebase Hosting 有免費額度，一般使用不需要付費。

**Q: 支援哪些瀏覽器？**
A: 支援所有現代瀏覽器 (Chrome, Safari, Firefox, Edge)。

**Q: 可以支援多個網域嗎？**
A: 可以，在 `ALLOWED_DOMAINS` 陣列中添加多個網域：
```javascript
ALLOWED_DOMAINS: ['company.com', 'subsidiary.com']
```

**Q: Session 多久會過期？**
A: 24 小時後自動過期，需要重新登入。

---

## ✅ 完成!

您已成功部署 Wrapper App！如有問題，請參閱 [README.md](README.md) 的故障排除章節。
