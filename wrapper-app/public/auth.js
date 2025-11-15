/**
 * Google Sign-In 身份驗證邏輯
 *
 * 此檔案負責：
 * 1. 初始化 Google Identity Services (GSI)
 * 2. 處理使用者登入
 * 3. 驗證 Email 網域
 * 4. 管理登入狀態 (Session Storage)
 */

// ============================================================
// 工具函式
// ============================================================

/**
 * 除錯日誌輸出
 * @param {string} message - 日誌訊息
 * @param {*} data - 額外的資料
 */
function debugLog(message, data = null) {
  if (CONFIG.DEBUG_MODE) {
    console.log(`[AUTH] ${message}`, data || '');
  }
}

/**
 * 顯示錯誤訊息
 * @param {string} message - 錯誤訊息
 */
function showError(message) {
  const errorElement = document.getElementById('error-message');
  const errorText = document.getElementById('error-text');

  errorText.textContent = message;
  errorElement.classList.add('show');

  // 隱藏載入中狀態
  hideLoading();

  debugLog('顯示錯誤訊息', message);
}

/**
 * 隱藏錯誤訊息
 */
function hideError() {
  const errorElement = document.getElementById('error-message');
  errorElement.classList.remove('show');
}

/**
 * 顯示載入中狀態
 */
function showLoading() {
  const loadingElement = document.getElementById('loading');
  loadingElement.classList.add('show');
  hideError();
}

/**
 * 隱藏載入中狀態
 */
function hideLoading() {
  const loadingElement = document.getElementById('loading');
  loadingElement.classList.remove('show');
}

/**
 * 從 Email 提取網域名稱
 * @param {string} email - Email 地址
 * @returns {string} - 網域名稱 (例如: "company.com")
 */
function extractDomain(email) {
  if (!email || typeof email !== 'string') {
    return '';
  }

  const parts = email.split('@');
  return parts.length === 2 ? parts[1].toLowerCase() : '';
}

/**
 * 驗證 Email 網域是否在白名單中
 * @param {string} email - Email 地址
 * @returns {boolean} - 是否允許登入
 */
function validateEmailDomain(email) {
  const domain = extractDomain(email);

  if (!domain) {
    debugLog('無法提取網域', email);
    return false;
  }

  const isAllowed = CONFIG.ALLOWED_DOMAINS.some(
    allowedDomain => domain === allowedDomain.toLowerCase()
  );

  debugLog('網域驗證結果', {
    email: email,
    domain: domain,
    allowed: isAllowed,
    allowedDomains: CONFIG.ALLOWED_DOMAINS
  });

  return isAllowed;
}

// ============================================================
// Session 管理
// ============================================================

/**
 * 儲存使用者 Session
 * @param {object} userData - 使用者資料
 */
function saveSession(userData) {
  try {
    const sessionData = {
      email: userData.email,
      name: userData.name,
      picture: userData.picture,
      timestamp: Date.now()
    };

    sessionStorage.setItem(CONFIG.SESSION_KEY, JSON.stringify(sessionData));
    debugLog('Session 已儲存', sessionData);
  } catch (error) {
    console.error('儲存 Session 失敗:', error);
  }
}

/**
 * 讀取使用者 Session
 * @returns {object|null} - 使用者資料或 null
 */
function loadSession() {
  try {
    const sessionData = sessionStorage.getItem(CONFIG.SESSION_KEY);

    if (!sessionData) {
      debugLog('無 Session 資料');
      return null;
    }

    const userData = JSON.parse(sessionData);
    const sessionAge = Date.now() - userData.timestamp;
    const maxAge = 24 * 60 * 60 * 1000; // 24 小時

    if (sessionAge > maxAge) {
      debugLog('Session 已過期', { age: sessionAge, maxAge: maxAge });
      clearSession();
      return null;
    }

    debugLog('Session 已載入', userData);
    return userData;
  } catch (error) {
    console.error('讀取 Session 失敗:', error);
    return null;
  }
}

/**
 * 清除使用者 Session
 */
function clearSession() {
  sessionStorage.removeItem(CONFIG.SESSION_KEY);
  debugLog('Session 已清除');
}

// ============================================================
// Google Sign-In 回調處理
// ============================================================

/**
 * 處理 Google Sign-In 回調
 * @param {object} response - Google 回傳的憑證回應
 */
function handleCredentialResponse(response) {
  debugLog('收到 Google 登入回應');

  showLoading();

  try {
    // 解析 JWT Token (Google ID Token)
    const credential = response.credential;
    const payload = parseJwt(credential);

    debugLog('Token Payload', payload);

    const userData = {
      email: payload.email,
      name: payload.name,
      picture: payload.picture,
      emailVerified: payload.email_verified
    };

    // 驗證 Email 是否已驗證
    if (!userData.emailVerified) {
      showError('您的 Google 帳號 Email 尚未驗證，請先完成驗證。');
      return;
    }

    // 驗證 Email 網域
    if (!validateEmailDomain(userData.email)) {
      const allowedDomainsText = CONFIG.ALLOWED_DOMAINS
        .map(domain => '@' + domain)
        .join(', ');

      showError(
        `登入失敗：您使用的帳號 (${userData.email}) 不在允許的網域內。\n\n` +
        `請使用以下網域的 Google Workspace 帳號登入：${allowedDomainsText}`
      );
      return;
    }

    // 驗證通過，儲存 Session
    saveSession(userData);

    debugLog('驗證通過，準備重新導向');

    // 導向應用程式主頁
    window.location.href = 'app.html';

  } catch (error) {
    console.error('處理登入回應時發生錯誤:', error);
    showError('登入過程中發生錯誤，請稍後再試。');
  }
}

/**
 * 解析 JWT Token
 * @param {string} token - JWT Token
 * @returns {object} - Token Payload
 */
function parseJwt(token) {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );

    return JSON.parse(jsonPayload);
  } catch (error) {
    console.error('解析 JWT Token 失敗:', error);
    throw new Error('無法解析 Google 登入資訊');
  }
}

// ============================================================
// 初始化
// ============================================================

/**
 * 初始化頁面
 */
function initializePage() {
  debugLog('初始化登入頁面');

  // 更新頁面標題和公司名稱
  if (CONFIG.APP_NAME) {
    document.getElementById('app-title').textContent = CONFIG.APP_NAME;
    document.title = `登入 - ${CONFIG.APP_NAME}`;
  }

  if (CONFIG.COMPANY_NAME) {
    document.getElementById('company-name').textContent = CONFIG.COMPANY_NAME;
  }

  // 檢查是否已登入
  const session = loadSession();
  if (session) {
    debugLog('使用者已登入，自動重新導向', session);
    window.location.href = 'app.html';
    return;
  }

  // 初始化 Google Sign-In
  initializeGoogleSignIn();
}

/**
 * 初始化 Google Sign-In
 */
function initializeGoogleSignIn() {
  debugLog('初始化 Google Sign-In');

  // 檢查 Google Client ID 是否已設定
  if (!CONFIG.GOOGLE_CLIENT_ID || CONFIG.GOOGLE_CLIENT_ID.includes('YOUR_')) {
    showError(
      '系統設定錯誤：Google Client ID 尚未設定。\n\n' +
      '請聯繫系統管理員完成設定。'
    );
    return;
  }

  // 等待 Google Identity Services Library 載入完成
  if (typeof google === 'undefined' || !google.accounts) {
    console.error('Google Identity Services Library 尚未載入');
    setTimeout(initializeGoogleSignIn, 500);
    return;
  }

  try {
    // 初始化 Google Identity Services
    google.accounts.id.initialize({
      client_id: CONFIG.GOOGLE_CLIENT_ID,
      callback: handleCredentialResponse,
      auto_select: false,
      cancel_on_tap_outside: true
    });

    // 渲染 Google Sign-In 按鈕
    google.accounts.id.renderButton(
      document.getElementById('google-signin-button'),
      {
        theme: 'outline',
        size: 'large',
        text: 'signin_with',
        shape: 'rectangular',
        logo_alignment: 'left',
        width: 280
      }
    );

    // 提示使用者選擇帳號 (One Tap 登入)
    // 註：如果不想要 One Tap，可以註解掉下面這行
    // google.accounts.id.prompt();

    debugLog('Google Sign-In 初始化完成');

  } catch (error) {
    console.error('初始化 Google Sign-In 失敗:', error);
    showError('初始化登入系統失敗，請重新整理頁面。');
  }
}

// ============================================================
// 頁面載入完成後執行
// ============================================================

// 確保 DOM 完全載入後再執行
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializePage);
} else {
  initializePage();
}
