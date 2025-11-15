//
//  Constants.swift
//  AuditorApp
//
//  電腦軟體版本更新稽核紀錄系統 - iOS 原生入口應用程式
//  常數定義
//

import Foundation

struct AppConstants {
    // MARK: - Google Sign-In Configuration

    /// Google OAuth 2.0 Client ID
    /// ⚠️ 重要：請在 Google Cloud Console 中建立 iOS OAuth 2.0 Client ID
    /// 並將此處替換為您的實際 Client ID
    static let googleClientID = "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"

    /// 允許的 Google Workspace 網域列表
    /// 根據 PRD FR 5.1.3：只允許特定網域的使用者登入
    /// 範例：["your-company.com", "subsidiary.com"]
    static let allowedDomains = ["your-company.com"]

    // MARK: - GAS Web App Configuration

    /// Google Apps Script Web App 的部署 URL
    /// ⚠️ 重要：請將此處替換為您實際部署的 GAS Web App URL
    /// 格式：https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec
    static let gasWebAppURL = "https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec"

    // MARK: - Keychain Configuration

    /// Keychain 服務名稱（用於儲存 Google 登入憑證）
    static let keychainService = "com.auditor.app.google-signin"

    /// Keychain 帳號鍵（用於儲存使用者 Email）
    static let keychainAccountKey = "userEmail"

    /// Keychain Token 鍵（用於儲存 OAuth Token）
    static let keychainTokenKey = "authToken"

    // MARK: - App Information

    /// 應用程式顯示名稱
    static let appName = "電腦軟體版本稽核紀錄"

    /// 應用程式版本
    static let appVersion = "1.0.0"

    /// 品牌顏色（深紫色，與 GAS Web App 一致）
    static let brandColorHex = "#673ab7"

    // MARK: - Error Messages

    struct ErrorMessages {
        static let invalidDomain = "登入失敗，請確保您使用的是公司的 Workspace 帳號。"
        static let signInFailed = "Google 登入失敗，請稍後再試。"
        static let networkError = "網路連線錯誤，請檢查您的網路設定。"
        static let webAppLoadFailed = "無法載入應用程式，請檢查網路連線。"
        static let configurationError = "應用程式配置錯誤，請聯絡系統管理員。"
    }

    // MARK: - Validation

    /// 驗證 Email 網域是否在允許列表中
    /// - Parameter email: 使用者的 Email 地址
    /// - Returns: 如果網域被允許則返回 true
    static func isEmailDomainAllowed(_ email: String) -> Bool {
        guard let domain = email.split(separator: "@").last else {
            return false
        }
        return allowedDomains.contains(String(domain))
    }

    /// 檢查是否已正確配置必要的常數
    /// - Returns: 如果配置完整則返回 true
    static func isConfigured() -> Bool {
        return !googleClientID.contains("YOUR_") &&
               !gasWebAppURL.contains("YOUR_") &&
               !allowedDomains.isEmpty
    }
}
