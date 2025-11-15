# 部署指南 (Deployment Guide)

本文件詳細說明如何建置、簽名和發布 Android 原生應用程式到 Google Play Store 或內部發布。

## 📋 目錄

1. [開發環境建置](#1-開發環境建置)
2. [建置 Debug 版本](#2-建置-debug-版本)
3. [建立簽名金鑰](#3-建立簽名金鑰)
4. [建置 Release 版本](#4-建置-release-版本)
5. [發布到 Google Play Store](#5-發布到-google-play-store)
6. [內部發布 (Managed Google Play)](#6-內部發布-managed-google-play)
7. [版本更新](#7-版本更新)

---

## 1. 開發環境建置

### 1.1 安裝必要工具

確保已安裝以下工具：

- ✅ **Android Studio** (Arctic Fox 或更新版本)
  - 下載: https://developer.android.com/studio
- ✅ **JDK 8 或更高版本**
- ✅ **Git** (用於版本控制)

### 1.2 導入專案

```bash
# Clone 專案
cd /path/to/your/workspace
git clone <your-repository-url>

# 或直接使用現有專案
cd auditor_tool/android-app
```

在 Android Studio 中：
1. 選擇 **File → Open**
2. 導航到 `auditor_tool/android-app` 目錄
3. 點擊 **OK**
4. 等待 Gradle 同步完成

### 1.3 配置專案

在建置前，請先完成配置步驟（參考 [CONFIGURATION.md](CONFIGURATION.md)）：

- [ ] 放置 `google-services.json`
- [ ] 更新 `build.gradle` 配置
- [ ] 更新 `strings.xml`
- [ ] 設定 GAS 應用程式的 X-Frame-Options

---

## 2. 建置 Debug 版本

Debug 版本用於開發和測試，使用 Android 預設的 debug keystore。

### 2.1 使用 Android Studio 建置

1. 選擇 **Build → Build Bundle(s) / APK(s) → Build APK(s)**
2. 等待建置完成
3. 點擊通知中的 **locate** 連結查看輸出

輸出位置: `app/build/outputs/apk/debug/app-debug.apk`

### 2.2 使用命令列建置

```bash
# 在專案根目錄 (android-app/)
./gradlew assembleDebug
```

### 2.3 安裝到設備

```bash
# 透過 ADB 安裝
adb install app/build/outputs/apk/debug/app-debug.apk

# 或在 Android Studio 中直接 Run
```

---

## 3. 建立簽名金鑰

Release 版本需要使用簽名金鑰進行簽名。這是發布到 Google Play Store 的必要步驟。

### 3.1 生成 Keystore

```bash
# 在安全的位置生成 keystore
keytool -genkey -v \
  -keystore ~/keystores/auditor-release.keystore \
  -alias auditor-key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# 系統會提示您輸入以下資訊：
# - Keystore 密碼（請務必記住！）
# - 金鑰密碼（建議與 keystore 密碼相同）
# - 姓名、組織、城市等資訊
```

**重要提示:**
- ⚠️ **妥善保管 keystore 文件和密碼！** 如果遺失，將無法更新應用程式。
- ⚠️ **建議將 keystore 備份到安全的位置（如加密的雲端儲存）**
- ⚠️ **不要將 keystore 提交到版本控制系統（Git）**

### 3.2 獲取 SHA-1 指紋

```bash
keytool -list -v -alias auditor-key \
  -keystore ~/keystores/auditor-release.keystore
```

找到 `SHA1:` 開頭的行，複製該值，並將其添加到 Google Cloud Console（參考 CONFIGURATION.md）。

### 3.3 配置簽名設定

#### 方法 1: 使用 gradle.properties (推薦)

在專案根目錄建立 `keystore.properties` 文件：

```properties
# keystore.properties (不要提交到 Git!)
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=auditor-key
storeFile=/absolute/path/to/auditor-release.keystore
```

更新 `app/build.gradle`：

```gradle
// 在 android {} 區塊之前
def keystorePropertiesFile = rootProject.file("keystore.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**確保將 `keystore.properties` 添加到 `.gitignore`:**

```bash
# 在專案根目錄
echo "keystore.properties" >> .gitignore
```

#### 方法 2: 環境變數

```bash
# 設定環境變數
export AUDITOR_KEYSTORE_FILE="/path/to/auditor-release.keystore"
export AUDITOR_KEYSTORE_PASSWORD="your-password"
export AUDITOR_KEY_ALIAS="auditor-key"
export AUDITOR_KEY_PASSWORD="your-key-password"

# 然後在 build.gradle 中使用 System.getenv()
```

---

## 4. 建置 Release 版本

### 4.1 清理專案

```bash
./gradlew clean
```

### 4.2 建置 Release APK

```bash
./gradlew assembleRelease
```

輸出位置: `app/build/outputs/apk/release/app-release.apk`

### 4.3 建置 Android App Bundle (推薦)

Android App Bundle (AAB) 是 Google Play 推薦的發布格式，可以減少下載大小。

```bash
./gradlew bundleRelease
```

輸出位置: `app/build/outputs/bundle/release/app-release.aab`

### 4.4 驗證簽名

```bash
# 驗證 APK 簽名
jarsigner -verify -verbose -certs app/build/outputs/apk/release/app-release.apk

# 或使用 apksigner (Android SDK Build Tools)
apksigner verify --print-certs app/build/outputs/apk/release/app-release.apk
```

---

## 5. 發布到 Google Play Store

### 5.1 建立 Google Play Console 帳號

1. 前往 [Google Play Console](https://play.google.com/console)
2. 支付一次性註冊費用（$25 USD）
3. 完成帳號設定

### 5.2 建立應用程式

1. 在 Play Console 中點擊 **建立應用程式**
2. 填寫基本資訊：
   - **應用程式名稱**: `電腦軟體版本稽核`
   - **預設語言**: `繁體中文`
   - **應用程式或遊戲**: 應用程式
   - **免費或付費**: 免費
3. 接受開發者計畫政策
4. 點擊 **建立應用程式**

### 5.3 填寫商店資訊

#### 應用程式類別

- **應用程式**: 工具
- **目標年齡層**: 適用於所有年齡層

#### 內容分級

1. 前往 **內容分級**
2. 填寫問卷（根據您的應用程式內容）
3. 送出並獲得分級

#### 隱私權政策

如果您的應用程式收集使用者資料，需要提供隱私權政策 URL。

簡易範本：

```
本應用程式收集以下資料：
- Google 帳號的 Email 地址（用於身份驗證）
- 表單提交的資料（儲存於 Google Sheets）

資料使用方式：
- 僅用於內部稽核用途
- 不會分享給第三方
- 儲存於 Google Workspace 中

聯絡方式：
your-email@your-company.com
```

### 5.4 準備商店資源

#### App 圖示
- 尺寸: 512 x 512 px
- 格式: PNG (32-bit)

#### 精選圖片
- 尺寸: 1024 x 500 px
- 格式: JPEG 或 PNG

#### 螢幕截圖
- 至少 2 張，最多 8 張
- 手機: 最小 320 px，最大 3840 px
- 平板 (可選): 最小 320 px，最大 3840 px

建議使用 Android 模擬器截圖：
1. 執行應用程式
2. 截取以下畫面：
   - 登入畫面
   - 表單主畫面
   - 表單填寫範例
   - 提交成功畫面

### 5.5 建立發布版本

1. 前往 **發布 → 正式版**
2. 點擊 **建立新版本**
3. 選擇 **使用 Google Play 應用程式簽署功能**（推薦）
4. 上傳 AAB 文件: `app-release.aab`
5. 填寫版本資訊：

```
版本名稱: 1.0
版本代碼: 1

這個版本的新功能：
- 首次發布
- Google Workspace 帳號驗證
- 電腦軟體版本稽核表單
- 支援手機和平板
```

6. 檢閱並發布

### 5.6 測試發布 (建議)

在正式發布前，建議先進行測試：

1. 前往 **發布 → 內部測試** 或 **封閉式測試**
2. 建立測試群組，添加測試人員的 Email
3. 上傳 AAB 並發布
4. 測試人員透過測試連結下載並測試
5. 收集反饋並修正問題
6. 確認無誤後再發布到正式版

---

## 6. 內部發布 (Managed Google Play)

如果您的組織使用 Google Workspace，可以透過 Managed Google Play 進行內部發布，無需公開到 Play Store。

### 6.1 前置需求

- ✅ 組織必須有 Google Workspace 帳號
- ✅ 啟用 Managed Google Play

### 6.2 發布到 Managed Google Play

1. 登入 [Google Play Console](https://play.google.com/console)
2. 建立應用程式時，選擇 **僅限內部 Managed Google Play**
3. 上傳 APK 或 AAB
4. 填寫基本資訊
5. 發布

### 6.3 使用者安裝

組織內的使用者可以透過 Managed Google Play 商店安裝應用程式：

1. 在 Android 設備上開啟 **Play Store**
2. 切換到組織帳號
3. 搜尋應用程式名稱
4. 點擊 **安裝**

### 6.4 優點

- ✅ 無需公開發布
- ✅ 僅限組織內部使用者
- ✅ 可透過 MDM (Mobile Device Management) 推送安裝
- ✅ 符合企業隱私和安全需求

---

## 7. 版本更新

### 7.1 更新版本號

編輯 `app/build.gradle`：

```gradle
android {
    defaultConfig {
        versionCode 2        // 遞增（必須大於上一版）
        versionName "1.1"    // 顯示給使用者的版本號
    }
}
```

**版本號規則:**
- `versionCode`: 整數，每次發布必須遞增
- `versionName`: 字串，建議使用語意化版本（如 `1.0.0`）

### 7.2 記錄更新內容

建立 `CHANGELOG.md` 記錄每個版本的更新內容：

```markdown
# 更新日誌

## [1.1.0] - 2025-11-20
### 新增
- 新增掃描條碼功能
- 支援離線模式

### 修正
- 修正登入時的網路錯誤
- 改善 WebView 載入速度

## [1.0.0] - 2025-11-15
### 新增
- 首次發布
- Google Sign-In 整合
- WebView 載入 GAS 應用程式
```

### 7.3 建置並發布更新

```bash
# 清理並建置
./gradlew clean bundleRelease

# 上傳到 Google Play Console
# 1. 前往「發布 → 正式版」
# 2. 建立新版本
# 3. 上傳新的 AAB
# 4. 填寫更新說明
# 5. 檢閱並發布
```

### 7.4 漸進式推出 (Staged Rollout)

為了降低風險，可以使用漸進式推出：

1. 在 Play Console 中選擇 **漸進式推出**
2. 設定推出百分比（如 10%）
3. 監控崩潰率和評價
4. 逐步增加到 20% → 50% → 100%

---

## 🔧 疑難排解

### 問題 1: "密鑰庫已竄改，或密碼不正確"

**原因**: Keystore 密碼錯誤

**解決方案**:
- 確認 `keystore.properties` 中的密碼正確
- 檢查 keystore 文件路徑是否正確

### 問題 2: "上傳失敗: 您已上傳使用此憑證簽署的 APK"

**原因**: 版本號未遞增

**解決方案**:
- 增加 `versionCode` 的值
- 重新建置並上傳

### 問題 3: Release 版本無法登入 Google

**原因**: Release keystore 的 SHA-1 未添加到 Google Cloud Console

**解決方案**:
1. 獲取 Release keystore 的 SHA-1
2. 在 Google Cloud Console 建立新的 Android OAuth 用戶端
3. 等待 5-10 分鐘
4. 重新安裝並測試

### 問題 4: ProGuard 導致應用程式崩潰

**原因**: ProGuard 移除了必要的類別

**解決方案**:
1. 檢查 `proguard-rules.pro`
2. 添加 `-keep` 規則保留必要的類別
3. 使用 `-dontwarn` 忽略警告（謹慎使用）

範例：
```proguard
# 保留 Google Sign-In 相關類別
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
```

---

## ✅ 發布檢查清單

在發布前，請確認：

- [ ] 所有功能測試通過
- [ ] 在多個設備上測試（手機、平板、不同 Android 版本）
- [ ] 更新 `versionCode` 和 `versionName`
- [ ] 填寫更新說明
- [ ] Release keystore 的 SHA-1 已添加到 Google Cloud Console
- [ ] ProGuard 規則正確設定
- [ ] 商店資訊（截圖、描述）已更新
- [ ] 隱私權政策和條款已更新（如有變更）
- [ ] 建立 Git tag 標記版本

```bash
# 建立 Git tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## 📞 支援資源

- **Android 開發者文件**: https://developer.android.com/
- **Google Play Console 說明**: https://support.google.com/googleplay/android-developer/
- **應用程式簽署**: https://developer.android.com/studio/publish/app-signing

如有問題，請聯繫開發團隊。
