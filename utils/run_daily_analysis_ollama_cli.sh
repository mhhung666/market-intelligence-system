#!/usr/bin/env bash
###############################################################################
# Market Intelligence System - Ollama Analysis (CLI Version)
#
# 使用 Ollama CLI 進行新聞預處理和情緒分析
# 作為 Claude 分析的前置步驟,用於降低成本
#
# 依賴:
#   - ollama CLI (https://ollama.com)
#   - 已下載模型 (ollama pull llama3.1:8b 或 qwen2.5:14b)
#
# 使用方式:
#   ./analyzers/run_daily_analysis_ollama_cli.sh
#   或
#   make analyze-ollama
###############################################################################

set -e  # 遇到錯誤立即退出

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
OLLAMA_MODEL="${OLLAMA_MODEL:-gpt-oss:20b}"  # 預設模型
TEMPERATURE="${TEMPERATURE:-0.3}"                # 較低溫度,更精確
MAX_NEWS_TO_ANALYZE=50                           # 最多分析前 50 則新聞
TOP_K=10                                         # 篩選出前 10 則重要新聞

# 日期
TODAY=$(date +"%Y-%m-%d")
YEAR=$(date +"%Y")

# 路徑
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/output/market-data/${YEAR}"
NEWS_DIR="${OUTPUT_DIR}/News"
ANALYSIS_DIR="${PROJECT_ROOT}/analysis"

# 輸出檔案
FILTERED_NEWS="${ANALYSIS_DIR}/filtered-news-${TODAY}.md"
SENTIMENT_REPORT="${ANALYSIS_DIR}/sentiment-analysis-${TODAY}.md"
PROMPT_FILE="/tmp/ollama-analysis-prompt-${TODAY}.txt"

###############################################################################
# 函數定義
###############################################################################

print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}🤖 Market Intelligence System - Ollama 新聞分析${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""
    echo -e "${GREEN}📅 分析日期: ${TODAY}${NC}"
    echo -e "${GREEN}🔧 使用模型: ${OLLAMA_MODEL}${NC}"
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
        echo -e "${YELLOW}正在下載模型...${NC}"
        ollama pull "${OLLAMA_MODEL}"
    fi

    echo -e "${GREEN}   ✅ Ollama 已就緒 (模型: ${OLLAMA_MODEL})${NC}"
    echo ""
}

collect_news_files() {
    echo -e "${BLUE}📰 收集當日新聞檔案...${NC}"

    # 查找新聞檔案
    local news_files=($(find "${NEWS_DIR}" -name "*-${TODAY}.md" 2>/dev/null || true))
    local count=${#news_files[@]}

    if [[ ${count} -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  未找到新聞檔案${NC}"
        echo -e "${YELLOW}請先執行: make fetch-news${NC}"
        exit 1
    fi

    echo -e "${GREEN}   找到 ${count} 個新聞檔案${NC}"
    echo ""

    # 返回檔案列表
    printf '%s\n' "${news_files[@]}"
}

read_news_content() {
    local news_files=("$@")
    local all_news=""

    for news_file in "${news_files[@]}"; do
        if [[ -f "${news_file}" ]]; then
            local symbol
            symbol=$(basename "${news_file}" | sed "s/-${TODAY}.md//")
            local news_content
            news_content=$(<"${news_file}")
            all_news="${all_news}

## ${symbol}

${news_content}
"
        fi
    done

    echo "${all_news}"
}

analyze_news_importance() {
    echo -e "${BLUE}📊 使用 Ollama 篩選重要新聞...${NC}"
    echo -e "${YELLOW}   分析前 ${MAX_NEWS_TO_ANALYZE} 則新聞,選出前 ${TOP_K} 則最重要的...${NC}"
    echo ""

    # 收集新聞內容
    local news_files
    IFS=$'\n' read -r -d '' -a news_files < <(collect_news_files && printf '\0')
    local news_content
    news_content=$(read_news_content "${news_files[@]}")

    # 生成篩選 Prompt
    cat > "${PROMPT_FILE}" <<EOF
你是一位專業的市場新聞分析師,擅長快速評估新聞的重要性和市場影響。

**重要：請使用繁體中文（Traditional Chinese）回答，不要使用簡體中文。**

## 任務

請從以下新聞中,選出**最重要的 ${TOP_K} 則新聞**,並說明選擇理由。

## 評估標準

**高度重要** (必選):
1. 重大經濟數據 (GDP, CPI, 非農就業等)
2. 央行政策決議 (利率、QE、縮表)
3. 地緣政治重大事件
4. 重大企業財報或併購
5. 產業顛覆性創新

**中度重要** (酌情選擇):
1. 企業營運更新
2. 產業趨勢報告
3. 重要人事變動
4. 法規政策變化

**低度重要** (忽略):
1. 公司例行公告
2. 分析師評級調整
3. 小型企業新聞

## 新聞列表

${news_content}

## 輸出格式

請按照以下格式輸出:

# 今日最重要的 ${TOP_K} 則市場新聞

## 1. [新聞標題]

**重要性評分**: X/10
**影響範圍**: [全球市場 / 美股 / 台股 / 特定產業]
**市場影響**: [看漲 / 看跌 / 中性]
**選擇理由**: [簡要說明為何這則新聞重要]

## 2. [新聞標題]
[同上格式]

...

只輸出 Markdown 格式的結果,不要有任何前置說明。
EOF

    # 調用 Ollama
    mkdir -p "${ANALYSIS_DIR}"

    # 使用 script 工具來過濾 ANSI 控制碼，或使用 sed 清理輸出
    if ollama run "${OLLAMA_MODEL}" < "${PROMPT_FILE}" 2>/dev/null | sed -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' -e 's/\x1b\[?[0-9;]*[a-zA-Z]//g' -e '/^Thinking\.\.\.$/,/^\.\.\.done thinking\.$/d' > "${FILTERED_NEWS}"; then
        echo -e "${GREEN}   ✅ 新聞篩選完成${NC}"
        echo -e "${GREEN}   結果已保存至: ${FILTERED_NEWS}${NC}"
        echo ""
    else
        echo -e "${RED}   ❌ 新聞篩選失敗${NC}"
        exit 1
    fi
}

analyze_market_sentiment() {
    echo -e "${BLUE}😊 使用 Ollama 分析市場情緒...${NC}"
    echo ""

    # 讀取篩選後的新聞
    local filtered_news
    if [[ -f "${FILTERED_NEWS}" ]]; then
        filtered_news=$(<"${FILTERED_NEWS}")
    else
        echo -e "${YELLOW}⚠️  未找到篩選後的新聞,跳過情緒分析${NC}"
        return
    fi

    # 生成情緒分析 Prompt
    cat > "${PROMPT_FILE}" <<EOF
你是一位市場情緒分析專家,擅長從新聞中評估市場整體情緒。

**重要：請使用繁體中文（Traditional Chinese）回答，不要使用簡體中文。**

## 任務

請根據以下重要新聞,分析當前市場情緒。

## 新聞內容

${filtered_news}

## 輸出格式

請按照以下格式輸出:

# 市場情緒分析 - ${TODAY}

## 整體市場情緒

**情緒指數**: X/10 (1=極度悲觀, 5=中性, 10=極度樂觀)
**主要情緒**: [樂觀 / 悲觀 / 中性 / 分化]
**信心水平**: [高 / 中 / 低]

## 情緒分解

### 😊 樂觀因素 (權重: XX%)
1. [因素1]: 簡短說明
2. [因素2]: 簡短說明

### 😟 悲觀因素 (權重: XX%)
1. [因素1]: 簡短說明
2. [因素2]: 簡短說明

### 😐 中性因素 (權重: XX%)
1. [因素1]: 簡短說明

## 產業情緒分布

| 產業 | 情緒 | 評分 | 說明 |
|------|------|------|------|
| 科技 | 🟢/🔴/⚪ | X/10 | 簡短說明 |
| 金融 | 🟢/🔴/⚪ | X/10 | 簡短說明 |
| 能源 | 🟢/🔴/⚪ | X/10 | 簡短說明 |

## 市場風險指標

**恐慌程度**: X/10
**主要風險**:
1. [風險1]
2. [風險2]

## 投資建議

**整體策略**: [進攻型 / 平衡型 / 防禦型]
**具體建議**:
- [建議1]
- [建議2]

只輸出 Markdown 格式的結果,不要有任何前置說明。
EOF

    # 調用 Ollama
    if ollama run "${OLLAMA_MODEL}" < "${PROMPT_FILE}" 2>/dev/null | sed -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' -e 's/\x1b\[?[0-9;]*[a-zA-Z]//g' -e '/^Thinking\.\.\.$/,/^\.\.\.done thinking\.$/d' > "${SENTIMENT_REPORT}"; then
        echo -e "${GREEN}   ✅ 情緒分析完成${NC}"
        echo -e "${GREEN}   結果已保存至: ${SENTIMENT_REPORT}${NC}"
        echo ""
    else
        echo -e "${RED}   ❌ 情緒分析失敗${NC}"
        exit 1
    fi
}

show_results() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}📄 分析結果${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""

    if [[ -f "${FILTERED_NEWS}" ]]; then
        echo -e "${GREEN}📰 篩選後的新聞: ${FILTERED_NEWS}${NC}"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        head -n 20 "${FILTERED_NEWS}"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        echo ""
    fi

    if [[ -f "${SENTIMENT_REPORT}" ]]; then
        echo -e "${GREEN}😊 市場情緒分析: ${SENTIMENT_REPORT}${NC}"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        head -n 20 "${SENTIMENT_REPORT}"
        echo -e "${BLUE}------------------------------------------------------------${NC}"
        echo ""
    fi

    echo -e "${GREEN}💡 這些結果可以作為 Claude 分析的輸入,降低 token 成本!${NC}"
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
    analyze_news_importance
    analyze_market_sentiment
    show_results
    cleanup

    echo -e "${GREEN}✅ Ollama 新聞分析完成!${NC}"
    echo ""
}

# 執行主程式
main "$@"
