package com.company.auditor

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.company.auditor.databinding.ActivityLoginBinding
import kotlinx.coroutines.launch

/**
 * LoginActivity - 登入畫面
 *
 * 實現使用者流程步驟 4-7：
 * - 顯示原生的登入畫面，包含「使用 Google 帳號登入」按鈕
 * - 觸發 Google Sign-In SDK 流程
 * - 檢查 Email 的網域是否正確
 * - 顯示錯誤或成功導航
 */
class LoginActivity : AppCompatActivity() {

    private lateinit var binding: ActivityLoginBinding
    private lateinit var authManager: AuthManager

    // Google Sign-In Activity Result Launcher
    private val signInLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        lifecycleScope.launch {
            handleSignInResult(result.data)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)

        authManager = AuthManager(this)

        setupUI()
    }

    /**
     * 設定 UI 元件
     */
    private fun setupUI() {
        binding.btnGoogleSignIn.setOnClickListener {
            startGoogleSignIn()
        }
    }

    /**
     * 啟動 Google Sign-In 流程
     *
     * FR 5.1.1: 使用 Google Sign-In for Android SDK
     */
    private fun startGoogleSignIn() {
        showLoading(true)

        val signInIntent = authManager.getSignInIntent()
        signInLauncher.launch(signInIntent)
    }

    /**
     * 處理 Sign-In 結果
     *
     * FR 5.1.2: 獲取登入使用者的 Email 地址
     * FR 5.1.4: 網域驗證和錯誤提示
     */
    private suspend fun handleSignInResult(data: Intent?) {
        val (success, message) = authManager.handleSignInResult(data)

        showLoading(false)

        if (success) {
            // 登入成功，導航到 WebView
            navigateToWebView()
        } else {
            // 登入失敗，顯示錯誤訊息
            showErrorDialog(message)
        }
    }

    /**
     * 顯示錯誤對話框
     *
     * FR 5.1.4: 使用原生 UI (AlertDialog) 顯示清晰的錯誤訊息
     */
    private fun showErrorDialog(message: String) {
        val (title, errorMessage) = when {
            message.startsWith("domain_error:") -> {
                val domains = message.substringAfter("domain_error:")
                Pair(
                    getString(R.string.error_wrong_domain),
                    getString(R.string.error_wrong_domain_message, domains)
                )
            }
            else -> {
                Pair(
                    getString(R.string.error_sign_in_failed),
                    message
                )
            }
        }

        AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(errorMessage)
            .setPositiveButton(R.string.ok) { dialog, _ ->
                dialog.dismiss()
            }
            .show()
    }

    /**
     * 顯示或隱藏載入進度
     */
    private fun showLoading(isLoading: Boolean) {
        binding.progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
        binding.btnGoogleSignIn.isEnabled = !isLoading
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
