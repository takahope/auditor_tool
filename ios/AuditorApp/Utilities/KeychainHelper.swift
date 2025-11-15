//
//  KeychainHelper.swift
//  AuditorApp
//
//  電腦軟體版本更新稽核紀錄系統 - iOS 原生入口應用程式
//  Keychain 安全儲存輔助類
//
//  根據 PRD NFR 6.4：必須使用 iOS 鑰匙圈 (Keychain) 儲存 OAuth Token
//

import Foundation
import Security

/// Keychain 操作錯誤類型
enum KeychainError: Error {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unexpectedStatus(OSStatus)
}

/// Keychain 安全儲存輔助類
/// 提供簡單的介面來儲存、讀取和刪除敏感資料
class KeychainHelper {

    static let shared = KeychainHelper()

    private init() {}

    // MARK: - Save to Keychain

    /// 儲存字串到 Keychain
    /// - Parameters:
    ///   - value: 要儲存的字串值
    ///   - key: 儲存的鍵名
    ///   - service: Keychain 服務名稱（預設使用 AppConstants）
    /// - Throws: KeychainError
    func save(_ value: String, forKey key: String, service: String = AppConstants.keychainService) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        try save(data, forKey: key, service: service)
    }

    /// 儲存 Data 到 Keychain
    /// - Parameters:
    ///   - data: 要儲存的資料
    ///   - key: 儲存的鍵名
    ///   - service: Keychain 服務名稱
    /// - Throws: KeychainError
    func save(_ data: Data, forKey key: String, service: String = AppConstants.keychainService) throws {
        // 先嘗試刪除現有項目（如果存在）
        try? delete(key, service: service)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            }
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Retrieve from Keychain

    /// 從 Keychain 讀取字串
    /// - Parameters:
    ///   - key: 要讀取的鍵名
    ///   - service: Keychain 服務名稱
    /// - Returns: 儲存的字串值
    /// - Throws: KeychainError
    func retrieve(_ key: String, service: String = AppConstants.keychainService) throws -> String {
        let data = try retrieveData(key, service: service)

        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return string
    }

    /// 從 Keychain 讀取 Data
    /// - Parameters:
    ///   - key: 要讀取的鍵名
    ///   - service: Keychain 服務名稱
    /// - Returns: 儲存的資料
    /// - Throws: KeychainError
    func retrieveData(_ key: String, service: String = AppConstants.keychainService) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    // MARK: - Delete from Keychain

    /// 從 Keychain 刪除項目
    /// - Parameters:
    ///   - key: 要刪除的鍵名
    ///   - service: Keychain 服務名稱
    /// - Throws: KeychainError
    func delete(_ key: String, service: String = AppConstants.keychainService) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Convenience Methods

    /// 清除所有 Keychain 項目（用於登出）
    func clearAll(service: String = AppConstants.keychainService) {
        try? delete(AppConstants.keychainAccountKey, service: service)
        try? delete(AppConstants.keychainTokenKey, service: service)
    }

    /// 檢查是否存在指定的 Keychain 項目
    /// - Parameters:
    ///   - key: 要檢查的鍵名
    ///   - service: Keychain 服務名稱
    /// - Returns: 如果項目存在則返回 true
    func exists(_ key: String, service: String = AppConstants.keychainService) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
