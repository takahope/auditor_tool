package com.company.auditor

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * SecurePreferences - 使用 Android Keystore 加密的 SharedPreferences
 *
 * 符合 NFR 6.4: 必須使用 Android Keystore 加密儲存在 SharedPreferences 中的 OAuth Token
 */
class SecurePreferences(context: Context) {

    companion object {
        private const val PREFS_FILE_NAME = "secure_prefs"
        private const val KEY_USER_EMAIL = "user_email"
        private const val KEY_USER_ID = "user_id"
        private const val KEY_ID_TOKEN = "id_token"
        private const val KEY_IS_LOGGED_IN = "is_logged_in"

        @Volatile
        private var instance: SecurePreferences? = null

        fun getInstance(context: Context): SecurePreferences {
            return instance ?: synchronized(this) {
                instance ?: SecurePreferences(context.applicationContext).also {
                    instance = it
                }
            }
        }
    }

    private val sharedPreferences: SharedPreferences

    init {
        // 建立或獲取 MasterKey (使用 Android Keystore)
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()

        // 建立加密的 SharedPreferences
        sharedPreferences = EncryptedSharedPreferences.create(
            context,
            PREFS_FILE_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    /**
     * 儲存使用者登入資訊
     */
    fun saveUserCredentials(email: String, userId: String, idToken: String) {
        sharedPreferences.edit().apply {
            putString(KEY_USER_EMAIL, email)
            putString(KEY_USER_ID, userId)
            putString(KEY_ID_TOKEN, idToken)
            putBoolean(KEY_IS_LOGGED_IN, true)
            apply()
        }
    }

    /**
     * 獲取使用者 Email
     */
    fun getUserEmail(): String? {
        return sharedPreferences.getString(KEY_USER_EMAIL, null)
    }

    /**
     * 獲取使用者 ID
     */
    fun getUserId(): String? {
        return sharedPreferences.getString(KEY_USER_ID, null)
    }

    /**
     * 獲取 ID Token
     */
    fun getIdToken(): String? {
        return sharedPreferences.getString(KEY_ID_TOKEN, null)
    }

    /**
     * 檢查使用者是否已登入
     */
    fun isLoggedIn(): Boolean {
        return sharedPreferences.getBoolean(KEY_IS_LOGGED_IN, false)
    }

    /**
     * 清除所有使用者資訊 (登出)
     */
    fun clearUserCredentials() {
        sharedPreferences.edit().apply {
            remove(KEY_USER_EMAIL)
            remove(KEY_USER_ID)
            remove(KEY_ID_TOKEN)
            putBoolean(KEY_IS_LOGGED_IN, false)
            apply()
        }
    }

    /**
     * 完全清除所有資料
     */
    fun clearAll() {
        sharedPreferences.edit().clear().apply()
    }
}
