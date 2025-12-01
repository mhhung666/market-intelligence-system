# Market Intelligence System (MIS)

市場情報系統 - 自動化市場數據收集與 AI 智能分析平台

## 專案簡介

**Market Intelligence System (MIS)** 是一個完整的市場情報解決方案,結合了:
- **市場數據爬取**: 自動收集全球市場指數、持股價格、市場新聞
- **AI 智能分析**: 使用 Claude 和 Ollama 雙引擎進行深度市場分析
- **自動化報告**: 定時生成市場趨勢分析報告

### 與 FAS (Financial Analysis System) 的區別

| 專案 | MIS (Market Intelligence System) | FAS (Financial Analysis System) |
|------|----------------------------------|----------------------------------|
| **定位** | 市場情報系統 | 財報分析系統 |
| **數據來源** | 市場指數、新聞、價格 | 公司財報、財務報表 |
| **分析重點** | 市場趨勢、技術面、新聞情緒 | 基本面、財務健康度、估值 |
| **輸出** | 市場分析報告、趨勢洞察 | 個股財報分析、投資組合管理 |

## 核心功能

### 1. 市場數據爬取 📊
- 全球主要市場指數 (台灣、美國、日本、香港、中國、韓國、歐洲等)
- 投資組合持倉即時價格
- 批次收集股票和指數市場新聞
- 所有配置均基於 YAML,無需修改程式碼

### 2. AI 智能分析 🤖
- **Claude 深度分析**: 市場趨勢、投資洞察、風險評估
- **Ollama 快速篩選**: 新聞重要性評估、情緒分析、關鍵字提取
- **雙引擎協作**: 成本優化 - 用 Ollama 預處理,Claude 深度分析

### 3. 自動化流程 ⚙️
- Docker 容器化部署
- Cron 定時任務 (亞洲市場 08:00、美歐市場 21:00)
- 自動生成帶日期的分析報告

## 專案結構

```
market-intelligence-system/
├── scrapers/                    # 爬蟲腳本
│   ├── common.py               # 共用模組
│   ├── fetch_global_indices.py # 全球指數爬蟲
│   ├── fetch_holdings_prices.py# 持倉價格爬蟲
│   ├── fetch_market_news.py    # 單一股票/指數新聞爬蟲
│   ├── fetch_all_news.py       # 批次新聞爬蟲
│   └── README.md               # 爬蟲詳細說明
├── analyzers/                   # AI 分析引擎 ⭐ 新增
│   ├── analyzer_base.py        # 抽象基類
│   ├── claude_analyzer.py      # Claude 市場分析器
│   ├── ollama_analyzer.py      # Ollama 市場分析器
│   └── README.md               # 分析引擎說明
├── config/                      # 配置檔案
│   ├── indices.yaml            # 指數配置
│   └── holdings.yaml           # 持倉配置
├── tests/                       # 測試檔案
├── cron/                        # Cron 設定檔
├── output/                      # 爬蟲數據輸出
│   └── market-data/
│       └── {YEAR}/
│           ├── Daily/          # 每日指數數據
│           ├── Stocks/         # 個股歷史數據
│           └── News/           # 新聞數據
├── analysis/                    # AI 分析報告輸出 ⭐ 新增
│   └── market-analysis-{date}.md
├── Makefile                     # Make 快捷指令
├── Dockerfile                   # Docker 映像檔
├── docker-compose.yml          # Docker Compose 配置
├── requirements.txt            # Python 依賴
├── .env.example                # 環境變數範例
└── README.md                   # 本檔案
```

## 快速開始

### 1. 安裝依賴

```bash
# 建立虛擬環境
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# 安裝依賴
pip install -r requirements.txt

# AI 分析引擎依賴
pip install anthropic  # Claude
pip install ollama     # Ollama
```

### 2. 配置環境變數

```bash
cp .env.example .env
```

編輯 `.env`:
```bash
# Claude API Key (用於深度分析)
CLAUDE_API_KEY=sk-ant-...

# Ollama 服務地址 (可選,預設 localhost)
OLLAMA_HOST=http://localhost:11434

# 輸出目錄
OUTPUT_DIR=./output

# 時區
TZ=Asia/Taipei
```

### 3. 執行爬蟲

```bash
# 使用 Makefile
make fetch-all      # 執行所有爬蟲
make fetch-global   # 只爬取全球指數
make fetch-holdings # 只爬取持倉價格
make fetch-news     # 只爬取新聞
```

### 4. 執行 AI 分析

```python
from analyzers import ClaudeAnalyzer, OllamaAnalyzer

# 初始化分析器
claude = ClaudeAnalyzer()
ollama = OllamaAnalyzer()

claude.initialize()
ollama.initialize()

# 分析市場指數
result = claude.analyze_market_indices(
    "output/market-data/2025/Daily/global-indices-2025-12-01.md",
    regions=['美國', '台灣'],
    focus='trend'
)

print(result)
```

詳細使用方法請參考 [analyzers/README.md](analyzers/README.md)

## 使用 Docker

```bash
# 建置映像檔
docker-compose build

# 啟動服務
docker-compose up -d

# 查看日誌
docker-compose logs -f

# 停止服務
docker-compose down
```

## 工作流程

```
┌─────────────────┐
│  定時任務觸發   │ (Cron: 08:00, 21:00)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  爬取市場數據   │ (scrapers/)
│ - 全球指數      │
│ - 持倉價格      │
│ - 市場新聞      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 儲存至 output/  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Ollama 預處理   │ (analyzers/)
│ - 篩選重要新聞  │
│ - 情緒分析      │
│ - 關鍵字提取    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Claude 深度分析 │
│ - 市場趨勢分析  │
│ - 投資洞察      │
│ - 風險評估      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 生成分析報告    │
│ analysis/       │
└─────────────────┘
```

## 配置檔案說明

### config/holdings.yaml

投資組合配置:

```yaml
holdings:
  核心持倉:
    Tesla:
      symbol: "TSLA"
      fetch_news: true    # 是否爬取新聞
      enabled: true       # 是否啟用
      position: 3.4%      # 持倉比例
```

### config/indices.yaml

市場指數配置:

```yaml
global_indices:
  美國:
    S&P 500:
      symbol: "^GSPC"
      fetch_news: true    # 是否爬取新聞
```

## AI 分析引擎

### Claude 分析器
- **用途**: 深度市場分析、投資建議、風險評估
- **成本**: 付費 API (按 token 計費)
- **適合**: 高質量分析、結構化報告

### Ollama 分析器
- **用途**: 大量新聞篩選、情緒分析、快速摘要
- **成本**: 免費 (本地運行)
- **適合**: 預處理、初步篩選

### 雙引擎協作範例

```python
# Step 1: Ollama 快速篩選 100 則新聞 → 10 則重要新聞
important_news = ollama.analyze_market_news(all_news, top_k=10)

# Step 2: Claude 深度分析這 10 則新聞
analysis = claude.analyze_market_news(important_news)

# 成本節省: 只用 Claude 分析 10 則,而非 100 則! (節省 90%)
```

## 技術棧

### 爬蟲層
- Python 3.11+
- yfinance - Yahoo Finance API
- pandas - 資料處理
- pyyaml - 配置解析

### 分析層
- Anthropic Claude API - 深度分析
- Ollama - 本地 LLM 推論
- LangChain (未來計畫)

### 基礎設施
- Docker - 容器化
- Cron - 定時任務
- Git - 版本控制

## 常見問題

### Q: MIS 和 FAS 有什麼區別?

A:
- **MIS**: 專注於市場層面的數據和分析 (指數、新聞、趨勢)
- **FAS**: 專注於公司層面的財報分析 (營收、利潤、估值)
- 兩者互補,可以整合使用

### Q: 需要付費 API 嗎?

A:
- **爬蟲功能**: 完全免費 (使用 Yahoo Finance)
- **AI 分析**:
  - Ollama: 免費 (本地運行,需要 16GB+ RAM)
  - Claude: 付費 (可選,用於高質量分析)

### Q: 如何降低 Claude API 成本?

A: 使用雙引擎協作:
1. 先用 Ollama 篩選重要資料 (免費)
2. 再用 Claude 分析篩選後的資料 (成本降低 80-90%)

### Q: 如何新增要追蹤的股票?

A: 編輯 `config/holdings.yaml`:
```yaml
holdings:
  核心持倉:
    Apple:
      symbol: "AAPL"
      fetch_news: true
      enabled: true
      position: 5.0%
```

無需修改程式碼,重新執行爬蟲即可。

## 未來計畫

- [ ] GitHub Pages 自動發布分析報告
- [ ] Telegram/Discord 通知整合
- [ ] 更多 AI 模型支援 (GPT-4, Gemini)
- [ ] 技術指標分析 (RSI, MACD, 布林通道)
- [ ] 回測系統整合

## 授權

MIT License

## 相關專案

- [Financial Analysis System (FAS)](../financial-analysis-system/) - 財報分析系統

---

*Market Intelligence System - 讓 AI 幫你洞察市場* 🚀
