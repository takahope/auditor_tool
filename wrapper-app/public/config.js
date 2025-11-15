/**
 * Wrapper App 設定檔
 *
 * 這個檔案包含了 Wrapper App 的核心設定，包括：
 * - Google OAuth Client ID
 * - 允許的 Email 網域白名單
 * - GAS Web App URL
 */

const CONFIG = {
  /**
   * Google OAuth 2.0 Client ID
   *
   * 請前往 Google Cloud Console (https://console.cloud.google.com) 建立：
   * 1. 選擇或建立專案
   * 2. 啟用 "Google Identity Services" API
   * 3. 建立 OAuth 2.0 憑證
   * 4. 設定授權的 JavaScript 來源 (例如: https://app.your-company.com)
   * 5. 將 Client ID 貼到下方
   */
  GOOGLE_CLIENT_ID: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',

  /**
   * 允許登入的 Email 網域白名單
   *
   * 只有這些網域的 Google 帳號才能登入使用此應用程式。
   * 例如：['your-company.com', 'subsidiary.com']
   *
   * 注意：請勿包含 @ 符號，只需填寫網域名稱
   */
  ALLOWED_DOMAINS: ['your-company.com'],

  /**
   * GAS Web App 的部署 URL
   *
   * 這是您的 Google Apps Script Web App 的 .../exec 網址。
   * 格式類似：https://script.google.com/macros/s/AKfycby.../exec
   *
   * 如何取得：
   * 1. 在 Google Apps Script 編輯器中點選「部署」→「管理部署」
   * 2. 複製「網頁應用程式」的網址
   */
  GAS_APP_URL: 'https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec',

  /**
   * 應用程式名稱（顯示在登入頁面）
   */
  APP_NAME: '電腦軟體版本更新稽核紀錄系統',

  /**
   * 公司或組織名稱（顯示在登入頁面）
   */
  COMPANY_NAME: '您的公司名稱',

  /**
   * Session Storage Key
   * （用於儲存登入狀態，一般不需要修改）
   */
  SESSION_KEY: 'auditor_tool_auth_session',

  /**
   * 是否啟用除錯模式
   * 設為 true 時會在 console 輸出詳細的除錯訊息
   */
  DEBUG_MODE: false
};

// 凍結設定物件，防止意外修改
Object.freeze(CONFIG);
