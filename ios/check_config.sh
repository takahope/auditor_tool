#!/bin/bash

# 配置檢查腳本
# 用於驗證 AuditorApp 是否已正確配置

echo "🔍 AuditorApp 配置檢查"
echo "================================"
echo ""

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 檢查計數器
ERRORS=0
WARNINGS=0

# 檢查 CocoaPods 安裝
echo "📦 檢查 CocoaPods..."
if command -v pod &> /dev/null; then
    echo -e "${GREEN}✓${NC} CocoaPods 已安裝: $(pod --version)"
else
    echo -e "${RED}✗${NC} CocoaPods 未安裝"
    echo "   請執行: sudo gem install cocoapods"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 檢查 Podfile
echo "📄 檢查 Podfile..."
if [ -f "Podfile" ]; then
    echo -e "${GREEN}✓${NC} Podfile 存在"
else
    echo -e "${RED}✗${NC} Podfile 不存在"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 檢查 GoogleService-Info.plist
echo "🔑 檢查 Google 服務配置..."
if [ -f "AuditorApp/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✓${NC} GoogleService-Info.plist 存在"

    # 檢查是否為模板檔案
    if grep -q "YOUR_CLIENT_ID" "AuditorApp/GoogleService-Info.plist"; then
        echo -e "${YELLOW}⚠${NC} GoogleService-Info.plist 似乎還是模板檔案"
        echo "   請從 Google Cloud Console 下載實際的配置檔案"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗${NC} GoogleService-Info.plist 不存在"
    echo "   請從 Google Cloud Console 下載並放置在 AuditorApp/ 目錄下"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 檢查 Constants.swift
echo "⚙️  檢查應用程式常數配置..."
if [ -f "AuditorApp/Utilities/Constants.swift" ]; then
    echo -e "${GREEN}✓${NC} Constants.swift 存在"

    # 檢查是否已配置
    if grep -q "YOUR_GOOGLE_CLIENT_ID" "AuditorApp/Utilities/Constants.swift"; then
        echo -e "${YELLOW}⚠${NC} googleClientID 尚未配置"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓${NC} googleClientID 已配置"
    fi

    if grep -q "YOUR_DEPLOYMENT_ID" "AuditorApp/Utilities/Constants.swift"; then
        echo -e "${YELLOW}⚠${NC} gasWebAppURL 尚未配置"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓${NC} gasWebAppURL 已配置"
    fi

    if grep -q "your-company.com" "AuditorApp/Utilities/Constants.swift"; then
        echo -e "${YELLOW}⚠${NC} allowedDomains 可能需要更新為實際網域"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗${NC} Constants.swift 不存在"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 檢查 Info.plist
echo "📋 檢查 Info.plist..."
if [ -f "AuditorApp/Info.plist" ]; then
    echo -e "${GREEN}✓${NC} Info.plist 存在"

    # 檢查 URL Scheme
    if grep -q "YOUR_REVERSED_CLIENT_ID" "AuditorApp/Info.plist"; then
        echo -e "${YELLOW}⚠${NC} URL Scheme 尚未配置"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓${NC} URL Scheme 已配置"
    fi
else
    echo -e "${RED}✗${NC} Info.plist 不存在"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 檢查原始碼檔案
echo "📱 檢查原始碼檔案..."
REQUIRED_FILES=(
    "AuditorApp/AuditorApp.swift"
    "AuditorApp/Views/ContentView.swift"
    "AuditorApp/Views/LoginView.swift"
    "AuditorApp/Views/WebAppView.swift"
    "AuditorApp/Models/AuthenticationManager.swift"
    "AuditorApp/Utilities/KeychainHelper.swift"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $(basename $file)"
    else
        echo -e "${RED}✗${NC} $(basename $file) 不存在"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# 檢查 Pods 安裝
echo "📚 檢查依賴安裝..."
if [ -d "Pods" ]; then
    echo -e "${GREEN}✓${NC} CocoaPods 依賴已安裝"

    if [ -f "AuditorApp.xcworkspace" ]; then
        echo -e "${GREEN}✓${NC} Xcode Workspace 已建立"
        echo -e "${GREEN}ℹ${NC} 請使用 'open AuditorApp.xcworkspace' 開啟專案"
    else
        echo -e "${YELLOW}⚠${NC} Xcode Workspace 不存在"
        echo "   請執行: pod install"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠${NC} CocoaPods 依賴尚未安裝"
    echo "   請執行: pod install"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 總結
echo "================================"
echo "📊 檢查總結"
echo "================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 所有檢查通過！專案已正確配置。"
    echo ""
    echo "下一步："
    echo "1. 使用 'open AuditorApp.xcworkspace' 開啟專案"
    echo "2. 在 Xcode 中選擇您的開發團隊"
    echo "3. 執行專案 (⌘ + R)"
    exit 0
else
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}✗${NC} 發現 $ERRORS 個錯誤"
    fi

    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} 發現 $WARNINGS 個警告"
    fi

    echo ""
    echo "請修正上述問題後再次執行此腳本。"
    echo "詳細設置指南請參考: XCODE_SETUP.md"
    exit 1
fi
