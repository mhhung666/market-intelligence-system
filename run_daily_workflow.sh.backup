#!/bin/bash
###############################################################################
# Market Intelligence System - Complete Daily Workflow
#
# 功能: 完整的每日自動化流程
#   1. 資料抓取與分析 (make daily)
#   2. 更新 GitHub Pages (make update-pages)
#   3. 自動 Git Commit
#   4. 推送到 GitHub (make push)
#
# 使用: 由 crontab 自動執行,或手動執行
###############################################################################

set -e  # 遇到錯誤立即退出

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日期
TODAY=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")

# 專案路徑
PROJECT_ROOT="/Users/mhhung/Development/MH/market-intelligence-system"

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}📊 Market Intelligence System - Daily Workflow${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo -e "${GREEN}📅 日期: ${TODAY}${NC}"
echo -e "${GREEN}⏰ 時間: ${TIME}${NC}"
echo ""

# 切換到專案目錄
cd "${PROJECT_ROOT}" || exit 1

# Step 1: 執行 make daily (資料抓取 + 分析)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 Step 1/4: 執行每日分析 (make daily)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if make daily; then
    echo -e "${GREEN}✅ 每日分析完成!${NC}"
    echo ""
else
    echo -e "${RED}❌ 每日分析失敗!${NC}"
    exit 1
fi

# Step 2: 更新 GitHub Pages
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Step 2/4: 更新 GitHub Pages (make update-pages)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if make update-pages; then
    echo -e "${GREEN}✅ GitHub Pages 已更新!${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  GitHub Pages 更新失敗,繼續執行...${NC}"
    echo ""
fi

# Step 3: Git Commit
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 Step 3/4: Git Commit (make commit-auto)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if make commit-auto; then
    echo -e "${GREEN}✅ Git Commit 完成!${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  沒有變更需要 commit${NC}"
    echo ""
fi

# Step 4: Push to GitHub
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Step 4/4: Push to GitHub (make push)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if make push; then
    echo -e "${GREEN}✅ Push 完成!${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  Push 失敗或沒有需要 push 的內容${NC}"
    echo ""
fi

# 完成
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 完整工作流程執行完畢!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📊 執行摘要:${NC}"
echo -e "  1. ✅ 資料抓取與分析"
echo -e "  2. ✅ GitHub Pages 更新"
echo -e "  3. ✅ Git Commit"
echo -e "  4. ✅ Push to GitHub"
echo ""
echo -e "${GREEN}完成時間: $(date +"%Y-%m-%d %H:%M:%S")${NC}"
