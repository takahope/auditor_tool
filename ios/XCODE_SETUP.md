# Xcode 專案設置指南

本文件說明如何在 Xcode 中設置 AuditorApp iOS 專案。

## 前置需求

- macOS 12.0 (Monterey) 或更新版本
- Xcode 14.0 或更新版本
- CocoaPods（用於安裝 Google Sign-In SDK）
- Apple Developer 帳號（用於在實體裝置上測試）

## 步驟 1: 安裝 CocoaPods

如果您尚未安裝 CocoaPods，請在終端執行：

```bash
sudo gem install cocoapods
```

## 步驟 2: 建立 Xcode 專案

### 2.1 開啟 Xcode 並建立新專案

1. 啟動 Xcode
2. 選擇 **File → New → Project**
3. 選擇 **iOS → App**
4. 點擊 **Next**

### 2.2 配置專案資訊

填寫以下資訊：

- **Product Name**: `AuditorApp`
- **Team**: 選擇您的 Apple Developer Team
- **Organization Identifier**: `com.yourcompany`（請替換為您的組織識別碼）
- **Bundle Identifier**: 會自動生成為 `com.yourcompany.AuditorApp`
- **Interface**: 選擇 **SwiftUI**
- **Language**: 選擇 **Swift**
- **Storage**: 選擇 **None**（我們使用 Keychain）
- **Include Tests**: 勾選（建議）

點擊 **Next**，選擇儲存位置為 `ios/` 目錄（本專案的 `ios` 資料夾）。

### 2.3 刪除自動生成的檔案

Xcode 會自動生成一些檔案，請刪除以下檔案（我們已經有自己的版本）：

- `ContentView.swift`
- `AuditorAppApp.swift`
- `Assets.xcassets`（保留，但我們稍後會添加圖示）

### 2.4 添加現有的原始碼檔案

在 Xcode 左側的專案導覽器中：

1. 右鍵點擊 `AuditorApp` 資料夾
2. 選擇 **Add Files to "AuditorApp"**
3. 導覽到本專案的 `ios/AuditorApp` 目錄
4. 選擇以下資料夾和檔案（按住 Command 可多選）：
   - `Views/` 資料夾（包含所有 Swift 檔案）
   - `Models/` 資料夾
   - `Utilities/` 資料夾
   - `AuditorApp.swift`
5. **重要**：確保勾選 **Copy items if needed**
6. **重要**：確保勾選 **Create groups**（而非 Create folder references）
7. 點擊 **Add**

### 2.5 添加 Info.plist

1. 在 Xcode 左側的專案導覽器中，右鍵點擊 `AuditorApp` 資料夾
2. 選擇 **Add Files to "AuditorApp"**
3. 選擇 `ios/AuditorApp/Info.plist`
4. 確保勾選 **Copy items if needed**
5. 點擊 **Add**

## 步驟 3: 安裝 CocoaPods 依賴

### 3.1 關閉 Xcode

### 3.2 在終端執行

```bash
cd ios
pod install
```

### 3.3 開啟 Workspace

**重要**：從現在開始，請使用 `AuditorApp.xcworkspace` 開啟專案（而非 `.xcodeproj`）

```bash
open AuditorApp.xcworkspace
```

## 步驟 4: 配置 Google Sign-In

### 4.1 建立 Google Cloud 專案

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 建立新專案或選擇現有專案
3. 啟用 **Google Sign-In API**

### 4.2 建立 iOS OAuth 2.0 Client ID

1. 在 Google Cloud Console 中，前往 **APIs & Services → Credentials**
2. 點擊 **+ CREATE CREDENTIALS → OAuth client ID**
3. 選擇 **iOS** 作為應用程式類型
4. 填寫以下資訊：
   - **Name**: `AuditorApp iOS`
   - **Bundle ID**: `com.yourcompany.AuditorApp`（與您的專案一致）
5. 點擊 **CREATE**
6. 記下 **Client ID**（格式：`XXXXXXXXX-XXXXXXX.apps.googleusercontent.com`）
7. 記下 **iOS URL scheme**（格式：`com.googleusercontent.apps.XXXXXXXXX-XXXXXXX`）

### 4.3 下載 GoogleService-Info.plist

1. 如果 Google Cloud Console 提供下載選項，請下載 `GoogleService-Info.plist`
2. 如果沒有，請手動建立（參考 `GoogleService-Info.plist.template`）
3. 將 `GoogleService-Info.plist` 拖放到 Xcode 專案中
4. **確保勾選 "Copy items if needed"**

### 4.4 更新 Constants.swift

開啟 `Utilities/Constants.swift`，更新以下值：

```swift
static let googleClientID = "YOUR_CLIENT_ID.apps.googleusercontent.com"
static let allowedDomains = ["your-company.com"]  // 您的 Workspace 網域
static let gasWebAppURL = "https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec"
```

### 4.5 更新 Info.plist

開啟 `Info.plist`，找到 `CFBundleURLTypes`，將 `YOUR_REVERSED_CLIENT_ID` 替換為您的實際值（步驟 4.2 中的 iOS URL scheme）。

## 步驟 5: 配置專案設置

在 Xcode 中：

1. 點擊專案導覽器中的專案檔案（藍色圖示）
2. 選擇 **AuditorApp** target
3. 在 **General** 標籤中：
   - **Minimum Deployments**: 設定為 `iOS 15.0`
   - **Supported Destinations**: 勾選 `iPhone` 和 `iPad`
   - **Deployment Info**: 根據需要設定支援的方向
4. 在 **Signing & Capabilities** 標籤中：
   - 選擇您的 **Team**
   - Xcode 會自動管理簽名

### 5.1 添加 Keychain Sharing Capability（可選但建議）

1. 點擊 **+ Capability**
2. 搜尋並添加 **Keychain Sharing**
3. 使用預設的 Keychain Group

## 步驟 6: 添加 App Icon

### 6.1 準備 App Icon

準備不同尺寸的應用程式圖示（建議使用線上工具如 [AppIcon.co](https://appicon.co)）

### 6.2 添加到 Assets

1. 在 Xcode 專案導覽器中，點擊 `Assets.xcassets`
2. 右鍵點擊左側欄，選擇 **App Icons & Launch Images → New iOS App Icon**
3. 將準備好的圖示拖放到對應的尺寸格子中

## 步驟 7: 建置並執行

### 7.1 選擇目標裝置

在 Xcode 頂部工具列中，選擇目標裝置（模擬器或實體裝置）

### 7.2 建置專案

1. 按下 **⌘ + B** 進行建置
2. 檢查是否有任何編譯錯誤

### 7.3 執行應用程式

1. 按下 **⌘ + R** 執行應用程式
2. 第一次執行時，如果出現簽名錯誤，請確保您已選擇正確的 Team

## 步驟 8: 測試 Google Sign-In

### 8.1 在模擬器中測試

**注意**：Google Sign-In 在模擬器中的體驗可能與實體裝置不同

### 8.2 在實體裝置上測試（推薦）

1. 連接您的 iOS 裝置
2. 在 Xcode 中選擇您的裝置作為目標
3. 第一次執行時，可能需要在裝置上信任您的開發者憑證
4. 執行應用程式並測試登入流程

## 常見問題排解

### 問題 1: "No such module 'GoogleSignIn'"

**解決方法**：
```bash
cd ios
pod deintegrate
pod install
```
然後重新開啟 `.xcworkspace`

### 問題 2: Google Sign-In 失敗

**檢查項目**：
- `Constants.swift` 中的 `googleClientID` 是否正確
- `Info.plist` 中的 URL Scheme 是否正確
- Google Cloud Console 中的 Bundle ID 是否與專案一致

### 問題 3: 編譯錯誤 "Cannot find type 'GIDSignIn'"

**解決方法**：
- 確保您開啟的是 `.xcworkspace` 而非 `.xcodeproj`
- 確認已執行 `pod install`

### 問題 4: 網域驗證失敗

**檢查項目**：
- `Constants.swift` 中的 `allowedDomains` 是否包含您的測試帳號網域
- 使用正確的 Google Workspace 帳號登入

## 下一步

完成以上步驟後，您應該已經成功設置了 AuditorApp iOS 專案。接下來：

1. 測試所有功能（登入、載入 GAS 應用、登出）
2. 自訂品牌元素（顏色、圖示、文字）
3. 準備部署到 App Store（參考主 README.md）

## 參考資源

- [Google Sign-In for iOS Documentation](https://developers.google.com/identity/sign-in/ios/start-integrating)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
