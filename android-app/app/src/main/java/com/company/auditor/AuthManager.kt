package com.company.auditor

import android.content.Context
import android.content.Intent
import androidx.activity.result.ActivityResultLauncher
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import kotlinx.coroutines.tasks.await

/**
 * AuthManager - 管理 Google Sign-In 和網域驗證
 *
 * 實現 FR 5.1.1 到 FR 5.1.5 的所有登入與驗證需求
 */
class AuthManager(private val context: Context) {

    companion object {
        // 允許的網域列表 - 可在 BuildConfig 中配置
        // FR 5.1.3: 應用程式必須配置一個「允許的網域」列表
        private val ALLOWED_DOMAINS = BuildConfig.ALLOWED_DOMAINS.toList()
    }

    private val securePreferences = SecurePreferences.getInstance(context)
    private val googleSignInClient: GoogleSignInClient

    init {
        // 配置 Google Sign-In
        // FR 5.1.1: 應用程式必須整合「Google Sign-In for Android SDK」
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestId()
            .requestIdToken(context.getString(R.string.default_web_client_id))
            .build()

        googleSignInClient = GoogleSignIn.getClient(context, gso)
    }

    /**
     * 獲取 Google Sign-In Intent
     */
    fun getSignInIntent(): Intent {
        return googleSignInClient.signInIntent
    }

    /**
     * 處理 Sign-In 結果
     *
     * @return Pair<Boolean, String> - (成功與否, 錯誤訊息或使用者 Email)
     */
    suspend fun handleSignInResult(data: Intent?): Pair<Boolean, String> {
        try {
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            val account = task.await()

            // FR 5.1.2: 應用程式必須能獲取登入使用者的 Email 地址
            val email = account.email ?: return Pair(false, "無法獲取 Email")

            // FR 5.1.4: 驗證網域
            val isValidDomain = validateEmailDomain(email)

            if (!isValidDomain) {
                // 網域驗證失敗，登出
                signOut()
                return Pair(false, "domain_error:${ALLOWED_DOMAINS.joinToString(", ")}")
            }

            // FR 5.1.5: 登入憑證必須被安全地儲存
            saveUserCredentials(account)

            return Pair(true, email)

        } catch (e: ApiException) {
            return Pair(false, "登入失敗: ${e.statusCode}")
        } catch (e: Exception) {
            return Pair(false, "登入失敗: ${e.message}")
        }
    }

    /**
     * 驗證 Email 網域是否在允許列表中
     *
     * FR 5.1.3 & FR 5.1.4: 網域驗證
     */
    private fun validateEmailDomain(email: String): Boolean {
        val domain = email.substringAfter("@", "")
        return ALLOWED_DOMAINS.contains(domain)
    }

    /**
     * 儲存使用者憑證到加密的 SharedPreferences
     */
    private fun saveUserCredentials(account: GoogleSignInAccount) {
        securePreferences.saveUserCredentials(
            email = account.email ?: "",
            userId = account.id ?: "",
            idToken = account.idToken ?: ""
        )
    }

    /**
     * 檢查是否已有有效的登入狀態
     */
    fun isUserLoggedIn(): Boolean {
        // 檢查 SharedPreferences
        if (!securePreferences.isLoggedIn()) {
            return false
        }

        // 檢查 Google Sign-In 狀態
        val account = GoogleSignIn.getLastSignedInAccount(context)
        if (account == null) {
            // 如果 Google Sign-In 狀態不存在，清除本地憑證
            securePreferences.clearUserCredentials()
            return false
        }

        // 再次驗證網域
        val email = account.email ?: return false
        return validateEmailDomain(email)
    }

    /**
     * 獲取當前使用者 Email
     */
    fun getCurrentUserEmail(): String? {
        return securePreferences.getUserEmail()
    }

    /**
     * 登出
     */
    suspend fun signOut() {
        try {
            googleSignInClient.signOut().await()
        } catch (e: Exception) {
            // 忽略登出錯誤
        } finally {
            securePreferences.clearUserCredentials()
        }
    }

    /**
     * 完全撤銷存取權限
     */
    suspend fun revokeAccess() {
        try {
            googleSignInClient.revokeAccess().await()
        } catch (e: Exception) {
            // 忽略撤銷錯誤
        } finally {
            securePreferences.clearAll()
        }
    }
}
