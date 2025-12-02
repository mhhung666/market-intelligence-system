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
- **雙報告系統**: 市場分析 + 持倉分析,關注點分離更清晰
- **Claude CLI 深度分析**: 市場趨勢、投資洞察、風險評估 (本機執行)
- **Ollama 快速篩選**: 新聞重要性評估、情緒分析 (本機推論,零成本)
- **雙引擎協作**: 成本優化 - Ollama 預處理 + Claude 深度分析
- **無需 API Key**: 使用 Claude CLI,已登入即可使用

### 3. 自動化流程 ⚙️
- Docker 容器化部署
- Cron 定時任務 (亞洲市場 08:00、美歐市場 21:00)
- 自動生成帶日期的分析報告

## 專案結構

```
market-intelligence-system/
├── src/
│   ├── scrapers/                    # 爬蟲腳本（市場指數/持倉/新聞）
│   ├── scripts/                     # CLI 腳本 (analysis/deployment/tools)
│   └── legacy/                      # Python SDK (保留)
├── config/                          # 指數/持倉/共用設定
├── output/market-data/{YEAR}/       # 爬蟲輸出 (Daily/News/Stocks)
├── reports/markdown/                # 報告輸出 (市場/持倉/情緒)
├── docs/                            # GitHub Pages 靜態網站 (index/market/holdings)
├── tests/                           # 單元測試
├── Makefile                         # 常用工作流
├── CHANGELOG.md                     # 版本更新記錄
├── DEVELOPMENT.md                   # 開發筆記與架構說明
└── QUICKSTART.md                    # 快速開始指南
```

## 🚀 快速開始

> **5 分鐘快速上手** - 詳細請參考 [QUICKSTART.md](QUICKSTART.md)

### 1. 安裝依賴

```bash
# Python 依賴 (爬蟲)
make install

# Claude CLI (分析引擎)
npm install -g @anthropic-ai/claude-cli
claude login  # 登入你的 Claude 帳號

# Ollama (可選,用於成本優化)
# macOS: brew install ollama
# Linux: curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.1:8b
```

### 2. 執行完整分析

```bash
# 一鍵執行: 爬取數據 + Claude 分析
make daily

# 或使用 Ollama 預處理 (降低成本)
make fetch-all && make analyze-all
```

### 3. 查看結果

```bash
# 查看市場分析報告 (全球市場趨勢)
cat reports/markdown/market-analysis-$(date +%Y-%m-%d).md

# 查看持倉分析報告 (投資組合表現)
cat reports/markdown/holdings-analysis-$(date +%Y-%m-%d).md
```

✅ **完成！** 你已經獲得兩份專業的分析報告：市場分析 + 持倉分析。

---

## 📖 詳細文檔

- [QUICKSTART.md](QUICKSTART.md) - 快速開始指南 **← 從這裡開始**
- [src/scripts/README.md](src/scripts/README.md) - CLI 工具詳細說明
- [DEVELOPMENT.md](DEVELOPMENT.md) - 開發路線圖與架構說明
- [CHANGELOG.md](CHANGELOG.md) - 版本更新記錄

---

## ⚙️ 配置說明

### 配置持股清單

編輯 [config/holdings.yaml](config/holdings.yaml):

```yaml
holdings:
  # 美股
  - symbol: AAPL
    name: Apple Inc.

  # 台股 (加 .TW)
  - symbol: 2330.TW
    name: 台積電
```

### 配置全球指數

編輯 [config/indices.yaml](config/indices.yaml):

```yaml
indices:
  taiwan:
    - symbol: ^TWII
      name: 台灣加權指數

  us:
    - symbol: ^GSPC
      name: S&P 500
    - symbol: ^IXIC
      name: Nasdaq
```

---

## 🛠️ 常用命令

### 爬蟲相關

```bash
make fetch-all       # 執行所有爬蟲 (指數 + 持股 + 新聞)
make fetch-global   # 只爬取全球指數
make fetch-holdings # 只爬取持倉價格
make fetch-news     # 只爬取新聞
```

### 分析相關

```bash
make analyze-daily   # Claude CLI 市場分析
make analyze-ollama  # Ollama 新聞預處理 (可選)
make analyze-all     # 完整分析 (Ollama + Claude)
```

### 完整工作流程

```bash
make daily           # 爬取 + Claude 分析 (推薦)
make help            # 顯示所有可用命令
```

---

## 🤖 自動化執行

設定 cron 定時任務:

```bash
# 編輯 crontab
crontab -e

# 每天早上 8:00 執行 (亞洲市場收盤後)
0 8 * * * cd /path/to/market-intelligence-system && make daily >> /tmp/mis.log 2>&1

# 每天晚上 21:00 執行 (美國市場收盤後)
0 21 * * * cd /path/to/market-intelligence-system && make daily >> /tmp/mis.log 2>&1
```

---

## 📊 輸出範例

### 雙報告系統 v2.0

系統會生成兩份獨立的專業分析報告：

#### 1. 市場分析報告 (`market-analysis-YYYY-MM-DD.md`)

專注於全球市場趨勢和新聞：

- 📊 **執行摘要**: 市場概況、關鍵數據、情緒評估
- 🌍 **全球市場深度分析**: 美國、亞洲、歐洲市場表現
- 📰 **重要新聞解讀**: 新聞影響分析與投資啟示
- 🏭 **產業輪動分析**: 資金流向和產業表現
- ⚠️ **風險與機會**: 市場風險識別與投資機會
- 🔮 **後市展望**: 情境分析與關鍵催化劑
- 💡 **投資策略建議**: 短期/中期可執行策略

#### 2. 持倉分析報告 (`holdings-analysis-YYYY-MM-DD.md`)

專注於投資組合和持股表現：

- 💰 **資產配置分析**: 現金/股票比例評估
- 🎯 **選擇權部位分析**: 到期風險管理（12/05、12/19）
- 📈 **持倉表現分析**: 基於成本價、倉位、損益的深度分析
- ⚖️ **倉位結構分析**: 集中度風險評估
- 🎯 **倉位調整建議**: 具體加減碼建議（含價位、股數、資金）
- ⚠️ **風險提示**: 選擇權、倉位、虧損風險
- ✅ **行動清單**: 立即執行、本週執行、持續監控
- 📊 **績效追蹤**: 月度績效與 vs S&P 500

---

## 🐛 故障排除

### Claude CLI 相關

```bash
# 確認安裝
which claude

# 重新登入
claude login

# 測試
echo "Hello" | claude
```

### Ollama 相關

```bash
# 檢查服務
ollama list

# 下載模型
ollama pull llama3.1:8b

# 啟動服務
ollama serve
```

詳細請參考 [src/scripts/README.md](src/scripts/README.md)

## Docker / 部署

Docker 設定尚未隨倉庫提供，建議先使用 Makefile 在本機驗證；若需要容器化可依需求新增 Dockerfile/compose 配置。

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
│ reports/markdown│
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
