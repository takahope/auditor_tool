package com.company.auditor

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * SplashActivity - 啟動畫面
 *
 * 實現使用者流程步驟 1-3：
 * - 顯示品牌啟動畫面
 * - 檢查 SharedPreferences 中是否有有效的 Google 登入憑證
 * - 根據登入狀態導航到相應的 Activity
 */
class SplashActivity : AppCompatActivity() {

    private lateinit var authManager: AuthManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 不需要設定 layout，因為使用 windowBackground

        authManager = AuthManager(this)

        // 啟動檢查邏輯
        lifecycleScope.launch {
            // 添加短暫延遲以顯示啟動畫面
            delay(1000)

            checkAuthenticationStatus()
        }
    }

    /**
     * 檢查身份驗證狀態並導航到相應的畫面
     */
    private fun checkAuthenticationStatus() {
        if (authManager.isUserLoggedIn()) {
            // 已登入且憑證有效，直接進入 WebView
            navigateToWebView()
        } else {
            // 未登入或憑證無效，前往登入畫面
            navigateToLogin()
        }
    }

    /**
     * 導航到登入畫面
     */
    private fun navigateToLogin() {
        val intent = Intent(this, LoginActivity::class.java)
        startActivity(intent)
        finish()
    }

    /**
     * 導航到 WebView 畫面
     */
    private fun navigateToWebView() {
        val intent = Intent(this, WebViewActivity::class.java)
        startActivity(intent)
        finish()
    }
}
