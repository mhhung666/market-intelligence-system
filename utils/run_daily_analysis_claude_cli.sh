#!/usr/bin/env bash
###############################################################################
# Market Intelligence System - Daily Analysis (Claude CLI Version)
#
# 使用 Claude CLI 進行每日市場分析
# 參考 FAS 的實作方式,使用純 Bash + Claude CLI
#
# 依賴:
#   - claude CLI (npm install -g @anthropic-ai/claude-cli)
#   - 已登入 Claude CLI (claude login)
#
# 使用方式:
#   ./analyzers/run_daily_analysis_claude_cli.sh
#   或
#   make analyze-daily
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
YEAR=$(date +"%Y")

# 路徑
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/output/market-data/${YEAR}"
DAILY_DIR="${OUTPUT_DIR}/Daily"
NEWS_DIR="${OUTPUT_DIR}/News"
ANALYSIS_DIR="${PROJECT_ROOT}/analysis"

# 檔案路徑
GLOBAL_INDICES="${DAILY_DIR}/global-indices-${TODAY}.md"
PRICES="${DAILY_DIR}/prices-${TODAY}.md"
ANALYSIS_OUTPUT="${ANALYSIS_DIR}/market-analysis-${TODAY}.md"
PROMPT_FILE="/tmp/market-analysis-prompt-${TODAY}.txt"

###############################################################################
# 函數定義
###############################################################################

print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}📊 Market Intelligence System - 每日市場分析 (Claude CLI)${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""
    echo -e "${GREEN}📅 分析日期: ${TODAY}${NC}"
    echo ""
}

check_dependencies() {
    echo -e "${BLUE}🔍 檢查依賴...${NC}"

    # 檢查 claude CLI
    if ! command -v claude &> /dev/null; then
        echo -e "${RED}❌ 錯誤: 未安裝 claude CLI${NC}"
        echo -e "${YELLOW}請執行: npm install -g @anthropic-ai/claude-cli${NC}"
        exit 1
    fi

    echo -e "${GREEN}   ✅ Claude CLI 已安裝${NC}"
    echo ""
}

check_data_files() {
    echo -e "${BLUE}🔍 檢查資料檔案...${NC}"

    local missing_files=()

    if [[ ! -f "${GLOBAL_INDICES}" ]]; then
        missing_files+=("全球指數檔案: ${GLOBAL_INDICES}")
    fi

    if [[ ! -f "${PRICES}" ]]; then
        missing_files+=("持倉價格檔案: ${PRICES}")
    fi

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  警告: 以下資料檔案不存在:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "${YELLOW}  - ${file}${NC}"
        done
        echo ""
        echo -e "${YELLOW}請先執行爬蟲腳本:${NC}"
        echo -e "${YELLOW}  make fetch-all${NC}"
        exit 1
    fi

    echo -e "${GREEN}   ✅ 資料檔案完整${NC}"
    echo ""
}

collect_news_files() {
    echo -e "${BLUE}📰 收集當日新聞檔案...${NC}"

    # 查找新聞檔案
    local news_files=($(find "${NEWS_DIR}" -name "*-${TODAY}.md" 2>/dev/null || true))
    local count=${#news_files[@]}

    echo -e "${GREEN}   找到 ${count} 個新聞檔案${NC}"
    echo ""

    # 返回檔案列表 (通過 stdout)
    printf '%s\n' "${news_files[@]}"
}

generate_analysis_prompt() {
    echo -e "${BLUE}📝 生成分析 Prompt...${NC}"

    # 讀取全球指數數據
    local indices_data
    indices_data=$(<"${GLOBAL_INDICES}")

    # 讀取持倉價格數據
    local prices_data
    prices_data=$(<"${PRICES}")

    # 讀取新聞數據
    local news_data=""
    local news_files
    mapfile -t news_files < <(collect_news_files)

    for news_file in "${news_files[@]}"; do
        if [[ -f "${news_file}" ]]; then
            local symbol
            symbol=$(basename "${news_file}" | sed "s/-${TODAY}.md//")
            local news_content
            news_content=$(<"${news_file}")
            news_data="${news_data}

### ${symbol} 新聞
${news_content}"
        fi
    done

    # 生成完整 Prompt
    cat > "${PROMPT_FILE}" <<EOF
你是一位專業的市場情報分析師,擅長解讀全球市場數據和新聞,提供深度市場洞察。

## 📋 分析任務

請根據以下今日市場數據,生成一份完整的**市場情報分析報告**。

### 核心要求:
1. **市場趨勢分析**: 識別全球市場的主要趨勢和驅動因素
2. **新聞影響評估**: 深度解讀重要新聞對市場的潛在影響
3. **持倉表現分析**: 評估持股表現並提供操作建議
4. **風險與機會**: 識別當前市場風險和投資機會
5. **可執行建議**: 提供具體、可操作的投資策略

### 報告風格:
- 專業但易懂
- 數據驅動,洞察為先
- 結構清晰,重點突出
- 避免模糊建議,提供具體方向

---

## 📊 今日市場數據

### 全球市場指數
\`\`\`markdown
${indices_data}
\`\`\`

### 持倉股票價格
\`\`\`markdown
${prices_data}
\`\`\`

### 市場新聞
\`\`\`markdown
${news_data}
\`\`\`

---

## 📄 報告結構

請按照以下結構生成報告:

# 📈 市場情報分析 - ${TODAY}

> **報告生成時間**: $(date +"%Y-%m-%d %H:%M UTC")
> **分析引擎**: Market Intelligence System (Claude CLI)
> **報告類型**: 每日市場情報

---

## 📊 執行摘要

### 市場概況
[用 2-3 段文字總結今日全球市場表現,包含:]
- 主要市場趨勢 (美股、亞股、歐股)
- 關鍵驅動因素
- 市場情緒指標 (VIX)
- 重要事件或數據

### 關鍵數據

| 指標 | 數值 | 變化 | 狀態 |
|------|------|------|------|
| S&P 500 | X,XXX.XX | +X.XX% | 🟢/🔴 描述 |
| Nasdaq | XX,XXX.XX | +X.XX% | 🟢/🔴 描述 |
| VIX | XX.XX | +X.XX% | 🟢/🔴 描述 |
| 台股加權 | XX,XXX.XX | +X.XX% | 🟢/🔴 描述 |
| 黃金 | \$X,XXX | +X.XX% | 🟢/🔴 描述 |

### 市場情緒評估

| 類別 | 評分 (1-10) | 說明 |
|------|-------------|------|
| 整體市場情緒 | X | 簡短說明 |
| 科技股情緒 | X | 簡短說明 |
| 波動性風險 | X | 簡短說明 |

---

## 🌍 全球市場分析

### 美國市場 🇺🇸

**主要指數表現**

| 指數 | 收盤價 | 漲跌幅 | 技術狀態 |
|------|--------|--------|----------|
| S&P 500 | X,XXX.XX | +X.XX% | 描述 |
| Nasdaq | XX,XXX.XX | +X.XX% | 描述 |
| Dow Jones | XX,XXX.XX | +X.XX% | 描述 |

**市場分析**:
[深入分析美國市場的表現,包含:]
- 主要驅動因素
- 產業輪動情況
- 技術面關鍵水平
- 後市展望

### 亞洲市場 🌏

**主要市場表現**

| 市場 | 指數 | 收盤價 | 漲跌幅 |
|------|------|--------|--------|
| 🇹🇼 台灣 | 加權指數 | XX,XXX.XX | +X.XX% |
| 🇯🇵 日本 | 日經225 | XX,XXX.XX | +X.XX% |
| 🇰🇷 韓國 | KOSPI | X,XXX.XX | +X.XX% |

**市場分析**:
[分析亞洲市場趨勢和關鍵因素]

### 歐洲市場 🇪🇺

**市場分析**:
[簡要分析歐洲市場]

---

## 💼 持倉股票分析

### 整體表現

| 分類 | 數量 | 平均漲跌 | 說明 |
|------|------|----------|------|
| 強勢上漲 (>+2%) | X 檔 | +X.XX% | 概述 |
| 穩健上漲 (+0%~+2%) | X 檔 | +X.XX% | 概述 |
| 輕微下跌 (0%~-2%) | X 檔 | -X.XX% | 概述 |
| 重大虧損 (<-2%) | X 檔 | -X.XX% | 概述 |

### 重點持股分析

[針對表現突出的股票 (漲跌幅 > 2%) 進行詳細分析:]

#### 📈 TICKER - 公司名稱 (+X.XX%)

**價格資訊**:
- 收盤價: \$XXX.XX
- 變化: +X.XX% (+\$X.XX)
- 當日區間: \$XXX.XX - \$XXX.XX

**分析**:
[結合新聞和市場數據,深入分析漲跌原因]

**操作建議**:
- **建議**: 持有 / 加碼 / 減碼 / 觀望
- **理由**: 具體說明
- **目標價**: \$XXX.XX (如適用)

---

## 📰 重要新聞解讀

[按主題或產業分類,深入解讀影響市場的重要新聞:]

### 科技產業

#### 新聞標題
[深度分析新聞內容、市場影響、投資啟示]

### 其他產業

#### 新聞標題
[同上]

---

## ⚠️ 風險與機會

### 市場風險

1. **風險1**: 詳細說明
2. **風險2**: 詳細說明

### 投資機會

1. **機會1**: 詳細說明
2. **機會2**: 詳細說明

### VIX 恐慌指數分析

- **當前值**: XX.XX
- **變化**: ±X.XX%
- **解讀**: [分析市場情緒]

---

## 💡 投資策略建議

### 短期策略 (1-2週)

**市場觀點**: [總結短期看法]

**具體建議**:
1. **建議1**: 詳細說明操作方向和條件
2. **建議2**: 詳細說明

**觸發式指令**:
- 如果 XXX,則執行 YYY 操作

### 中長期策略

**配置建議**: [說明配置方向]

---

## 🔮 後市展望

### 關鍵催化劑

**未來一週關注**:
1. 事件1: 時間、預期影響
2. 事件2: 時間、預期影響

### 情境分析

#### 樂觀情境 (機率: XX%)
[條件、預期影響、策略]

#### 基準情境 (機率: XX%)
[同上]

#### 悲觀情境 (機率: XX%)
[同上]

---

## ✅ 行動清單

### 立即執行 (本週)

- [ ] **行動1**: 具體描述
- [ ] **行動2**: 具體描述

### 中期追蹤

- [ ] **行動1**: 具體描述

---

## ⚠️ 免責聲明

本報告僅供參考,不構成投資建議。投資有風險,請根據自身情況做出獨立決策。

---

**報告製作**: Market Intelligence System
**分析引擎**: Claude CLI
**數據來源**: Yahoo Finance
**報告版本**: v1.0

---

請直接開始生成完整的市場情報分析報告,從標題開始,不要有任何前置說明或詢問。
EOF

    echo -e "${GREEN}   ✅ Prompt 已生成 (${PROMPT_FILE})${NC}"
    echo ""
}

run_claude_analysis() {
    echo -e "${BLUE}🧠 調用 Claude CLI 進行市場分析...${NC}"
    echo -e "${YELLOW}   這可能需要幾分鐘,請稍候...${NC}"
    echo ""

    # 確保分析目錄存在
    mkdir -p "${ANALYSIS_DIR}"

    # 調用 Claude CLI
    # 使用 --no-stream 避免串流輸出,直接儲存完整結果
    if claude --no-stream < "${PROMPT_FILE}" > "${ANALYSIS_OUTPUT}" 2>&1; then
        echo -e "${GREEN}   ✅ 分析完成!${NC}"
        echo ""
    else
        echo -e "${RED}   ❌ 分析失敗${NC}"
        echo -e "${YELLOW}   請檢查 Claude CLI 是否已登入: claude login${NC}"
        exit 1
    fi
}

show_results() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}📄 分析報告已保存至:${NC}"
    echo -e "${GREEN}   ${ANALYSIS_OUTPUT}${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""

    # 顯示報告前 30 行預覽
    echo -e "${BLUE}📋 報告預覽 (前 30 行):${NC}"
    echo -e "${BLUE}------------------------------------------------------------${NC}"
    head -n 30 "${ANALYSIS_OUTPUT}"
    echo -e "${BLUE}------------------------------------------------------------${NC}"
    echo ""
    echo -e "${GREEN}💡 查看完整報告: cat ${ANALYSIS_OUTPUT}${NC}"
    echo ""
}

cleanup() {
    # 清理臨時檔案
    rm -f "${PROMPT_FILE}"
}

###############################################################################
# 主程式
###############################################################################

main() {
    print_header
    check_dependencies
    check_data_files
    generate_analysis_prompt
    run_claude_analysis
    show_results
    cleanup

    echo -e "${GREEN}✅ 每日市場分析完成!${NC}"
    echo ""
}

# 執行主程式
main "$@"
