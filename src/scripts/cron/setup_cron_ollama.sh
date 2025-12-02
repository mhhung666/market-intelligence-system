#!/usr/bin/env bash
###############################################################################
# Market Intelligence System - Cron Job Setup for macOS (Ollama Version)
#
# 設定定時任務使用 Ollama (完全免費):
# - 早上 08:00 執行 (美國收盤後的新聞)
# - 晚上 20:00 執行 (亞洲收盤後的新聞)
#
# 使用方式:
#   chmod +x setup_cron_ollama.sh
#   ./setup_cron_ollama.sh
###############################################################################

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 獲取專案根目錄的絕對路徑
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/market-intelligence-system-ollama.log"
CRON_SCRIPT="${PROJECT_ROOT}/run_daily_cron_ollama.sh"

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}🤖 Market Intelligence System - Cron Job 設定 (Ollama)${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

echo -e "${GREEN}專案路徑: ${PROJECT_ROOT}${NC}"
echo -e "${GREEN}日誌檔案: ${LOG_FILE}${NC}"
echo -e "${GREEN}執行腳本: ${CRON_SCRIPT}${NC}"
echo ""

# 檢查依賴
echo -e "${BLUE}🔍 檢查依賴...${NC}"

# 檢查 Ollama
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}❌ 錯誤: 未安裝 Ollama${NC}"
    echo -e "${YELLOW}請訪問 https://ollama.com 安裝${NC}"
    exit 1
fi
echo -e "${GREEN}   ✅ Ollama: $(ollama --version)${NC}"

# 檢查模型
if ! ollama list | grep -q "gemini-3-pro-preview"; then
    echo -e "${YELLOW}⚠️  警告: 未安裝 gemini-3-pro-preview 模型${NC}"
    echo -e "${YELLOW}   建議執行: ollama pull gemini-3-pro-preview${NC}"
fi

echo ""

# 檢查執行腳本是否存在
if [[ ! -f "${CRON_SCRIPT}" ]]; then
    echo -e "${RED}❌ 錯誤: 找不到執行腳本 ${CRON_SCRIPT}${NC}"
    exit 1
fi

# 確保腳本有執行權限
chmod +x "${CRON_SCRIPT}"

# 備份現有的 crontab
echo -e "${BLUE}📋 備份現有 crontab...${NC}"
BACKUP_FILE="${PROJECT_ROOT}/crontab-ollama.backup.$(date +%Y%m%d_%H%M%S)"
crontab -l > "${BACKUP_FILE}" 2>/dev/null || echo "# No existing crontab" > "${BACKUP_FILE}"
echo -e "${GREEN}   ✅ 備份已保存: ${BACKUP_FILE}${NC}"
echo ""

# 生成新的 crontab 內容
echo -e "${BLUE}📝 生成新的 crontab 設定...${NC}"
TEMP_CRONTAB="/tmp/mis_crontab_ollama_$$"

# 複製現有 crontab (排除舊的 MIS 任務)
crontab -l 2>/dev/null | grep -v "market-intelligence-system" > "${TEMP_CRONTAB}" || true

# 添加新的 cron 任務
cat >> "${TEMP_CRONTAB}" <<EOF

# ============================================================
# Market Intelligence System - 自動化市場分析 (Ollama - 免費)
# ============================================================
# 早上 08:00 執行 (美國收盤後的新聞)
0 8 * * * ${CRON_SCRIPT}

# 晚上 20:00 執行 (亞洲收盤後的新聞)
0 20 * * * ${CRON_SCRIPT}
# ============================================================
EOF

echo ""
echo -e "${YELLOW}即將安裝以下 cron 任務 (使用 Ollama):${NC}"
echo -e "${YELLOW}------------------------------------------------------------${NC}"
cat "${TEMP_CRONTAB}"
echo -e "${YELLOW}------------------------------------------------------------${NC}"
echo ""
echo -e "${GREEN}💡 優點:${NC}"
echo -e "${GREEN}   ✅ 完全免費 - 無 API 成本${NC}"
echo -e "${GREEN}   ✅ 本地運行 - 數據完全私密${NC}"
echo -e "${GREEN}   ✅ 無網路依賴 - 離線也能使用${NC}"
echo ""
echo -e "${YELLOW}⚠️  注意:${NC}"
echo -e "${YELLOW}   - 需要足夠的 RAM (建議 16GB+)${NC}"
echo -e "${YELLOW}   - 執行時間較 Claude 長 (5-10 分鐘)${NC}"
echo -e "${YELLOW}   - 分析質量取決於模型選擇${NC}"
echo ""

# 詢問確認
read -p "是否安裝這些 cron 任務? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    crontab "${TEMP_CRONTAB}"
    echo -e "${GREEN}✅ Cron 任務已安裝!${NC}"
    echo ""

    echo -e "${BLUE}📋 當前 crontab 設定:${NC}"
    echo -e "${BLUE}------------------------------------------------------------${NC}"
    crontab -l
    echo -e "${BLUE}------------------------------------------------------------${NC}"
    echo ""

    echo -e "${GREEN}🎉 設定完成!${NC}"
    echo ""
    echo -e "${BLUE}執行時間:${NC}"
    echo -e "  • 每天早上 08:00 (美國收盤後)"
    echo -e "  • 每天晚上 20:00 (亞洲收盤後)"
    echo ""
    echo -e "${BLUE}使用模型:${NC}"
    echo -e "  gemini-3-pro-preview (預設)"
    echo -e "  可修改 ${CRON_SCRIPT} 中的 OLLAMA_MODEL 變數"
    echo ""
    echo -e "${BLUE}日誌位置:${NC}"
    echo -e "  ${LOG_FILE}"
    echo ""
    echo -e "${BLUE}查看日誌:${NC}"
    echo -e "  tail -f ${LOG_FILE}"
    echo ""
    echo -e "${BLUE}手動測試執行:${NC}"
    echo -e "  ${CRON_SCRIPT}"
    echo ""
    echo -e "${BLUE}移除 cron 任務:${NC}"
    echo -e "  crontab -e  # 然後手動刪除 Market Intelligence System 相關行"
    echo ""
    echo -e "${BLUE}還原備份:${NC}"
    echo -e "  crontab ${BACKUP_FILE}"
    echo ""
    echo -e "${YELLOW}💡 提示: 你隨時可以切換回 Claude 版本，執行 ./setup_cron.sh${NC}"
    echo ""
else
    echo -e "${YELLOW}❌ 已取消安裝${NC}"
    rm -f "${TEMP_CRONTAB}"
    exit 0
fi

# 清理臨時檔案
rm -f "${TEMP_CRONTAB}"

echo -e "${GREEN}✅ 所有設定完成!${NC}"
