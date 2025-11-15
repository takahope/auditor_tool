# iOS 原生應用程式開發指南

本文件說明如何使用 `ios/` 目錄中的 iOS 原生應用程式。

## 📱 關於 iOS App

為了解決移動端使用者訪問 Google Apps Script (GAS) Web App 時遇到的 Google 帳號混亂問題，我們開發了一個原生 iOS 應用程式，作為 GAS 應用的統一入口。

### 解決的問題

當使用者在 iPhone/iPad 的瀏覽器中訪問 GAS Web App 時，經常會遇到：
- 被強制導向 Google 帳號選擇頁面
- 使用者容易選錯帳號（個人帳號 vs 公司帳號）
- 反覆登入、切換帳號，使用體驗不佳
- 缺乏品牌一致性

### 解決方案

iOS 原生應用提供：
- ✅ 原生的 Google 登入介面
- ✅ 強制驗證使用者帳號網域（只允許公司帳號）
- ✅ 安全的憑證儲存（iOS Keychain）
- ✅ 在應用內無縫載入 GAS Web App
- ✅ 完全客製化的品牌體驗

## 🚀 快速開始

### 1. 環境需求

- macOS 12.0 (Monterey) 或更新版本
- Xcode 14.0 或更新版本
- Apple Developer 帳號

### 2. 導航到 iOS 目錄

```bash
cd ios
```

### 3. 閱讀詳細文檔

所有詳細的設置、開發和部署說明都在 `ios/` 目錄中：

- **[ios/README.md](./ios/README.md)** - 主要文檔，包含快速開始、配置、開發和部署指南
- **[ios/XCODE_SETUP.md](./ios/XCODE_SETUP.md)** - Xcode 專案設置的詳細步驟指南

### 4. 配置檢查

在開始之前，執行配置檢查腳本以驗證環境：

```bash
cd ios
./check_config.sh
```

## 📂 專案結構概覽

```
ios/
├── AuditorApp/              # iOS 應用程式原始碼
│   ├── Views/              # SwiftUI 視圖
│   ├── Models/             # 資料模型
│   ├── Utilities/          # 工具類和常數
│   └── Resources/          # 資源檔案
├── Podfile                 # CocoaPods 依賴
├── README.md               # 詳細說明文檔
├── XCODE_SETUP.md          # Xcode 設置指南
└── check_config.sh         # 配置檢查腳本
```

## 🔧 關鍵配置步驟

### 1. Google Cloud Console 配置

在開發 iOS App 之前，您需要：

1. 建立或選擇 Google Cloud 專案
2. 啟用 Google Sign-In API
3. 建立 iOS OAuth 2.0 Client ID
4. 下載 `GoogleService-Info.plist`

### 2. 應用程式配置

需要配置三個關鍵檔案：

#### `Constants.swift`
```swift
static let googleClientID = "YOUR_CLIENT_ID.apps.googleusercontent.com"
static let allowedDomains = ["your-company.com"]
static let gasWebAppURL = "https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec"
```

#### `Info.plist`
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
</array>
```

#### `GoogleService-Info.plist`
從 Google Cloud Console 下載實際的配置檔案。

### 3. GAS 應用配置

**重要**：GAS 應用必須設定允許在 iframe 中載入。

在 `code.js` 的 `doGet()` 函式中確認：

```javascript
const htmlOutput = HtmlService.createHtmlOutputFromFile('Index')
  .setTitle('電腦軟體版本更新稽核紀錄');

// ⭐ 關鍵配置：允許在 WKWebView 中載入
htmlOutput.setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);

return htmlOutput;
```

✅ 本專案的 GAS 應用已經正確配置（參見 `code.js:29`）。

## 📱 支援的平台

- **iOS**：15.0 及以上
- **裝置**：iPhone、iPad
- **方向**：支援直向和橫向

## 🔒 安全性

- **Keychain 儲存**：所有敏感資料儲存在 iOS Keychain 中
- **網域驗證**：強制驗證使用者 Email 網域
- **HTTPS**：強制使用 HTTPS 連線
- **最小權限**：僅請求必要的權限

## 📦 部署選項

### 選項 1: App Store（公開發布）

適合：對外提供服務的應用

詳細步驟請參考 `ios/README.md` 的「部署到 App Store」章節。

### 選項 2: Apple Business Manager（企業內部）

適合：僅供公司內部使用的應用

透過 Apple Business Manager 和 MDM 系統進行內部分發。

### 選項 3: TestFlight（測試）

適合：開發和測試階段

透過 TestFlight 邀請測試人員進行測試。

## 🐛 疑難排解

### 常見問題

**Q: 如何開始開發？**
A: 請閱讀 `ios/XCODE_SETUP.md` 的詳細步驟指南。

**Q: Google Sign-In 失敗？**
A: 檢查 `Constants.swift` 和 `Info.plist` 中的配置是否正確。

**Q: WKWebView 載入失敗？**
A: 確認 GAS 應用已設定 `setXFrameOptionsMode(ALLOWALL)`。

**Q: 編譯錯誤 "No such module 'GoogleSignIn'"？**
A: 確保使用 `AuditorApp.xcworkspace` 開啟專案，而非 `.xcodeproj`。

詳細的疑難排解請參考 `ios/README.md` 的「常見問題」章節。

## 📚 延伸閱讀

- [產品需求文件 (PRD)](./PRD.md) - 完整的產品規格說明
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)

## 🤝 支援

如有技術問題或需要協助，請參考：
1. `ios/README.md` - 完整的開發文檔
2. `ios/XCODE_SETUP.md` - 詳細的設置步驟
3. 執行 `ios/check_config.sh` - 自動檢查配置

---

**提示**：本文件提供 iOS 應用的概覽。所有詳細的技術文檔都在 `ios/` 目錄中。
