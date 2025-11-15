//
//  AuthenticationManager.swift
//  AuditorApp
//
//  電腦軟體版本更新稽核紀錄系統 - iOS 原生入口應用程式
//  Google 認證管理器
//
//  根據 PRD FR 5.1：整合 Google Sign-In for iOS SDK
//  根據 PRD FR 5.1.4：驗證 Email 網域
//

import Foundation
import GoogleSignIn
import Combine

/// 使用者認證狀態
enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated(email: String)
    case failed(error: String)
}

/// Google 認證管理器
/// 使用 ObservableObject 以便與 SwiftUI 整合
class AuthenticationManager: ObservableObject {

    static let shared = AuthenticationManager()

    // MARK: - Published Properties

    /// 當前認證狀態
    @Published var authState: AuthenticationState = .unauthenticated

    /// 當前登入使用者的 Email
    @Published var userEmail: String?

    /// 當前登入使用者的名稱
    @Published var userName: String?

    /// 當前登入使用者的頭像 URL
    @Published var userPhotoURL: URL?

    // MARK: - Private Properties

    private let keychainHelper = KeychainHelper.shared

    private init() {
        // 嘗試恢復之前的登入狀態
        restoreSignIn()
    }

    // MARK: - Authentication Methods

    /// 使用 Google Sign-In 登入
    /// 根據 PRD 使用者流程步驟 5-7
    /// - Parameter presentingViewController: 用於呈現登入介面的 ViewController
    func signIn(presenting viewController: UIViewController? = nil) {
        authState = .authenticating

        // 檢查配置是否正確
        guard AppConstants.isConfigured() else {
            authState = .failed(error: AppConstants.ErrorMessages.configurationError)
            return
        }

        // 配置 Google Sign-In
        guard let clientID = GIDConfiguration(clientID: AppConstants.googleClientID) else {
            authState = .failed(error: AppConstants.ErrorMessages.configurationError)
            return
        }

        GIDSignIn.sharedInstance.configuration = clientID

        // 取得頂層 ViewController（如果未提供）
        guard let presentingVC = viewController ?? topViewController() else {
            authState = .failed(error: "無法取得 ViewController")
            return
        }

        // 執行 Google Sign-In
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.handleSignInError(error)
                return
            }

            guard let user = result?.user,
                  let email = user.profile?.email else {
                self.authState = .failed(error: AppConstants.ErrorMessages.signInFailed)
                return
            }

            // 根據 PRD FR 5.1.4：驗證 Email 網域
            if !AppConstants.isEmailDomainAllowed(email) {
                // 網域不符合，登出並顯示錯誤
                self.signOut()
                self.authState = .failed(error: AppConstants.ErrorMessages.invalidDomain)
                return
            }

            // 網域驗證通過，儲存使用者資訊
            self.handleSuccessfulSignIn(user: user, email: email)
        }
    }

    /// 登出
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        keychainHelper.clearAll()

        userEmail = nil
        userName = nil
        userPhotoURL = nil
        authState = .unauthenticated
    }

    /// 恢復之前的登入狀態
    /// 根據 PRD 使用者流程步驟 3-4
    func restoreSignIn() {
        // 檢查 Keychain 中是否有儲存的憑證
        guard let savedEmail = try? keychainHelper.retrieve(AppConstants.keychainAccountKey) else {
            authState = .unauthenticated
            return
        }

        // 嘗試恢復 Google Sign-In 狀態
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }

            if let error = error {
                print("恢復登入失敗: \(error.localizedDescription)")
                self.keychainHelper.clearAll()
                self.authState = .unauthenticated
                return
            }

            guard let user = user,
                  let email = user.profile?.email else {
                self.keychainHelper.clearAll()
                self.authState = .unauthenticated
                return
            }

            // 再次驗證網域（防止配置變更）
            if !AppConstants.isEmailDomainAllowed(email) {
                self.signOut()
                self.authState = .failed(error: AppConstants.ErrorMessages.invalidDomain)
                return
            }

            // 恢復成功
            self.handleSuccessfulSignIn(user: user, email: email)
        }
    }

    /// 刷新 Access Token
    func refreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            completion(false)
            return
        }

        currentUser.refreshTokensIfNeeded { [weak self] user, error in
            if let error = error {
                print("Token 刷新失敗: \(error.localizedDescription)")
                completion(false)
                return
            }

            // Token 刷新成功，更新 Keychain
            if let token = user?.idToken?.tokenString {
                try? self?.keychainHelper.save(token, forKey: AppConstants.keychainTokenKey)
            }

            completion(true)
        }
    }

    // MARK: - Private Helper Methods

    /// 處理成功登入
    private func handleSuccessfulSignIn(user: GIDGoogleUser, email: String) {
        // 儲存使用者資訊
        self.userEmail = email
        self.userName = user.profile?.name
        self.userPhotoURL = user.profile?.imageURL(withDimension: 200)

        // 根據 PRD NFR 6.4：將憑證儲存到 Keychain
        do {
            try keychainHelper.save(email, forKey: AppConstants.keychainAccountKey)

            if let token = user.idToken?.tokenString {
                try keychainHelper.save(token, forKey: AppConstants.keychainTokenKey)
            }

            authState = .authenticated(email: email)

        } catch {
            print("儲存憑證失敗: \(error.localizedDescription)")
            authState = .failed(error: "儲存憑證失敗")
        }
    }

    /// 處理登入錯誤
    private func handleSignInError(_ error: Error) {
        let nsError = error as NSError

        // 檢查是否為使用者取消登入
        if nsError.code == GIDSignInError.canceled.rawValue {
            authState = .unauthenticated
            return
        }

        // 其他錯誤
        print("Google Sign-In 錯誤: \(error.localizedDescription)")
        authState = .failed(error: AppConstants.ErrorMessages.signInFailed)
    }

    /// 取得頂層 ViewController
    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return nil
        }

        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }

        return topVC
    }

    // MARK: - Computed Properties

    /// 是否已認證
    var isAuthenticated: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }

    /// 是否正在認證中
    var isAuthenticating: Bool {
        if case .authenticating = authState {
            return true
        }
        return false
    }
}
