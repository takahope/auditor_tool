# AuditorApp - iOS 原生入口應用程式

電腦軟體版本更新稽核紀錄系統的 iOS 原生入口應用程式。

## 📱 專案概述

本專案是基於 [Google Apps Script iOS 原生入口應用程式 PRD](../PRD.md) 開發的原生 iOS 應用程式，旨在解決移動端使用者訪問 Google Apps Script (GAS) Web App 時遇到的帳號驗證問題。

### 核心功能

✅ **原生 Google 登入**：使用 Google Sign-In for iOS SDK，提供流暢的登入體驗
✅ **網域驗證**：確保只有公司 Workspace 帳號能夠訪問
✅ **安全儲存**：使用 iOS Keychain 安全儲存登入憑證
✅ **無縫整合**：在原生 WKWebView 中載入 GAS 應用，提供一致的使用體驗
✅ **品牌一致**：完全客製化的 UI，與企業品牌保持一致

### 技術架構

- **開發語言**：Swift
- **UI 框架**：SwiftUI
- **最低版本**：iOS 15.0
- **支援裝置**：iPhone、iPad
- **依賴管理**：CocoaPods
- **主要依賴**：Google Sign-In SDK 7.0

## 📂 專案結構

```
ios/
├── AuditorApp/
│   ├── AuditorApp.swift           # App 入口點
│   ├── Info.plist                 # 應用程式配置
│   ├── GoogleService-Info.plist   # Google 服務配置（需自行下載）
│   │
│   ├── Views/                     # SwiftUI 視圖
│   │   ├── ContentView.swift      # 主要視圖（路由邏輯）
│   │   ├── LoginView.swift        # 登入畫面
│   │   └── WebAppView.swift       # WKWebView 容器
│   │
│   ├── Models/                    # 資料模型
│   │   └── AuthenticationManager.swift  # 認證管理器
│   │
│   └── Utilities/                 # 工具類
│       ├── Constants.swift        # 常數定義
│       └── KeychainHelper.swift   # Keychain 安全儲存
│
├── Podfile                        # CocoaPods 依賴定義
├── README.md                      # 本文件
└── XCODE_SETUP.md                 # Xcode 專案設置詳細指南
```

## 🚀 快速開始

### 前置需求

在開始之前，請確保您已安裝：

- macOS 12.0 (Monterey) 或更新版本
- Xcode 14.0 或更新版本
- CocoaPods
- Apple Developer 帳號（用於在實體裝置上測試）

### 步驟 1: 複製專案

```bash
git clone <repository-url>
cd auditor_tool/ios
```

### 步驟 2: 安裝依賴

```bash
# 如果尚未安裝 CocoaPods
sudo gem install cocoapods

# 安裝專案依賴
pod install
```

### 步驟 3: 配置 Google Sign-In

#### 3.1 建立 Google Cloud 專案

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 建立新專案或選擇現有專案
3. 啟用 **Google Sign-In API**

#### 3.2 建立 OAuth 2.0 Client ID

1. 前往 **APIs & Services → Credentials**
2. 點擊 **+ CREATE CREDENTIALS → OAuth client ID**
3. 選擇 **iOS** 作為應用程式類型
4. 填寫 Bundle ID：`com.yourcompany.AuditorApp`
5. 記下 **Client ID** 和 **iOS URL scheme**

#### 3.3 下載並添加 GoogleService-Info.plist

1. 下載 `GoogleService-Info.plist`
2. 將其放置在 `ios/AuditorApp/` 目錄下
3. **重要**：確保此檔案不被提交到版本控制（已在 `.gitignore` 中）

### 步驟 4: 更新配置

#### 4.1 更新 Constants.swift

開啟 `AuditorApp/Utilities/Constants.swift`，更新以下值：

```swift
// Google OAuth Client ID
static let googleClientID = "YOUR_CLIENT_ID.apps.googleusercontent.com"

// 允許的 Workspace 網域
static let allowedDomains = ["your-company.com"]

// GAS Web App URL
static let gasWebAppURL = "https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec"
```

#### 4.2 更新 Info.plist

開啟 `AuditorApp/Info.plist`，找到 `CFBundleURLTypes`，將 `YOUR_REVERSED_CLIENT_ID` 替換為您的實際值（格式：`com.googleusercontent.apps.XXXXXXXXX`）。

### 步驟 5: 開啟專案並建置

```bash
# 開啟 Workspace（重要：必須開啟 .xcworkspace，而非 .xcodeproj）
open AuditorApp.xcworkspace
```

在 Xcode 中：
1. 選擇您的開發團隊（Signing & Capabilities）
2. 選擇目標裝置（模擬器或實體裝置）
3. 按下 ⌘ + R 執行

## 📖 詳細設置指南

如果您需要從零開始建立 Xcode 專案，或遇到任何問題，請參考：

👉 [XCODE_SETUP.md](./XCODE_SETUP.md) - Xcode 專案設置詳細指南

## 🔧 開發指南

### 修改品牌元素

#### 1. 修改顏色

在 `Constants.swift` 中修改品牌顏色：

```swift
static let brandColorHex = "#673ab7"  // 主要品牌色
```

在各個視圖中，使用 `Color(hex: AppConstants.brandColorHex)` 來應用品牌色。

#### 2. 修改應用程式名稱

在 `Constants.swift` 中修改：

```swift
static let appName = "您的應用程式名稱"
```

#### 3. 替換 App Icon

1. 準備各種尺寸的應用程式圖示（推薦使用 [AppIcon.co](https://appicon.co)）
2. 在 Xcode 中打開 `Assets.xcassets`
3. 將圖示拖放到 `AppIcon` 中

### 添加新功能

#### 1. 添加新的視圖

在 `Views/` 目錄下建立新的 Swift 檔案：

```swift
import SwiftUI

struct YourNewView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

#### 2. 修改導航邏輯

在 `ContentView.swift` 中修改視圖路由邏輯。

### 除錯技巧

#### 檢視 Keychain 內容

在 `AuthenticationManager.swift` 中添加除錯程式碼：

```swift
if let email = try? KeychainHelper.shared.retrieve(AppConstants.keychainAccountKey) {
    print("儲存的 Email: \(email)")
}
```

#### 檢視 WKWebView 錯誤

在 `WebAppView.swift` 的 `Coordinator` 中，檢查錯誤訊息：

```swift
func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print("詳細錯誤: \(error)")
}
```

## 📦 部署到 App Store

### 準備工作

1. **Apple Developer Program**：需要付費的開發者帳號
2. **App Icon**：準備完整的應用程式圖示集
3. **截圖**：準備不同裝置的應用程式截圖
4. **隱私政策**：準備隱私政策文件（必要）

### 步驟

#### 1. 建立 App Store Connect 記錄

1. 前往 [App Store Connect](https://appstoreconnect.apple.com/)
2. 點擊 **我的 App → + 按鈕**
3. 填寫應用程式資訊

#### 2. 配置 Xcode

1. 在 Xcode 中選擇 **Product → Archive**
2. 等待建置完成
3. 在 Organizer 中，選擇您的 Archive
4. 點擊 **Distribute App**
5. 選擇 **App Store Connect**
6. 跟隨指示上傳

#### 3. 提交審核

1. 在 App Store Connect 中填寫所有必要資訊
2. 上傳截圖
3. 填寫版本說明
4. 提交審核

### 企業內部部署（Apple Business Manager）

如果您只想內部發布，可以使用 Apple Business Manager：

1. 註冊 [Apple Business Manager](https://business.apple.com/)
2. 使用企業帳號建置應用程式
3. 透過 MDM（Mobile Device Management）系統分發

## 🔒 安全性考量

### 1. Keychain 安全

- 所有敏感資料（Email、Token）都儲存在 iOS Keychain 中
- 使用 `kSecAttrAccessibleAfterFirstUnlock` 存取政策

### 2. 網路安全

- 強制使用 HTTPS（App Transport Security）
- 只允許連接到 `script.google.com` 和 `accounts.google.com`

### 3. 憑證管理

- `GoogleService-Info.plist` 不應提交到版本控制
- 定期輪換 OAuth Client ID

### 4. 網域驗證

- 嚴格驗證使用者 Email 網域
- 不符合網域的使用者將被拒絕

## 🐛 常見問題

### Q1: Google Sign-In 失敗

**原因**：Client ID 或 URL Scheme 配置錯誤

**解決方法**：
1. 檢查 `Constants.swift` 中的 `googleClientID`
2. 檢查 `Info.plist` 中的 URL Scheme
3. 確認 Google Cloud Console 中的 Bundle ID 正確

### Q2: WKWebView 無法載入 GAS 應用

**原因**：GAS 應用未設定 `setXFrameOptionsMode`

**解決方法**：
在 GAS 的 `code.js` 中確認：

```javascript
htmlOutput.setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
```

### Q3: 編譯錯誤 "No such module 'GoogleSignIn'"

**解決方法**：
```bash
cd ios
pod deintegrate
pod install
open AuditorApp.xcworkspace  # 確保開啟 .xcworkspace
```

### Q4: Keychain 資料遺失

**原因**：應用程式重新安裝或系統更新

**解決方法**：
- 這是正常行為，使用者需要重新登入
- 未來可考慮使用 iCloud Keychain Sync

## 📚 參考資源

- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [WKWebView Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [iOS App Distribution Guide](https://developer.apple.com/distribute/)

## 📄 授權

本專案依據您組織的內部政策管理。

## 🤝 支援

如有問題，請聯絡：
- 技術支援：[your-support-email@your-company.com]
- 專案維護者：[maintainer@your-company.com]

---

**版本**: 1.0.0
**最後更新**: 2025-11-15
**相容性**: iOS 15.0+
