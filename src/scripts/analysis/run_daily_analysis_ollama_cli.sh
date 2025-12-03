#!/usr/bin/env bash
###############################################################################
# Market Intelligence System - Ollama 完整分析 (與 Claude CLI 相同任務)
#
# 使用 Ollama 執行與 Claude CLI 相同的分析任務:
# 1. 市場分析報告 (market-analysis-{date}.md)
# 2. 持倉分析報告 (holdings-analysis-{date}.md)
#
# 優點: 完全免費，本地運行
# 缺點: 分析質量可能不如 Claude，需要較大記憶體
#
# 依賴:
#   - ollama CLI (https://ollama.com)
#   - 推薦模型: qwen2.5:14b, llama3.1:70b, gemma2:27b
#
# 使用方式:
#   ./src/scripts/analysis/run_daily_analysis_ollama_full.sh
###############################################################################

set -e  # 遇到錯誤立即退出

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
OLLAMA_MODEL="${OLLAMA_MODEL:-deepseek-r1:70b}"  # 預設模型，可透過環境變數更改
TEMPERATURE="${TEMPERATURE:-0.3}"             # 較低溫度，更精確

# 日期和時間
TODAY=$(date +"%Y-%m-%d")
YEAR=$(date +"%Y")

# 支援時間後綴 (可選)
# 用法: TIME_SUFFIX=0800 ./run_daily_analysis_ollama_cli.sh
# 未設定時使用當前時間 (格式: HHMM, 例如 0800, 1430, 2000)
if [ -z "$TIME_SUFFIX" ]; then
    TIME_SUFFIX=$(date +"%H%M")
fi

# 路徑
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/output/market-data/${YEAR}"
DAILY_DIR="${OUTPUT_DIR}/Daily"
NEWS_DIR="${OUTPUT_DIR}/News"
REPORTS_DIR="${PROJECT_ROOT}/reports/markdown"
CONFIG_DIR="${PROJECT_ROOT}/config"

# 檔案路徑
GLOBAL_INDICES="${DAILY_DIR}/global-indices-${TODAY}.md"
PRICES="${DAILY_DIR}/holdings-prices-${TODAY}.md"
HOLDINGS_CONFIG="${CONFIG_DIR}/holdings.yaml"
PORTFOLIO_HOLDINGS="${PROJECT_ROOT}/../financial-analysis-system/portfolio/${YEAR}/holdings.md"
MARKET_ANALYSIS_OUTPUT="${REPORTS_DIR}/market-analysis-ollama-${TODAY}-${TIME_SUFFIX}.md"
HOLDINGS_ANALYSIS_OUTPUT="${REPORTS_DIR}/holdings-analysis-ollama-${TODAY}-${TIME_SUFFIX}.md"
MARKET_PROMPT_FILE="/tmp/ollama-market-analysis-prompt-${TODAY}-${TIME_SUFFIX}.txt"
HOLDINGS_PROMPT_FILE="/tmp/ollama-holdings-analysis-prompt-${TODAY}-${TIME_SUFFIX}.txt"

###############################################################################
# 函數定義
###############################################################################

print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}🤖 Market Intelligence System - Ollama 完整分析${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""
    echo -e "${GREEN}📅 分析日期: ${TODAY}${NC}"
    echo -e "${GREEN}🔧 使用模型: ${OLLAMA_MODEL}${NC}"
    echo -e "${GREEN}📄 報告 1: market-analysis-${TODAY}.md${NC}"
    echo -e "${GREEN}📄 報告 2: holdings-analysis-${TODAY}.md${NC}"
    echo ""
}

check_dependencies() {
    echo -e "${BLUE}🔍 檢查依賴...${NC}"

    # 檢查 ollama CLI
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}❌ 錯誤: 未安裝 ollama CLI${NC}"
        echo -e "${YELLOW}請訪問 https://ollama.com 下載安裝${NC}"
        exit 1
    fi

    # 檢查模型是否已下載
    if ! ollama list | grep -q "${OLLAMA_MODEL}"; then
        echo -e "${YELLOW}⚠️  模型 ${OLLAMA_MODEL} 未下載${NC}"
        echo -e "${YELLOW}正在下載模型（這可能需要幾分鐘）...${NC}"
        ollama pull "${OLLAMA_MODEL}"
    fi

    echo -e "${GREEN}   ✅ Ollama 已就緒 (模型: ${OLLAMA_MODEL})${NC}"
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
        echo -e "${YELLOW}請先執行爬蟲腳本: make fetch-all${NC}"
        exit 1
    fi

    echo -e "${GREEN}   ✅ 資料檔案完整${NC}"
    echo ""
}

collect_news_files() {
    # 查找新聞檔案
    find "${NEWS_DIR}" -name "*-${TODAY}.md" 2>/dev/null || true
}

###############################################################################
# 市場分析報告生成
###############################################################################

generate_market_analysis_prompt() {
    echo -e "${BLUE}📝 生成市場分析 Prompt...${NC}"

    # 讀取全球指數數據
    local indices_data
    indices_data=$(<"${GLOBAL_INDICES}")

    # 讀取新聞數據
    local news_data=""
    local news_files
    # 相容 bash 3.x (macOS 默認版本)
    news_files=()
    while IFS= read -r line; do
        news_files+=("$line")
    done < <(collect_news_files)

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

    local news_count=${#news_files[@]}

    # 生成市場分析 Prompt（與 Claude 版本相同）
    cat > "${MARKET_PROMPT_FILE}" <<'EOF'
你是一位專業的全球市場分析師,擅長解讀市場數據和新聞,提供深度市場洞察。

**重要：請使用繁體中文（Traditional Chinese）回答，不要使用簡體中文。**

## 📋 分析任務

請根據以下今日市場數據,生成一份**全球市場情報分析報告**。

### 核心要求:
1. **市場趨勢分析**: 識別全球市場的主要趨勢和驅動因素
2. **新聞影響評估**: 深度解讀重要新聞對市場的潛在影響
3. **產業輪動分析**: 分析資金流向和產業表現
4. **風險與機會**: 識別當前市場風險和投資機會
5. **後市展望**: 提供未來一週的市場展望

### 報告風格:
- 專業但易懂
- 數據驅動,洞察為先
- 結構清晰,重點突出
- 避免模糊建議,提供具體方向

---

## 📊 今日市場數據

### 全球市場指數
```markdown
EOF

    cat >> "${MARKET_PROMPT_FILE}" <<EOF
${indices_data}
\`\`\`

### 市場新聞 (${news_count} 則)
\`\`\`markdown
${news_data}
\`\`\`

---

## 📄 報告結構

請按照以下結構生成報告:

# 📈 全球市場分析 - ${TODAY}

> **報告生成時間**: $(date +"%Y-%m-%d %H:%M UTC")
> **分析引擎**: Market Intelligence System (Ollama)
> **使用模型**: ${OLLAMA_MODEL}
> **報告類型**: 全球市場情報

---

## 📊 執行摘要

### 市場概況
[用 2-3 段文字總結今日全球市場表現:]
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
| 黃金 | \\\$X,XXX | +X.XX% | 🟢/🔴 描述 |

### 市場情緒評估

| 類別 | 評分 (1-10) | 說明 |
|------|-------------|------|
| 整體市場情緒 | X | 簡短說明 |
| 科技股情緒 | X | 簡短說明 |
| 波動性風險 | X | 簡短說明 |

---

## 🌍 全球市場深度分析

### 美國市場 🇺🇸

**主要指數表現**

| 指數 | 收盤價 | 漲跌幅 | 技術狀態 |
|------|--------|--------|----------|
| S&P 500 | X,XXX.XX | +X.XX% | 描述 |
| Nasdaq | XX,XXX.XX | +X.XX% | 描述 |
| Dow Jones | XX,XXX.XX | +X.XX% | 描述 |

**市場分析**:
[深入分析美國市場:]
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
[分析亞洲市場趨勢]

### 歐洲市場 🇪🇺

**市場分析**:
[簡要分析歐洲市場]

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

## 🏭 產業輪動分析

### 強勢產業

| 產業 | 表現 | 驅動因素 |
|------|------|----------|
| 產業1 | +X.XX% | 簡述 |
| 產業2 | +X.XX% | 簡述 |

### 弱勢產業

| 產業 | 表現 | 原因 |
|------|------|------|
| 產業1 | -X.XX% | 簡述 |

**分析**: [深入分析產業輪動背後的邏輯]

---

## ⚠️ 風險與機會

### 市場風險

1. **風險1**: 詳細說明
2. **風險2**: 詳細說明
3. **風險3**: 詳細說明

### 投資機會

1. **機會1**: 詳細說明
2. **機會2**: 詳細說明

### VIX 恐慌指數分析

- **當前值**: XX.XX
- **變化**: ±X.XX%
- **解讀**: [分析市場情緒和波動性預期]

---

## 🔮 後市展望

### 未來一週關鍵事件

**經濟數據**:
- 日期: 數據名稱 - 預期影響
- 日期: 數據名稱 - 預期影響

**企業財報**:
- 日期: 公司名稱 - 關注重點

**其他重要事件**:
- 事件描述

### 情境分析

#### 樂觀情境 (機率: XX%)
[條件、預期影響、市場反應]

#### 基準情境 (機率: XX%)
[條件、預期影響、市場反應]

#### 悲觀情境 (機率: XX%)
[條件、預期影響、市場反應]

---

## 💡 投資策略建議

### 短期觀點 (1-2週)

**市場看法**: [總結]

**策略建議**:
1. 建議1
2. 建議2

### 中期觀點 (1-3個月)

**市場看法**: [總結]

**策略建議**:
1. 建議1
2. 建議2

---

## ⚠️ 免責聲明

本報告僅供參考,不構成投資建議。投資有風險,請根據自身情況做出獨立決策。

---

**報告製作**: Market Intelligence System
**分析引擎**: Ollama (${OLLAMA_MODEL})
**數據來源**: Yahoo Finance
**報告版本**: v2.0 (Ollama Edition)

---

請直接開始生成完整的市場分析報告,從標題開始,不要有任何前置說明或詢問。只輸出 Markdown 格式的報告內容。
EOF

    echo -e "${GREEN}   ✅ 市場分析 Prompt 已生成${NC}"
    echo ""
}

run_market_analysis() {
    echo -e "${BLUE}🤖 調用 Ollama 進行市場分析...${NC}"
    echo -e "${YELLOW}   使用模型: ${OLLAMA_MODEL}${NC}"
    echo -e "${YELLOW}   這可能需要幾分鐘,請稍候...${NC}"
    echo ""

    mkdir -p "${REPORTS_DIR}"

    # 使用 sed 過濾 ANSI 控制碼和 thinking 標記
    if ollama run "${OLLAMA_MODEL}" < "${MARKET_PROMPT_FILE}" 2>/dev/null | \
       sed -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
           -e 's/\x1b\[?[0-9;]*[a-zA-Z]//g' \
           -e '/^Thinking\.\.\.$/,/^\.\.\.done thinking\.$/d' \
           > "${MARKET_ANALYSIS_OUTPUT}"; then
        echo -e "${GREEN}   ✅ 市場分析完成!${NC}"
        echo ""
    else
        echo -e "${RED}   ❌ 市場分析失敗${NC}"
        exit 1
    fi
}

###############################################################################
# 持倉分析報告生成
###############################################################################

generate_holdings_analysis_prompt() {
    echo -e "${BLUE}📝 生成持倉分析 Prompt...${NC}"

    # 讀取持倉價格數據
    local prices_data
    prices_data=$(<"${PRICES}")

    # 讀取持倉配置數據
    local holdings_config=""
    if [[ -f "${HOLDINGS_CONFIG}" ]]; then
        holdings_config=$(<"${HOLDINGS_CONFIG}")
    fi

    # 讀取投資組合完整資訊
    local portfolio_data=""
    if [[ -f "${PORTFOLIO_HOLDINGS}" ]]; then
        portfolio_data=$(<"${PORTFOLIO_HOLDINGS}")
    fi

    # 生成持倉分析 Prompt（與 Claude 版本相同，只修改模型說明）
    cat > "${HOLDINGS_PROMPT_FILE}" <<'EOF'
你是一位專業的投資組合分析師,擅長評估持倉表現、資產配置和風險管理。

**重要：請使用繁體中文（Traditional Chinese）回答，不要使用簡體中文。**

## 📋 分析任務

請根據以下投資組合數據,生成一份**持倉分析報告**。

### 核心要求:
1. **資產配置分析**: 評估現金/股票比例是否合理
2. **持倉表現評估**: 分析每檔股票的表現（考慮成本、當前價、倉位）
3. **選擇權風險管理**: 評估選擇權部位風險,提供到期處理建議
4. **倉位調整建議**: 基於市場環境和個股表現提供加減碼建議
5. **風險控制**: 識別倉位過重、損失過大等風險點

### 報告風格:
- 具體、可操作
- 基於數據和成本價
- 考慮選擇權約束
- 提供明確的買賣建議

---

## 📊 投資組合數據

### 投資組合完整資訊
```markdown
EOF

    cat >> "${HOLDINGS_PROMPT_FILE}" <<EOF
${portfolio_data}
\`\`\`

### 持倉配置詳情
\`\`\`yaml
${holdings_config}
\`\`\`

### 今日持倉價格
\`\`\`markdown
${prices_data}
\`\`\`

---

## 📄 報告結構

請按照以下結構生成報告:

# 💼 投資組合分析 - ${TODAY}

> **報告生成時間**: $(date +"%Y-%m-%d %H:%M UTC")
> **分析引擎**: Market Intelligence System (Ollama)
> **使用模型**: ${OLLAMA_MODEL}
> **報告類型**: 持倉分析

---

[後續結構與 Claude 版本完全相同...]

請直接開始生成完整的持倉分析報告,從標題開始,不要有任何前置說明或詢問。只輸出 Markdown 格式的報告內容。
EOF

    echo -e "${GREEN}   ✅ 持倉分析 Prompt 已生成${NC}"
    echo ""
}

run_holdings_analysis() {
    echo -e "${BLUE}🤖 調用 Ollama 進行持倉分析...${NC}"
    echo -e "${YELLOW}   使用模型: ${OLLAMA_MODEL}${NC}"
    echo -e "${YELLOW}   這可能需要幾分鐘,請稍候...${NC}"
    echo ""

    mkdir -p "${REPORTS_DIR}"

    if ollama run "${OLLAMA_MODEL}" < "${HOLDINGS_PROMPT_FILE}" 2>/dev/null | \
       sed -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
           -e 's/\x1b\[?[0-9;]*[a-zA-Z]//g' \
           -e '/^Thinking\.\.\.$/,/^\.\.\.done thinking\.$/d' \
           > "${HOLDINGS_ANALYSIS_OUTPUT}"; then
        echo -e "${GREEN}   ✅ 持倉分析完成!${NC}"
        echo ""
    else
        echo -e "${RED}   ❌ 持倉分析失敗${NC}"
        exit 1
    fi
}

###############################################################################
# 結果展示
###############################################################################

show_results() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}📄 分析報告已生成!${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""

    echo -e "${GREEN}📈 市場分析報告 (Ollama):${NC}"
    echo -e "${GREEN}   ${MARKET_ANALYSIS_OUTPUT}${NC}"
    echo ""

    echo -e "${GREEN}💼 持倉分析報告 (Ollama):${NC}"
    echo -e "${GREEN}   ${HOLDINGS_ANALYSIS_OUTPUT}${NC}"
    echo ""

    # 顯示檔案大小
    if [[ -f "${MARKET_ANALYSIS_OUTPUT}" ]]; then
        local size=$(du -h "${MARKET_ANALYSIS_OUTPUT}" | cut -f1)
        echo -e "${BLUE}   市場分析報告大小: ${size}${NC}"
    fi

    if [[ -f "${HOLDINGS_ANALYSIS_OUTPUT}" ]]; then
        local size=$(du -h "${HOLDINGS_ANALYSIS_OUTPUT}" | cut -f1)
        echo -e "${BLUE}   持倉分析報告大小: ${size}${NC}"
    fi

    echo ""
    echo -e "${GREEN}💡 查看完整報告:${NC}"
    echo -e "${GREEN}   cat ${MARKET_ANALYSIS_OUTPUT}${NC}"
    echo -e "${GREEN}   cat ${HOLDINGS_ANALYSIS_OUTPUT}${NC}"
    echo ""
}

cleanup() {
    # 清理臨時檔案
    rm -f "${MARKET_PROMPT_FILE}" "${HOLDINGS_PROMPT_FILE}"
}

###############################################################################
# 主程式
###############################################################################

main() {
    print_header
    check_dependencies
    check_data_files

    echo -e "${BLUE}📊 生成市場分析報告...${NC}"
    echo ""
    generate_market_analysis_prompt
    run_market_analysis

    echo -e "${BLUE}💼 生成持倉分析報告...${NC}"
    echo ""
    generate_holdings_analysis_prompt
    run_holdings_analysis

    show_results
    cleanup

    echo -e "${GREEN}✅ Ollama 完整分析完成!${NC}"
    echo -e "${YELLOW}💡 提示: 你可以將 Claude 和 Ollama 的報告進行對比${NC}"
    echo ""
}

# 執行主程式
main "$@"
