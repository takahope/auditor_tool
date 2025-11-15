//
//  ContentView.swift
//  AuditorApp
//
//  電腦軟體版本更新稽核紀錄系統 - iOS 原生入口應用程式
//  主要內容視圖
//
//  根據 PRD 使用者流程：根據認證狀態顯示登入畫面或 Web App
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var authManager = AuthenticationManager.shared
    @State private var showSplashScreen = true

    var body: some View {
        ZStack {
            // 主要內容
            Group {
                if authManager.isAuthenticated {
                    // 根據 PRD 步驟 8-9：已認證，顯示 Web App
                    WebAppView()
                        .transition(.opacity)
                } else {
                    // 根據 PRD 步驟 4-7：未認證，顯示登入畫面
                    LoginView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)

            // 啟動畫面（Launch Screen）
            if showSplashScreen {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // 根據 PRD NFR 6.3：應用程式啟動必須快速
            // 顯示 Splash Screen 1.5 秒後隱藏
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showSplashScreen = false
                }
            }
        }
    }
}

// MARK: - Splash Screen View

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            // 品牌漸層背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "673ab7"),
                    Color(hex: "512da8")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // App Logo
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)

                // App 名稱
                VStack(spacing: 10) {
                    Text(AppConstants.appName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("iOS 版本")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }

                // 載入動畫
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
                    .padding(.top, 20)
            }
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
