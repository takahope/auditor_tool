//
//  AuditorApp.swift
//  AuditorApp
//
//  電腦軟體版本更新稽核紀錄系統 - iOS 原生入口應用程式
//  應用程式入口點
//
//  根據 PRD 第 4 節：使用 SwiftUI 開發的原生 iOS 應用
//

import SwiftUI
import GoogleSignIn

@main
struct AuditorApp: App {

    // MARK: - App Delegate

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // 處理 Google Sign-In 的 URL callback
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 根據 PRD NFR 6.3：應用程式啟動必須快速
        // 在背景執行初始化任務
        DispatchQueue.global(qos: .background).async {
            self.setupGoogleSignIn()
        }

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // 處理 Google Sign-In 的 URL scheme callback
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: - Private Methods

    private func setupGoogleSignIn() {
        // Google Sign-In 配置已在 AuthenticationManager 中處理
        // 此處可添加其他全域初始化邏輯
        print("應用程式初始化完成")
    }
}
