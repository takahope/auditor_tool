//
//  WebAppView.swift
//  AuditorApp
//
//  電腦軟體版本更新稽核紀錄系統 - iOS 原生入口應用程式
//  WKWebView 容器視圖
//
//  根據 PRD FR 5.2：在 WKWebView 中載入 GAS 應用程式
//

import SwiftUI
import WebKit

struct WebAppView: View {

    @ObservedObject var authManager = AuthenticationManager.shared
    @StateObject private var webViewModel = WebViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // WKWebView
                WebView(viewModel: webViewModel)
                    .ignoresSafeArea(edges: .bottom)

                // 載入指示器
                if webViewModel.isLoading {
                    LoadingOverlay()
                }

                // 錯誤訊息
                if let error = webViewModel.errorMessage {
                    ErrorOverlay(message: error) {
                        webViewModel.reload()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(Color(hex: "673ab7"))
                        Text(AppConstants.appName)
                            .font(.headline)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { webViewModel.reload() }) {
                            Label("重新載入", systemImage: "arrow.clockwise")
                        }

                        Button(action: { webViewModel.goBack() }) {
                            Label("返回", systemImage: "arrow.left")
                        }
                        .disabled(!webViewModel.canGoBack)

                        Button(action: { webViewModel.goForward() }) {
                            Label("前進", systemImage: "arrow.right")
                        }
                        .disabled(!webViewModel.canGoForward)

                        Divider()

                        Button(role: .destructive, action: {
                            authManager.signOut()
                        }) {
                            Label("登出", systemImage: "arrow.right.square")
                        }

                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            webViewModel.loadWebApp()
        }
    }
}

// MARK: - WebView (UIViewRepresentable)

struct WebView: UIViewRepresentable {

    @ObservedObject var viewModel: WebViewModel

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // 根據 PRD FR 5.2.2：配置 WKWebView 與 Google Sign-In 共享認證
        configuration.processPool = WKProcessPool()

        // 允許 JavaScript
        configuration.preferences.javaScriptEnabled = true

        // 根據 NFR 6.3：啟用快取以提升效能
        configuration.websiteDataStore = WKWebsiteDataStore.default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // 根據 NFR 6.2：支援 iPad 的 Split View
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // 視圖更新時的邏輯（如果需要）
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, WKNavigationDelegate {
        let viewModel: WebViewModel

        init(viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            viewModel.isLoading = true
            viewModel.errorMessage = nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            viewModel.isLoading = false
            viewModel.canGoBack = webView.canGoBack
            viewModel.canGoForward = webView.canGoForward
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            viewModel.isLoading = false
            viewModel.errorMessage = AppConstants.ErrorMessages.webAppLoadFailed
            print("WebView 載入失敗: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            viewModel.isLoading = false
            viewModel.errorMessage = AppConstants.ErrorMessages.webAppLoadFailed
            print("WebView 初始載入失敗: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // 可以在此處處理特殊的 URL scheme 或外部連結
            decisionHandler(.allow)
        }
    }
}

// MARK: - WebViewModel

class WebViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var canGoBack = false
    @Published var canGoForward = false

    private var webView: WKWebView?

    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    /// 載入 GAS Web App
    /// 根據 PRD FR 5.2.1：載入 GAS 的 .../exec 網址
    func loadWebApp() {
        guard let url = URL(string: AppConstants.gasWebAppURL) else {
            errorMessage = AppConstants.ErrorMessages.configurationError
            return
        }

        var request = URLRequest(url: url)

        // 設定 User-Agent 以識別來自原生應用
        request.setValue("AuditorApp-iOS/\(AppConstants.appVersion)", forHTTPHeaderField: "User-Agent")

        // 根據 PRD FR 5.2.2：設定請求以共享 Google 認證
        request.httpShouldHandleCookies = true

        loadRequest(request)
    }

    func loadRequest(_ request: URLRequest) {
        guard let webView = webView else {
            // WebView 尚未初始化，延遲載入
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loadRequest(request)
            }
            return
        }

        webView.load(request)
    }

    func reload() {
        errorMessage = nil
        webView?.reload()
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))

                Text("載入中...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(40)
            .background(Color(hex: "673ab7"))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Error Overlay

struct ErrorOverlay: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)

                Text(message)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: retryAction) {
                    Text("重試")
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "673ab7"))
                        .frame(width: 120, height: 44)
                        .background(Color.white)
                        .cornerRadius(22)
                }
            }
            .padding(40)
            .background(Color(hex: "512da8"))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Preview

struct WebAppView_Previews: PreviewProvider {
    static var previews: some View {
        WebAppView()
    }
}

// MARK: - Extension for WebView to Access WebView Instance

extension WebView {
    func onAppear(perform action: @escaping (WKWebView) -> Void) -> some View {
        self.modifier(WebViewAppearModifier(action: action, viewModel: viewModel))
    }
}

struct WebViewAppearModifier: ViewModifier {
    let action: (WKWebView) -> Void
    @ObservedObject var viewModel: WebViewModel

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { _ in
                Color.clear.onAppear {
                    // 此處可以存取 WebView 實例
                }
            }
        )
    }
}
