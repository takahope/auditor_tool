# 電腦軟體版本稽核 - Android 原生應用程式

## 📱 專案概述

這是一個 **Android 原生入口應用程式**，作為 Google Apps Script (GAS) 網頁應用程式的統一入口。透過原生應用程式的包裝 (Wrapper)，專門解決在移動端（Android 手機、平板）上因 Google 帳號驗證流程混亂所導致的使用者體驗不佳問題。

### 核心功能

✅ **Google Workspace 帳號驗證**
- 使用 Google Sign-In for Android SDK
- 自動驗證登入帳號的網域（例如：`@your-company.com`）
- 防止使用者使用錯誤的 Google 帳號

✅ **安全的憑證儲存**
- 使用 Android Keystore 加密儲存 OAuth Token
- 符合企業級安全標準

✅ **無縫的 WebView 整合**
- 在 App 內部載入 GAS 應用程式
- 與 Google Sign-In 共享認證狀態
- 提供原生的下拉刷新和工具列功能

✅ **品牌化體驗**
- 自訂啟動畫面 (Splash Screen)
- 統一的品牌形象
- 原生的登入介面

## 🏗️ 技術架構

- **開發語言**: Kotlin
- **最低 Android 版本**: Android 8.0 (API 26, Oreo)
- **目標 Android 版本**: Android 14 (API 34)
- **支援設備**: Android 手機和平板

### 主要依賴項

- **Google Sign-In SDK**: `com.google.android.gms:play-services-auth:20.7.0`
- **Encrypted SharedPreferences**: `androidx.security:security-crypto:1.1.0-alpha06`
- **AndroidX WebKit**: `androidx.webkit:webkit:1.9.0`
- **Material Design Components**: `com.google.android.material:material:1.11.0`
- **Kotlin Coroutines**: `org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3`

## 📂 專案結構

```
android-app/
├── app/
│   ├── src/main/
│   │   ├── java/com/company/auditor/
│   │   │   ├── SplashActivity.kt          # 啟動畫面
│   │   │   ├── LoginActivity.kt           # 登入畫面
│   │   │   ├── WebViewActivity.kt         # WebView 載入 GAS
│   │   │   ├── AuthManager.kt             # Google Sign-In 管理
│   │   │   └── SecurePreferences.kt       # 加密儲存
│   │   ├── res/
│   │   │   ├── layout/                    # 佈局文件
│   │   │   ├── values/                    # 字串、顏色、主題
│   │   │   ├── drawable/                  # 圖示和背景
│   │   │   └── menu/                      # 選單
│   │   └── AndroidManifest.xml
│   ├── build.gradle                       # App 級別構建配置
│   └── google-services.json               # Firebase/Google Services 配置
├── build.gradle                           # 專案級別構建配置
├── settings.gradle
└── README.md                              # 本文件
```

## 🚀 快速入門

### 前置需求

1. **Android Studio** (建議最新版本)
2. **JDK 8 或更高版本**
3. **Google Cloud Console 專案**（用於 Google Sign-In）
4. **已部署的 GAS Web App**

### 安裝步驟

詳細的配置和部署步驟請參閱：
- [CONFIGURATION.md](CONFIGURATION.md) - 配置指南
- [DEPLOYMENT.md](DEPLOYMENT.md) - 部署指南

### 快速配置清單

1. ✅ 在 Google Cloud Console 建立專案並啟用 Google Sign-In API
2. ✅ 下載 `google-services.json` 並放置於 `app/` 目錄
3. ✅ 更新 `app/build.gradle` 中的配置：
   - `ALLOWED_DOMAINS` - 允許的網域列表
   - `GAS_WEB_APP_URL` - GAS 應用程式的 URL
4. ✅ 更新 `app/src/main/res/values/strings.xml` 中的 `default_web_client_id`
5. ✅ 同步 Gradle 並建置專案

## 🔐 安全性

### 實施的安全措施

- ✅ **Android Keystore 加密**: 所有憑證使用硬體支援的加密儲存
- ✅ **網域驗證**: 強制驗證使用者使用指定的 Workspace 網域
- ✅ **HTTPS Only**: 所有網路通訊使用 HTTPS
- ✅ **備份排除**: 敏感憑證檔案排除在備份之外
- ✅ **ProGuard 保護**: Release 版本啟用代碼混淆

### 備份排除配置

應用程式已設定排除敏感資料不參與 Android 備份：
- `app/src/main/res/xml/backup_rules.xml`
- `app/src/main/res/xml/data_extraction_rules.xml`

## 📱 使用者流程

1. **啟動應用程式**: 使用者點擊 App 圖示
2. **Splash Screen**: 顯示品牌啟動畫面，檢查登入狀態
3. **登入（如需要）**:
   - 顯示「使用 Google 帳號登入」按鈕
   - 觸發 Google Sign-In 流程
   - 驗證網域（例如：必須是 `@your-company.com`）
4. **載入 GAS 應用**:
   - 在 WebView 中載入 GAS 應用程式
   - 自動使用已驗證的 Google 帳號
5. **使用應用**: 完整的表單功能和資料提交

## 🎨 自訂品牌

### 更換 App 圖示

1. 準備圖示（建議 512x512 PNG）
2. 使用 Android Studio 的 Image Asset Studio：
   - `右鍵點擊 res/ → New → Image Asset`
   - 選擇您的圖示檔案
   - 自動生成所有尺寸

### 更改顏色主題

編輯 `app/src/main/res/values/colors.xml`：

```xml
<color name="primary">#1976D2</color>        <!-- 主要顏色 -->
<color name="primary_dark">#1565C0</color>   <!-- 深色主題 -->
<color name="accent">#FF5722</color>         <!-- 強調色 -->
```

### 更改應用名稱

編輯 `app/src/main/res/values/strings.xml`：

```xml
<string name="app_name">您的應用名稱</string>
```

## 🛠️ 建置與測試

### Debug 版本

```bash
# 在 Android Studio 中
Build → Build Bundle(s) / APK(s) → Build APK(s)

# 或使用命令列
./gradlew assembleDebug
```

輸出位置: `app/build/outputs/apk/debug/app-debug.apk`

### Release 版本

```bash
# 確保已設定簽名金鑰
./gradlew assembleRelease
```

詳細的簽名和發布步驟請參閱 [DEPLOYMENT.md](DEPLOYMENT.md)

## 📋 需求符合性

本應用程式完全符合 PRD (產品需求文件) 的所有需求：

### 功能需求 (Functional Requirements)

- ✅ **FR 5.1.1**: 整合 Google Sign-In for Android SDK
- ✅ **FR 5.1.2**: 獲取登入使用者的 Email 地址
- ✅ **FR 5.1.3**: 配置允許的網域列表
- ✅ **FR 5.1.4**: 網域驗證和原生錯誤提示
- ✅ **FR 5.1.5**: 使用 Android Keystore 加密儲存憑證
- ✅ **FR 5.2.1**: 在 WebView 中載入 GAS 應用程式
- ✅ **FR 5.2.2**: 與 Google Sign-In 共享認證狀態
- ✅ **FR 5.2.3**: WebView 佔滿螢幕
- ✅ **FR 5.2.4**: 提供下拉刷新功能
- ✅ **FR 5.2.5**: 提供原生工具列（首頁、刷新、登出）

### 非功能需求 (Non-Functional Requirements)

- ✅ **NFR 6.1**: 支援 Android 8.0 (API 26) 及以上
- ✅ **NFR 6.2**: 支援手機和平板（自適應佈局）
- ✅ **NFR 6.3**: 快速啟動，WebView 啟用快取
- ✅ **NFR 6.4**: Android Keystore 加密儲存
- ✅ **NFR 6.5**: 可透過 Google Play Store 發布

## 🐛 疑難排解

### 常見問題

**Q: 登入後顯示 "Error 403: Forbidden"**

A: 確保 GAS 應用程式已設定 `setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)`

**Q: Google Sign-In 失敗**

A: 檢查以下項目：
1. `google-services.json` 是否正確放置
2. `default_web_client_id` 是否正確配置
3. SHA-1 憑證是否已添加到 Google Cloud Console

**Q: 網域驗證失敗**

A: 確認 `app/build.gradle` 中的 `ALLOWED_DOMAINS` 設定正確

## 📄 相關文件

- [CONFIGURATION.md](CONFIGURATION.md) - 詳細配置指南
- [DEPLOYMENT.md](DEPLOYMENT.md) - 部署和發布指南
- [../CLAUDE.md](../CLAUDE.md) - GAS 專案說明

## 📞 支援

如有問題或建議，請聯繫開發團隊。

## 📜 授權

本專案為內部企業應用程式，版權所有。

---

**開發日期**: 2025年11月15日
**版本**: 1.0
**基於 PRD**: Google Apps Script Android 原生入口應用程式
