# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案概述

這是一個 Google Apps Script Web App 專案,用於建立電腦軟體版本更新稽核紀錄系統。系統允許使用者透過網頁表單回報各駐站電腦的軟體更新狀態,資料會自動記錄到 Google Sheets。

## 技術架構

- **後端**: Google Apps Script (code.js)
  - 使用 `SpreadsheetApp` 操作 Google Sheets
  - 透過 `HtmlService` 提供 Web App 介面
  - 使用 `Session.getActiveUser()` 取得使用者資訊

- **前端**: HTML + Vanilla JavaScript (Index.html)
  - 使用 `google.script.run` 進行前後端通訊
  - 響應式設計,支援桌面與移動裝置
  - 自訂進度條載入動畫

## Google Sheets 工作表結構

專案依賴三個 Google Sheets 工作表:

1. **ComputerList** (電腦清單)
   - Column A: 駐站名稱
   - Column B: 電腦產編
   - 用於動態生成表單的駐站和電腦選項

2. **SevenZipVersions** (7-Zip 版本清單)
   - Column A: 7-Zip 版本號
   - 用於提供 7-Zip 版本下拉選單

3. **Log** (記錄表)
   - 儲存所有表單提交記錄
   - 欄位: 回報時間、提交者Email、駐站、電腦產編、Windows更新、Chrome更新、防毒軟體更新、7-Zip版本、TeamViewer版本、Forticlient版本、Adobe Acrobat版本、備註

## 關鍵功能

### 後端函式 (code.js)

- `doGet(e)`: Web App 入口點,回傳 HTML 頁面
- `getSelectData()`: 從 ComputerList 讀取駐站與電腦對應資料,回傳 Map 結構
- `getSevenZipVersions()`: 從 SevenZipVersions 讀取版本清單
- `getCurrentUser()`: 取得當前登入使用者的 email 和名稱
- `processFormData(formObject)`: 處理表單提交,將資料寫入 Log 工作表
- `onOpen(e)`: 在 Google Sheet 中建立自訂選單
- `openWebAppUrl()`: 顯示 Web App URL 的對話框

### 前端邏輯 (Index.html)

- 頁面載入時同時呼叫三個後端函式載入資料:
  - `getSelectData()` → `populateGroupSelect()`
  - `getSevenZipVersions()` → `populateSevenZipVersions()`
  - `getCurrentUser()` → `displayUserInfo()`
- 使用 `_dataLoadStatus` 物件追蹤三個資料源的載入狀態
- 駐站選擇變更時,動態更新電腦產編選項
- 表單提交時手動建立 `formObject`,確保 checkbox 狀態正確傳送
- 進度條系統提供視覺回饋

## 部署說明

這是 Google Apps Script 專案,需要透過 Google Apps Script 編輯器部署:

1. 在 Google Sheets 中開啟專案
2. 前往「擴充功能」→「Apps Script」
3. 將 code.js 內容貼入 Code.gs
4. 新增 HTML 檔案命名為 Index.html,貼入 Index.html 內容
5. 點選「部署」→「新增部署」
6. 選擇類型:「網頁應用程式」
7. 設定執行身分和存取權限
8. 部署後會取得 Web App URL

## 重要注意事項

- **前後端通訊**: 使用 `google.script.run.withSuccessHandler(callback).functionName(params)` 模式
- **表單驗證**: 目前未實作嚴格的表單驗證,checkbox 和選擇欄位可為空
- **使用者識別**: 使用 `Session.getActiveUser().getEmail()` 自動記錄提交者
- **時區**: 時間戳記使用伺服器時區 (Google Apps Script 預設為 GMT)
- **X-Frame-Options**: 設定為 ALLOWALL 以支援在 Google Sites 等平台嵌入

## 程式碼風格

- 使用傳統中文註解
- 函式使用 JSDoc 風格註解
- 常數使用大寫蛇形命名 (CONSTANT_CASE)
- 一般變數使用駝峰命名 (camelCase)
