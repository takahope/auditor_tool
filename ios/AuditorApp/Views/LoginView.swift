//
//  LoginView.swift
//  AuditorApp
//
//  電腦軟體版本更新稽核紀錄系統 - iOS 原生入口應用程式
//  登入視圖
//
//  根據 PRD 使用者流程步驟 4-5：顯示原生登入畫面
//

import SwiftUI

struct LoginView: View {

    @ObservedObject var authManager = AuthenticationManager.shared

    // MARK: - Body

    var body: some View {
        ZStack {
            // 背景漸層（與 GAS Web App 風格一致）
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "673ab7"),
                    Color(hex: "512da8")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // 應用程式 Logo 和標題
                VStack(spacing: 20) {
                    // Logo 圖示（可以替換為實際的 App Icon）
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                    // 應用程式名稱
                    Text(AppConstants.appName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)

                    // 副標題
                    Text("使用公司帳號登入")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 40)

                Spacer()

                // 登入按鈕和狀態區域
                VStack(spacing: 20) {

                    // 錯誤訊息
                    if case .failed(let error) = authManager.authState {
                        ErrorMessageView(message: error)
                    }

                    // Google 登入按鈕
                    GoogleSignInButton {
                        authManager.signIn()
                    }
                    .disabled(authManager.isAuthenticating)
                    .opacity(authManager.isAuthenticating ? 0.6 : 1.0)

                    // 載入中指示器
                    if authManager.isAuthenticating {
                        ProgressView("登入中...")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // 底部資訊
                VStack(spacing: 8) {
                    Text("版本 \(AppConstants.appVersion)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))

                    if !AppConstants.isConfigured() {
                        Text("⚠️ 應用程式尚未配置")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Google Sign-In Button

struct GoogleSignInButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Google Logo
                Image(systemName: "g.circle.fill")
                    .font(.system(size: 24))

                Text("使用 Google 帳號登入")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(Color(hex: "512da8"))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Error Message View

struct ErrorMessageView: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
