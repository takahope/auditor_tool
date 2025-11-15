# 配置指南 (Configuration Guide)

本文件詳細說明如何配置 Android 原生應用程式以整合您的 Google Apps Script (GAS) 應用程式。

## 📋 目錄

1. [Google Cloud Console 設定](#1-google-cloud-console-設定)
2. [下載配置文件](#2-下載配置文件)
3. [更新應用程式配置](#3-更新應用程式配置)
4. [GAS 應用程式設定](#4-gas-應用程式設定)
5. [測試配置](#5-測試配置)

---

## 1. Google Cloud Console 設定

### 1.1 建立或選擇專案

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 建立新專案或選擇現有專案
3. 記下 **專案 ID** 和 **專案編號**

### 1.2 啟用必要的 API

在 Google Cloud Console 中啟用以下 API：

1. 前往 **APIs & Services → Library**
2. 搜尋並啟用以下 API：
   - ✅ **Google Sign-In API**
   - ✅ **Google Sheets API**（如果 GAS 使用 Sheets）
   - ✅ **People API**（可選，用於獲取使用者資訊）

### 1.3 配置 OAuth 同意畫面

1. 前往 **APIs & Services → OAuth consent screen**
2. 選擇使用者類型：
   - **內部** (Internal): 僅限您的 Google Workspace 組織內的使用者（推薦）
   - **外部** (External): 任何 Google 帳號使用者
3. 填寫應用程式資訊：
   - **應用程式名稱**: `電腦軟體版本稽核`
   - **使用者支援電子郵件**: 您的電子郵件
   - **開發人員聯絡資訊**: 您的電子郵件
4. 點擊 **儲存並繼續**
5. **範圍 (Scopes)**: 點擊「新增或移除範圍」，添加：
   - `.../auth/userinfo.email`
   - `.../auth/userinfo.profile`
6. 完成設定

### 1.4 建立 OAuth 2.0 用戶端 ID

#### 建立 Web 用戶端 ID（用於 Google Sign-In）

1. 前往 **APIs & Services → Credentials**
2. 點擊 **+ CREATE CREDENTIALS → OAuth client ID**
3. 應用程式類型選擇: **Web application**
4. 名稱: `Auditor Tool Web Client`
5. **已授權的 JavaScript 來源**: （可留空）
6. **已授權的重新導向 URI**: （可留空）
7. 點擊 **建立**
8. **重要**: 複製並保存 **Web Client ID**（格式：`xxxxx.apps.googleusercontent.com`）

#### 建立 Android 用戶端 ID

1. 再次點擊 **+ CREATE CREDENTIALS → OAuth client ID**
2. 應用程式類型選擇: **Android**
3. 名稱: `Auditor Tool Android Client`
4. **套件名稱**: `com.company.auditor`
5. **SHA-1 憑證指紋**:

#### 如何獲取 SHA-1 憑證指紋？

**Debug 版本（開發用）:**

```bash
# 在專案根目錄執行
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android
```

找到 `SHA1:` 開頭的行，複製該值（格式：`AA:BB:CC:DD:...`）

**Release 版本（正式發布用）:**

```bash
# 使用您的 Release Keystore
keytool -list -v -alias YOUR_KEY_ALIAS \
  -keystore /path/to/your/release.keystore
```

6. 將 SHA-1 指紋貼上並點擊 **建立**
7. 如果您有多個簽名（Debug + Release），請為每個簽名都建立一個 Android 用戶端 ID

---

## 2. 下載配置文件

### 2.1 下載 google-services.json

1. 在 Google Cloud Console 中，前往 **APIs & Services → Credentials**
2. 或者，前往 [Firebase Console](https://console.firebase.google.com/)（如果使用 Firebase）
3. 選擇您的專案
4. 前往 **專案設定 → 一般**
5. 向下捲動到「您的應用程式」區段
6. 點擊 **Android** 圖示（如果尚未添加 Android 應用）
7. 套件名稱填入: `com.company.auditor`
8. 下載 `google-services.json` 文件

### 2.2 放置配置文件

將下載的 `google-services.json` 文件放置於：

```
android-app/app/google-services.json
```

**重要**: 確保文件名稱完全是 `google-services.json`，不要有任何後綴（如 `.txt`）。

---

## 3. 更新應用程式配置

### 3.1 更新 build.gradle (App 級別)

編輯 `android-app/app/build.gradle`：

```gradle
android {
    defaultConfig {
        // 設定允許的網域 - 替換為您的公司網域
        buildConfigField "String[]", "ALLOWED_DOMAINS", '{"your-company.com", "yourcompany.com"}'

        // GAS Web App URL - 替換為實際的部署 URL
        buildConfigField "String", "GAS_WEB_APP_URL", '"https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec"'
    }
}
```

#### 如何獲取 GAS Web App URL？

1. 在 Google Apps Script 編輯器中，點擊 **部署 → 管理部署**
2. 複製 **網頁應用程式** 的 URL
3. URL 格式應為: `https://script.google.com/macros/s/XXXXX/exec`

#### 允許的網域設定範例

```gradle
// 單一網域
buildConfigField "String[]", "ALLOWED_DOMAINS", '{"company.com"}'

// 多個網域
buildConfigField "String[]", "ALLOWED_DOMAINS", '{"company.com", "company.org", "company.net"}'
```

### 3.2 更新 strings.xml

編輯 `android-app/app/src/main/res/values/strings.xml`：

```xml
<resources>
    <!-- 更新應用程式名稱 -->
    <string name="app_name">電腦軟體版本稽核</string>

    <!-- 更新 Web Client ID - 使用步驟 1.4 中獲取的 Web Client ID -->
    <string name="default_web_client_id" translatable="false">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>

    <!-- 可選: 自訂錯誤訊息 -->
    <string name="error_wrong_domain_message">請確保您使用的是公司的 Google Workspace 帳號 (@%s)</string>
</resources>
```

**重要**: `default_web_client_id` 必須是步驟 1.4 中建立的 **Web Client ID**，不是 Android Client ID！

### 3.3 驗證 AndroidManifest.xml

確認 `android-app/app/src/main/AndroidManifest.xml` 中的 package name：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.company.auditor">
    <!-- ... -->
</manifest>
```

如果需要更改 package name，請同時更新：
- `build.gradle` 中的 `applicationId`
- `google-services.json` 中的 `package_name`
- 所有 Kotlin 文件的 package 宣告

---

## 4. GAS 應用程式設定

### 4.1 設定 X-Frame-Options

**這是必須的！** 否則 WebView 將無法載入 GAS 應用程式。

在您的 `code.js` 中，確保 `doGet()` 函式包含以下設定：

```javascript
function doGet(e) {
  const htmlOutput = HtmlService.createHtmlOutputFromFile('Index')
    .setTitle('電腦軟體版本更新稽核紀錄');

  // ✅ 必須設定此行！
  htmlOutput.setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);

  htmlOutput.addMetaTag('viewport', 'width=device-width, initial-scale=1.0');
  return htmlOutput;
}
```

**注意**: 您的現有 GAS 專案已經有此設定（code.js:29），所以無需修改。

### 4.2 設定 Web App 部署

確保 GAS 應用程式已正確部署：

1. 在 Apps Script 編輯器中，點擊 **部署 → 新增部署**
2. 選擇類型: **網頁應用程式**
3. 設定：
   - **執行身分**: `我` (Me)
   - **具有應用程式存取權的使用者**: `僅限我所屬機構中的使用者` (推薦)
4. 點擊 **部署**
5. 複製 **網頁應用程式** URL，並更新到 `build.gradle` 的 `GAS_WEB_APP_URL`

---

## 5. 測試配置

### 5.1 同步 Gradle

在 Android Studio 中：

1. 點擊 **File → Sync Project with Gradle Files**
2. 等待同步完成，確保沒有錯誤

### 5.2 檢查配置清單

在建置前，請確認：

- [ ] `google-services.json` 已放置於 `app/` 目錄
- [ ] `build.gradle` 中的 `ALLOWED_DOMAINS` 已更新
- [ ] `build.gradle` 中的 `GAS_WEB_APP_URL` 已更新
- [ ] `strings.xml` 中的 `default_web_client_id` 已更新
- [ ] GAS 應用程式已設定 `setXFrameOptionsMode(ALLOWALL)`
- [ ] GAS 應用程式已部署並可訪問
- [ ] SHA-1 憑證已添加到 Google Cloud Console

### 5.3 建置測試

```bash
# 清理並建置 Debug 版本
./gradlew clean assembleDebug
```

如果建置成功，輸出應顯示:

```
BUILD SUCCESSFUL in Xs
```

### 5.4 執行測試

1. 連接 Android 設備或啟動模擬器
2. 在 Android Studio 中點擊 **Run → Run 'app'**
3. 測試登入流程：
   - 是否顯示 Google Sign-In 按鈕？
   - 點擊後是否開啟 Google 帳號選擇器？
   - 選擇正確的 Workspace 帳號後，是否成功登入？
   - 是否載入 GAS 應用程式？
   - 選擇錯誤的帳號（非允許網域）時，是否顯示錯誤訊息？

---

## 🔧 疑難排解

### 問題 1: "Error: The app is not authorized"

**原因**: SHA-1 憑證未添加或不正確

**解決方案**:
1. 重新獲取 SHA-1 憑證（參考步驟 1.4）
2. 在 Google Cloud Console 中添加或更新 Android 用戶端 ID
3. 等待 5-10 分鐘讓更改生效
4. 重新建置並安裝應用程式

### 問題 2: "Error 403: Forbidden" 在 WebView 中

**原因**: GAS 應用程式未設定 `setXFrameOptionsMode`

**解決方案**:
1. 檢查 `code.js` 中的 `doGet()` 函式
2. 確保包含 `htmlOutput.setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)`
3. 重新部署 GAS 應用程式

### 問題 3: "default_web_client_id not found"

**原因**: `strings.xml` 中未設定或設定錯誤

**解決方案**:
1. 檢查 `app/src/main/res/values/strings.xml`
2. 確保有 `<string name="default_web_client_id">...</string>`
3. 值必須是 **Web Client ID**，不是 Android Client ID
4. 同步 Gradle

### 問題 4: 網域驗證失敗

**原因**: `ALLOWED_DOMAINS` 設定不正確

**解決方案**:
1. 檢查 `app/build.gradle` 中的 `ALLOWED_DOMAINS`
2. 確保格式正確：`'{"domain1.com", "domain2.com"}'`
3. 注意不要包含 `@` 符號
4. 同步 Gradle 並重新建置

---

## ✅ 配置完成

完成所有配置後，您的應用程式應該能夠：

1. ✅ 正確啟動並顯示 Splash Screen
2. ✅ 在登入畫面顯示 Google Sign-In 按鈕
3. ✅ 觸發 Google 帳號選擇器
4. ✅ 驗證使用者的網域
5. ✅ 成功登入後載入 GAS 應用程式
6. ✅ 在 WebView 中顯示完整的表單功能

如有任何問題，請參考 [README.md](README.md) 或 [DEPLOYMENT.md](DEPLOYMENT.md)。
