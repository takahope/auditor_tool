/**
 * 應用程式主頁邏輯
 *
 * 此檔案負責：
 * 1. 驗證使用者登入狀態
 * 2. 載入 GAS 應用程式 (使用 iframe)
 * 3. 顯示使用者資訊
 * 4. 處理登出功能
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
    console.log(`[APP] ${message}`, data || '');
  }
}

/**
 * 顯示錯誤訊息
 * @param {string} message - 錯誤訊息
 */
function showError(message) {
  const errorContainer = document.getElementById('error-container');
  const errorMessage = document.getElementById('error-message');
  const loadingOverlay = document.getElementById('loading-overlay');

  errorMessage.textContent = message;
  errorContainer.classList.add('show');
  loadingOverlay.classList.add('hide');

  debugLog('顯示錯誤訊息', message);
}

/**
 * 隱藏載入中覆蓋層
 */
function hideLoading() {
  const loadingOverlay = document.getElementById('loading-overlay');
  loadingOverlay.classList.add('hide');

  // 完全移除元素（在動畫完成後）
  setTimeout(() => {
    loadingOverlay.style.display = 'none';
  }, 300);
}

// ============================================================
// Session 管理
// ============================================================

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
// 使用者介面
// ============================================================

/**
 * 顯示使用者資訊
 * @param {object} userData - 使用者資料
 */
function displayUserInfo(userData) {
  const userEmailElement = document.getElementById('user-email');
  const userAvatarElement = document.getElementById('user-avatar');

  // 顯示 Email
  if (userData.email) {
    userEmailElement.textContent = userData.email;
  }

  // 顯示頭像
  if (userData.picture) {
    userAvatarElement.src = userData.picture;
    userAvatarElement.style.display = 'block';
    userAvatarElement.alt = userData.name || userData.email;

    // 設定 title 屬性（滑鼠移過時顯示）
    userAvatarElement.title = userData.name || userData.email;
  }

  debugLog('使用者資訊已顯示', userData);
}

// ============================================================
// 登出功能
// ============================================================

/**
 * 處理登出
 */
function handleLogout() {
  debugLog('使用者登出');

  // 確認是否要登出
  if (!confirm('確定要登出嗎？')) {
    return;
  }

  // 清除 Session
  clearSession();

  // 重新導向到登入頁面
  window.location.href = 'index.html';
}

// ============================================================
// 載入 GAS 應用程式
// ============================================================

/**
 * 載入 GAS 應用程式到 iframe
 */
function loadGasApp() {
  debugLog('開始載入 GAS 應用程式');

  // 檢查 GAS App URL 是否已設定
  if (!CONFIG.GAS_APP_URL || CONFIG.GAS_APP_URL.includes('YOUR_')) {
    showError(
      '系統設定錯誤：GAS 應用程式 URL 尚未設定。\n\n' +
      '請聯繫系統管理員完成設定。'
    );
    return;
  }

  const iframe = document.getElementById('gas-app-iframe');

  // 設定 iframe 載入完成事件
  iframe.addEventListener('load', function() {
    debugLog('GAS 應用程式載入完成');
    hideLoading();
  });

  // 設定 iframe 載入錯誤事件
  iframe.addEventListener('error', function() {
    console.error('載入 GAS 應用程式失敗');
    showError(
      '無法載入應用程式，可能的原因：\n\n' +
      '1. GAS 應用程式 URL 設定錯誤\n' +
      '2. 網路連線異常\n' +
      '3. GAS 應用程式未正確部署\n\n' +
      '請聯繫系統管理員。'
    );
  });

  // 設定超時檢查（30 秒）
  const loadTimeout = setTimeout(() => {
    const loadingOverlay = document.getElementById('loading-overlay');
    if (!loadingOverlay.classList.contains('hide')) {
      console.warn('GAS 應用程式載入超時');
      showError(
        '載入應用程式超時，請檢查：\n\n' +
        '1. 您的網路連線是否正常\n' +
        '2. GAS 應用程式是否正常運作\n\n' +
        '您可以嘗試重新載入頁面。'
      );
    }
  }, 30000);

  // 載入成功後清除超時檢查
  iframe.addEventListener('load', () => clearTimeout(loadTimeout), { once: true });

  // 設定 iframe src 開始載入
  iframe.src = CONFIG.GAS_APP_URL;

  debugLog('已設定 iframe src', CONFIG.GAS_APP_URL);
}

// ============================================================
// 初始化
// ============================================================

/**
 * 初始化應用程式頁面
 */
function initializeApp() {
  debugLog('初始化應用程式頁面');

  // 更新頁面標題
  if (CONFIG.APP_NAME) {
    document.getElementById('app-title').textContent = CONFIG.APP_NAME;
    document.title = CONFIG.APP_NAME;
  }

  // 檢查登入狀態
  const session = loadSession();

  if (!session) {
    debugLog('使用者未登入，重新導向到登入頁面');
    alert('您尚未登入，請先登入。');
    window.location.href = 'index.html';
    return;
  }

  // 顯示使用者資訊
  displayUserInfo(session);

  // 設定登出按鈕事件
  const logoutButton = document.getElementById('logout-button');
  logoutButton.addEventListener('click', handleLogout);

  // 載入 GAS 應用程式
  loadGasApp();
}

// ============================================================
// 頁面載入完成後執行
// ============================================================

// 確保 DOM 完全載入後再執行
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeApp);
} else {
  initializeApp();
}
