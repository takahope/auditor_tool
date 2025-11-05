/**
 * @OnlyCurrentDoc
 * 這個腳本是為了 "電腦狀態回報表單" Web App 而設計的後端程式。
 */

// =================================================================
// 常數設定
// =================================================================
const ss = SpreadsheetApp.getActiveSpreadsheet();
const COMPUTER_LIST_SHEET_NAME = "ComputerList";
const SEVEN_ZIP_SHEET_NAME = "SevenZipVersions";
const LOG_SHEET_NAME = "Log";

// =================================================================
// 主要 Web App 服務
// =================================================================

/**
 * 當使用者透過瀏覽器訪問 Web App URL 時，執行此函式。
 * @param {object} e - 事件參數，包含 URL 查詢參數。
 * @returns {HtmlOutput} - 渲染後的 HTML 頁面。
 */
function doGet(e) {
  // 從 'Index.html' 檔案建立 HTML 輸出
  const htmlOutput = HtmlService.createHtmlOutputFromFile('Index')
    .setTitle('電腦狀態回報表單');
  
  // 設定 X-Frame-Options 以允許在 Google SITES 等環境中嵌入
  htmlOutput.setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
  
  return htmlOutput;
}

// =================================================================
// 前端呼叫的後端函式 (google.script.run)
// =================================================================

/**
 * 從 'ComputerList' 工作表讀取駐站與電腦的對應資料。
 * @returns {object} - 一個物件，key 是駐站名稱，value 是該駐站的電腦產編陣列。
 * 範例: { "總部": ["HQ-DT-001", "HQ-DT-002"], "A駐站": ["A-ST-001"] }
 */
function getSelectData() {
  try {
    const sheet = ss.getSheetByName(COMPUTER_LIST_SHEET_NAME);
    if (!sheet) {
      throw new Error(`找不到工作表: ${COMPUTER_LIST_SHEET_NAME}`);
    }

    // 從 A2 讀取到 B 欄的最後一列
    const range = sheet.getRange(2, 1, sheet.getLastRow() - 1, 2);
    const values = range.getValues();

    const dataMap = {};

    values.forEach(row => {
      const group = row[0]; // 駐站 (Column A)
      const computer = row[1]; // 電腦產編 (Column B)

      if (group && computer) { // 確保兩者都有值
        if (!dataMap[group]) {
          dataMap[group] = []; // 如果這個駐站是第一次出現，初始化一個空陣列
        }
        dataMap[group].push(computer);
      }
    });
    
    // console.log("DataMap created:", JSON.stringify(dataMap));
    return dataMap;

  } catch (e) {
    console.error(`Error in getSelectData: ${e.message}`);
    return {}; // 發生錯誤時返回空物件
  }
}

/**
 * 從 'SevenZipVersions' 工作表讀取 7-Zip 版本清單。
 * @returns {string[]} - 包含所有 7-Zip 版本的字串陣列。
 * 範例: ["24.07", "23.01", "19.00"]
 */
function getSevenZipVersions() {
  try {
    const sheet = ss.getSheetByName(SEVEN_ZIP_SHEET_NAME);
    if (!sheet) {
      throw new Error(`找不到工作表: ${SEVEN_ZIP_SHEET_NAME}`);
    }

    // 從 A2 讀取到 A 欄的最後一列
    const range = sheet.getRange(2, 1, sheet.getLastRow() - 1, 1);
    const values = range.getValues();

    // 將二維陣列 [["24.07"], ["23.01"]] 轉換為一維陣列 ["24.07", "23.01"]
    const versions = values
      .map(row => row[0])
      .filter(version => version); // 過濾掉空值

    // console.log("Versions loaded:", versions);
    return versions;

  } catch (e) {
    console.error(`Error in getSevenZipVersions: ${e.message}`);
    return []; // 發生錯誤時返回空陣列
  }
}

/**
 * 處理從前端提交的表單資料，並將其寫入 'Log' 工作表。
 * @param {object} formObject - 從前端 JavaScript 傳來的表單物件。
 * @returns {string} - 回傳給前端的成功或失敗訊息。
 */
function processFormData(formObject) {
  try {
    console.log("Received form data:", JSON.stringify(formObject));

    const logSheet = ss.getSheetByName(LOG_SHEET_NAME);
    if (!logSheet) {
      throw new Error(`找不到工作表: ${LOG_SHEET_NAME}`);
    }

    // 檢查 'Log' 工作表是否為空，如果為空則添加標題
    if (logSheet.getLastRow() === 0) {
      const headers = [
        "回報時間", "駐站", "電腦產編", 
        "Windows更新", "Chrome更新", "防毒軟體更新", 
        "7-Zip版本", "備註"
      ];
      logSheet.appendRow(headers);
    }

    // 準備要寫入的新資料列
    const newRow = [
      new Date(), // 回報時間
      formObject.group,
      formObject.computer,
      formObject.winUpdated,    // 前端傳來的 boolean
      formObject.chromeUpdated, // 前端傳來的 boolean
      formObject.antivirusUpdated, // 前端傳來的 boolean
      formObject.sevenZipVersion,
      formObject.notes
    ];

    // 將資料附加到 'Log' 工作表的最後一行
    logSheet.appendRow(newRow);

    // 回傳成功訊息
    const successMessage = `回報成功：${formObject.group} - ${formObject.computer} 的狀態已於 ${new Date().toLocaleString()} 紀錄。`;
    console.log(successMessage);
    return successMessage;

  } catch (e) {
    console.error(`Error in processFormData: ${e.message}`);
    return `提交失敗：${e.message}`;
  }
}

/**
 * 獲取當前 Web App 的部署 URL。
 * (對應您 HTML 中的 getAppUrl() 呼叫)
 * @returns {string} - Web App 的 URL。
 */
function getAppUrl() {
  return ScriptApp.getService().getUrl();
}


// =================================================================
// Google Sheet 介面輔助功能
// =================================================================

/**
 * 當開啟 Google Sheet 時，自動執行此函式，在介面上建立一個自訂選單。
 */
function onOpen(e) {
  SpreadsheetApp.getUi()
    .createMenu('表單管理')
    .addItem('開啟回報表單', 'openWebAppUrl')
    .addToUi();
}

/**
 * 在 Google Sheet 中打開一個對話框，顯示 Web App 的 URL。
 */
function openWebAppUrl() {
  const url = ScriptApp.getService().getUrl();
  if (url) {
    const html = `<p>請點擊以下連結開啟表單：</p>
                  <p><a href="${url}" target="_blank">開啟電腦狀態回報表單</a></p>
                  <p>或複製此連結：<input type="text" value="${url}" style="width: 90%;" readonly onclick="this.select();"></p>`;
    SpreadsheetApp.getUi().showModalDialog(HtmlService.createHtmlOutput(html).setWidth(400).setHeight(150), '開啟表單');
  } else {
    // 如果尚未部署，提示使用者
    SpreadsheetApp.getUi().alert('您必須先「部署」此腳本為 Web 應用程式，才能取得連結。');
  }
}