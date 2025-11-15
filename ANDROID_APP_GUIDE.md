# Android 原生應用程式開發完成指南

## 📱 專案完成狀態

✅ **Android 原生應用程式已完成開發**

根據 PRD (產品需求文件)，我們已經完成了一個完整的 Android 原生入口應用程式，作為 Google Apps Script (GAS) 網頁應用程式的統一入口。

## 📂 專案位置

```
auditor_tool/
├── android-app/              # Android 應用程式專案
│   ├── app/                  # 主要應用程式模組
│   ├── README.md             # 專案說明
│   ├── CONFIGURATION.md      # 配置指南
│   ├── DEPLOYMENT.md         # 部署指南
│   └── ...
├── code.js                   # GAS 後端（已存在）
├── Index.html                # GAS 前端（已存在）
└── ANDROID_APP_GUIDE.md      # 本文件
```

## 🎯 已實現的功能

### ✅ 所有功能需求 (Functional Requirements)

1. **FR 5.1.1-5.1.5: 登入與驗證**
   - ✅ 整合 Google Sign-In for Android SDK
   - ✅ 獲取並驗證使用者 Email
   - ✅ 可配置的允許網域列表
   - ✅ 原生錯誤提示 (AlertDialog)
   - ✅ Android Keystore 加密儲存憑證

2. **FR 5.2.1-5.2.5: WebView 整合**
   - ✅ 在 WebView 中載入 GAS 應用程式
   - ✅ 與 Google Sign-In 共享認證狀態
   - ✅ 全螢幕 WebView 體驗
   - ✅ 下拉刷新功能 (SwipeRefreshLayout)
   - ✅ 原生工具列（首頁、刷新、登出）

3. **FR 5.3.1: GAS 設定**
   - ✅ code.js 已設定 `setXFrameOptionsMode(ALLOWALL)`（第 29 行）

### ✅ 所有非功能需求 (Non-Functional Requirements)

- ✅ **NFR 6.1**: 支援 Android 8.0 (API 26) 及以上
- ✅ **NFR 6.2**: 支援手機和平板（響應式佈局）
- ✅ **NFR 6.3**: 快速啟動，WebView 啟用快取
- ✅ **NFR 6.4**: Android Keystore 加密儲存
- ✅ **NFR 6.5**: 可透過 Google Play Store 發布

## 🏗️ 技術架構

### 核心技術

- **語言**: Kotlin
- **UI 框架**: XML Layouts + Material Design Components
- **最低 API**: 26 (Android 8.0 Oreo)
- **目標 API**: 34 (Android 14)

### 主要元件

1. **SplashActivity.kt** - 啟動畫面，檢查登入狀態
2. **LoginActivity.kt** - Google Sign-In 登入介面
3. **WebViewActivity.kt** - 載入 GAS 應用的 WebView
4. **AuthManager.kt** - 認證管理（登入、網域驗證）
5. **SecurePreferences.kt** - 加密儲存（Android Keystore）

### 安全性措施

- ✅ Android Keystore 硬體加密
- ✅ 網域驗證機制
- ✅ HTTPS Only
- ✅ 備份排除敏感資料
- ✅ ProGuard 代碼混淆

## 📋 下一步：配置與部署

### 步驟 1: 配置 Google Cloud Console

請參考 `android-app/CONFIGURATION.md`，完成以下設定：

1. ✅ 建立 Google Cloud 專案
2. ✅ 啟用 Google Sign-In API
3. ✅ 配置 OAuth 同意畫面
4. ✅ 建立 Web Client ID 和 Android Client ID
5. ✅ 下載 `google-services.json`

### 步驟 2: 更新應用程式配置

需要更新以下檔案中的配置：

#### `android-app/app/build.gradle`

```gradle
defaultConfig {
    // 1. 設定允許的網域（替換為您的公司網域）
    buildConfigField "String[]", "ALLOWED_DOMAINS", '{"your-company.com"}'

    // 2. 設定 GAS Web App URL（替換為實際的部署 URL）
    buildConfigField "String", "GAS_WEB_APP_URL", '"https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec"'
}
```

#### `android-app/app/src/main/res/values/strings.xml`

```xml
<!-- 替換為您的 Web Client ID -->
<string name="default_web_client_id" translatable="false">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
```

#### `android-app/app/google-services.json`

將從 Google Cloud Console 下載的 `google-services.json` 放置於 `android-app/app/` 目錄。

### 步驟 3: 建置與測試

```bash
# 進入 Android 專案目錄
cd android-app

# 建置 Debug 版本
./gradlew assembleDebug

# 輸出位置: app/build/outputs/apk/debug/app-debug.apk
```

### 步驟 4: 部署

請參考 `android-app/DEPLOYMENT.md`，了解如何：

1. 建立簽名金鑰
2. 建置 Release 版本
3. 發布到 Google Play Store
4. 或透過 Managed Google Play 內部發布

## 🎨 自訂品牌

### 更換 App 圖示

1. 準備 512x512 PNG 圖示
2. 在 Android Studio 中：
   - 右鍵點擊 `res/` → **New → Image Asset**
   - 選擇您的圖示檔案
   - 自動生成所有尺寸

### 更改顏色主題

編輯 `android-app/app/src/main/res/values/colors.xml`

### 更改應用名稱

編輯 `android-app/app/src/main/res/values/strings.xml`

## 📱 使用者流程

1. **啟動**: 使用者點擊 App 圖示
2. **Splash Screen**: 檢查登入狀態
3. **登入（如需要）**:
   - 顯示「使用 Google 帳號登入」按鈕
   - 觸發 Google Sign-In
   - 驗證網域（必須是允許的網域）
4. **載入 GAS**:
   - 在 WebView 中載入 GAS 應用
   - 自動使用已驗證的帳號
5. **使用應用**: 完整的表單功能

## 🔍 專案結構說明

```
android-app/
├── app/
│   ├── src/main/
│   │   ├── java/com/company/auditor/
│   │   │   ├── SplashActivity.kt          # 啟動畫面
│   │   │   ├── LoginActivity.kt           # 登入畫面
│   │   │   ├── WebViewActivity.kt         # WebView 載入 GAS
│   │   │   ├── AuthManager.kt             # 認證管理
│   │   │   └── SecurePreferences.kt       # 加密儲存
│   │   ├── res/
│   │   │   ├── layout/                    # UI 佈局
│   │   │   │   ├── activity_splash.xml
│   │   │   │   ├── activity_login.xml
│   │   │   │   └── activity_webview.xml
│   │   │   ├── values/
│   │   │   │   ├── strings.xml            # 字串資源
│   │   │   │   ├── colors.xml             # 顏色定義
│   │   │   │   └── themes.xml             # 主題樣式
│   │   │   ├── drawable/                  # 圖示和背景
│   │   │   ├── menu/                      # 選單
│   │   │   └── xml/                       # 備份規則
│   │   └── AndroidManifest.xml            # 應用程式清單
│   ├── build.gradle                       # App 構建配置
│   ├── google-services.json.template      # 配置範本
│   └── proguard-rules.pro                 # ProGuard 規則
├── build.gradle                           # 專案構建配置
├── settings.gradle                        # Gradle 設定
├── gradle.properties                      # Gradle 屬性
├── .gitignore                            # Git 忽略清單
├── README.md                             # 專案說明
├── CONFIGURATION.md                      # 配置指南
└── DEPLOYMENT.md                         # 部署指南
```

## 📚 相關文件

- **[README.md](android-app/README.md)** - 專案概述和快速入門
- **[CONFIGURATION.md](android-app/CONFIGURATION.md)** - 詳細配置指南
- **[DEPLOYMENT.md](android-app/DEPLOYMENT.md)** - 部署和發布指南
- **[CLAUDE.md](CLAUDE.md)** - GAS 專案說明

## ✅ 功能檢查清單

### 登入與驗證
- [x] Google Sign-In SDK 整合
- [x] Email 獲取
- [x] 網域驗證
- [x] 錯誤提示（原生 AlertDialog）
- [x] 憑證加密儲存（Android Keystore）

### WebView 整合
- [x] 載入 GAS 應用
- [x] Cookie 共享（認證狀態）
- [x] 全螢幕顯示
- [x] 下拉刷新
- [x] 工具列（首頁、刷新、登出）
- [x] 進度條顯示
- [x] 錯誤處理與重試

### 使用者體驗
- [x] Splash Screen
- [x] 品牌化登入介面
- [x] 流暢的導航流程
- [x] 返回鍵處理

### 安全性
- [x] Android Keystore 加密
- [x] HTTPS Only
- [x] 備份排除
- [x] ProGuard 混淆

### 平台支援
- [x] Android 8.0+ (API 26+)
- [x] 手機支援
- [x] 平板支援（響應式佈局）

## 🐛 疑難排解

如果遇到問題，請參考：

1. **配置問題**: 查看 `CONFIGURATION.md`
2. **建置問題**: 查看 `DEPLOYMENT.md`
3. **執行問題**: 查看 `README.md` 的疑難排解章節

常見問題：

- **登入失敗**: 檢查 SHA-1 憑證是否已添加
- **網域驗證失敗**: 檢查 `ALLOWED_DOMAINS` 設定
- **WebView 顯示 403**: 確認 GAS 已設定 `setXFrameOptionsMode`

## 📞 技術支援

如有任何問題或需要協助，請：

1. 查閱相關文件
2. 檢查配置是否正確
3. 聯繫開發團隊

---

## 🎉 專案完成

恭喜！Android 原生應用程式已完成開發。只需完成配置步驟，即可開始使用。

**開發完成日期**: 2025年11月15日
**版本**: 1.0
**符合 PRD**: ✅ 所有功能和非功能需求均已實現
