# 使用指南 - Market Intelligence System AI 分析器

## 快速開始

### 1. 設定環境變數

建立 `.env` 檔案並設定 Claude API Key:

```bash
# 在專案根目錄
cp .env.example .env

# 編輯 .env 並加入你的 API Key
export CLAUDE_API_KEY="sk-ant-..."
```

### 2. 安裝依賴

```bash
# 安裝 AI 分析器依賴
pip install anthropic  # Claude
pip install ollama     # Ollama (可選)
```

### 3. 執行每日分析

#### 方法一: 使用 Makefile (推薦)

```bash
# 完整每日流程 (爬取 + 分析)
make daily

# 只執行分析 (需要先有數據)
make analyze-daily
```

#### 方法二: 直接執行 Python 腳本

```bash
# 先爬取數據
python3 scrapers/fetch_global_indices.py
python3 scrapers/fetch_holdings_prices.py
python3 scrapers/fetch_all_news.py

# 再執行分析
python3 analyzers/run_daily_analysis.py
```

## 工作流程

```
┌─────────────────┐
│  make daily     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  爬取市場數據   │
│  - 全球指數     │
│  - 持股價格     │
│  - 市場新聞     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Claude AI 分析  │
│  - 市場趨勢     │
│  - 持股表現     │
│  - 新聞解讀     │
│  - 投資建議     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 生成分析報告    │
│ analysis/       │
│ market-analysis-│
│ 2025-12-01.md   │
└─────────────────┘
```

## 輸出範例

執行完成後,會在 `analysis/` 目錄生成報告:

```
analysis/
└── market-analysis-2025-12-01.md
```

報告包含:
- 📊 執行摘要 (市場概況、關鍵數據、風險評估)
- 🌍 全球市場分析 (美股、亞股、歐股)
- 💼 持倉股票分析 (表現評估、操作建議)
- 📰 重要新聞解讀 (深度分析、影響評估)
- ⚠️ 風險與機會 (市場風險、投資機會)
- 💡 投資策略建議 (短期、中長期)
- 🔮 後市展望 (催化劑、情境分析)
- ✅ 行動清單 (具體執行步驟)

## Token 使用統計

分析完成後會顯示 Claude API token 使用量:

```
📊 Token 使用統計:
   Input: 12,345 tokens
   Output: 8,901 tokens
   Total: 21,246 tokens
```

**成本估算** (以 Claude Sonnet 為例):
- Input: ~$0.037 / 1K tokens
- Output: ~$0.185 / 1K tokens
- 單次分析成本: 約 $2-3 USD

## 雙引擎協作 (Ollama + Claude)

未來版本將整合 Ollama 進行預處理,降低成本:

```python
# 1. Ollama 快速篩選重要新聞 (免費)
important_news = ollama.analyze_market_news(all_news, top_k=10)

# 2. Claude 深度分析篩選後的新聞 (付費)
analysis = claude.analyze_market_news(important_news)

# 成本節省: 90%
```

## 自訂分析

### 修改 Prompt

編輯 `run_daily_analysis.py` 中的 `generate_market_analysis_prompt()` 方法:

```python
def generate_market_analysis_prompt(self, news_files: List[Path]) -> str:
    # 自訂你的 Prompt
    prompt = """你是一位專業的市場分析師...

    ## 自訂分析重點:
    - 重點1
    - 重點2
    ...
    """
    return prompt
```

### 調整 Claude 參數

```python
result = self.claude._call_claude(
    system_prompt="...",
    user_prompt=prompt,
    max_tokens=8192,      # 調整最大 tokens
    temperature=0.7       # 調整創造性 (0-1)
)
```

## 常見問題

### Q: 分析失敗,提示找不到資料檔案?

A: 先執行爬蟲:
```bash
make fetch-all
```

### Q: Claude API 調用失敗?

A: 檢查:
1. API Key 是否正確設定
2. 網路連線是否正常
3. API 配額是否充足

### Q: 如何降低成本?

A:
1. 減少 `max_tokens` (但可能截斷報告)
2. 只分析重要持股 (修改配置檔)
3. 等待 Ollama 整合版本 (預處理)

### Q: 報告格式不符合預期?

A: 調整 Prompt 中的報告結構模板,或參考 FAS 的模板設計。

## 進階使用

### 程式化調用

```python
from analyzers import ClaudeAnalyzer

# 初始化
analyzer = ClaudeAnalyzer()
analyzer.initialize()

# 分析特定市場指數
result = analyzer.analyze_market_indices(
    "output/market-data/2025/Daily/global-indices-2025-12-01.md",
    regions=['美國', '台灣'],
    focus='trend'
)

print(result)
```

### 批次分析歷史數據

```python
from pathlib import Path

for indices_file in Path("output/market-data/2025/Daily").glob("global-indices-*.md"):
    result = analyzer.analyze_market_indices(str(indices_file))
    # 處理結果...
```

## 相關資源

- [Claude API 文檔](https://docs.anthropic.com/)
- [分析器 API 參考](README.md)
- [FAS 分析系統](../../financial-analysis-system/)

---

**Market Intelligence System** - AI 驅動的市場情報平台 🚀
