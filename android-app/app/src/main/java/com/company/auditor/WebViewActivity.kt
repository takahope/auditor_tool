package com.company.auditor

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.webkit.CookieManager
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.company.auditor.databinding.ActivityWebviewBinding
import kotlinx.coroutines.launch

/**
 * WebViewActivity - 在 WebView 中載入 GAS 應用程式
 *
 * 實現使用者流程步驟 8-10：
 * - 在 WebView 中載入 GAS 應用程式
 * - 與 Google Sign-In 共享認證狀態
 * - 提供原生的下拉刷新和工具列功能
 *
 * 實現 FR 5.2.1 到 FR 5.2.5 的所有 WebView 相關需求
 */
class WebViewActivity : AppCompatActivity() {

    private lateinit var binding: ActivityWebviewBinding
    private lateinit var authManager: AuthManager

    private val gasWebAppUrl = BuildConfig.GAS_WEB_APP_URL

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityWebviewBinding.inflate(layoutInflater)
        setContentView(binding.root)

        authManager = AuthManager(this)

        setupToolbar()
        setupWebView()
        setupSwipeRefresh()

        loadGasWebApp()
    }

    /**
     * 設定工具列
     *
     * FR 5.2.5: 提供原生的頂部應用欄，包含「返回」、「首頁」或「登出」按鈕
     */
    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
        supportActionBar?.setDisplayShowTitleEnabled(true)
    }

    /**
     * 設定 WebView
     *
     * FR 5.2.1 & FR 5.2.2: WebView 設定與認證共享
     * FR 5.2.3: WebView 佔滿螢幕空間
     */
    @SuppressLint("SetJavaScriptEnabled")
    private fun setupWebView() {
        binding.webView.apply {
            settings.apply {
                // 啟用 JavaScript (必須，因為 GAS 應用程式使用 JavaScript)
                javaScriptEnabled = true

                // 啟用 DOM Storage
                domStorageEnabled = true

                // 啟用資料庫
                databaseEnabled = true

                // 啟用快取
                cacheMode = android.webkit.WebSettings.LOAD_DEFAULT

                // 支援縮放
                setSupportZoom(true)
                builtInZoomControls = true
                displayZoomControls = false

                // 自適應螢幕
                useWideViewPort = true
                loadWithOverviewMode = true
            }

            // 設定 WebViewClient
            webViewClient = GasWebViewClient()

            // 設定 WebChromeClient (用於進度條)
            webChromeClient = GasWebChromeClient()
        }

        // 啟用 Cookie（與 Google Sign-In 共享認證狀態）
        // FR 5.2.2: WebView 必須設定為與 Google Sign-In SDK 共享認證狀態
        CookieManager.getInstance().apply {
            setAcceptCookie(true)
            setAcceptThirdPartyCookies(binding.webView, true)
        }
    }

    /**
     * 設定下拉刷新
     *
     * FR 5.2.4: 提供原生的「下拉刷新」功能
     */
    private fun setupSwipeRefresh() {
        binding.swipeRefreshLayout.setOnRefreshListener {
            binding.webView.reload()
        }
    }

    /**
     * 載入 GAS Web App
     *
     * FR 5.2.1: 成功驗證後，應用程式必須在 WebView 中載入 GAS 的 .../exec 網址
     */
    private fun loadGasWebApp() {
        showError(false)
        binding.webView.loadUrl(gasWebAppUrl)
    }

    /**
     * 自訂 WebViewClient
     */
    private inner class GasWebViewClient : WebViewClient() {

        override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
            super.onPageStarted(view, url, favicon)
            showError(false)
        }

        override fun onPageFinished(view: WebView?, url: String?) {
            super.onPageFinished(view, url)
            binding.swipeRefreshLayout.isRefreshing = false
        }

        override fun onReceivedError(
            view: WebView?,
            request: WebResourceRequest?,
            error: WebResourceError?
        ) {
            super.onReceivedError(view, request, error)

            // 只在主頁面載入失敗時顯示錯誤
            if (request?.isForMainFrame == true) {
                showError(true)
                binding.swipeRefreshLayout.isRefreshing = false
            }
        }

        override fun shouldOverrideUrlLoading(
            view: WebView?,
            request: WebResourceRequest?
        ): Boolean {
            // 允許在 WebView 內部導航
            return false
        }
    }

    /**
     * 自訂 WebChromeClient (用於進度條)
     */
    private inner class GasWebChromeClient : WebChromeClient() {
        override fun onProgressChanged(view: WebView?, newProgress: Int) {
            super.onProgressChanged(view, newProgress)

            binding.progressBar.apply {
                if (newProgress < 100) {
                    visibility = View.VISIBLE
                    progress = newProgress
                } else {
                    visibility = View.GONE
                }
            }
        }
    }

    /**
     * 顯示或隱藏錯誤視圖
     */
    private fun showError(show: Boolean) {
        binding.errorView.visibility = if (show) View.VISIBLE else View.GONE
        binding.swipeRefreshLayout.visibility = if (show) View.GONE else View.VISIBLE

        if (show) {
            binding.btnRetry.setOnClickListener {
                loadGasWebApp()
            }
        }
    }

    /**
     * 建立選項選單
     */
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_webview, menu)
        return true
    }

    /**
     * 處理選項選單項目點擊
     *
     * FR 5.2.5: 提供「返回」、「首頁」或「登出」按鈕
     */
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_refresh -> {
                binding.webView.reload()
                true
            }
            R.id.action_home -> {
                loadGasWebApp()
                true
            }
            R.id.action_logout -> {
                showLogoutConfirmation()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    /**
     * 顯示登出確認對話框
     */
    private fun showLogoutConfirmation() {
        AlertDialog.Builder(this)
            .setTitle(R.string.action_logout)
            .setMessage("確定要登出嗎？")
            .setPositiveButton(R.string.ok) { _, _ ->
                performLogout()
            }
            .setNegativeButton(R.string.cancel, null)
            .show()
    }

    /**
     * 執行登出
     */
    private fun performLogout() {
        lifecycleScope.launch {
            // 清除 WebView 快取和 Cookie
            binding.webView.clearCache(true)
            binding.webView.clearHistory()
            CookieManager.getInstance().removeAllCookies(null)

            // 登出 Google Sign-In
            authManager.signOut()

            // 返回登入畫面
            val intent = Intent(this@WebViewActivity, LoginActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            startActivity(intent)
            finish()
        }
    }

    /**
     * 處理返回按鈕
     */
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (binding.webView.canGoBack()) {
            binding.webView.goBack()
        } else {
            super.onBackPressed()
        }
    }
}
