# 📋 Market Intelligence System (MIS) - 開發路線圖

> 自動化市場數據收集 + AI 智能分析系統

---

## 🎯 專案目標

打造一個完整的市場情報系統,能夠:
1. **自動爬取市場數據** - 全球指數、持股價格、市場新聞
2. **AI 智能分析** - Claude + Ollama 雙引擎深度分析
3. **定時自動化** - Docker + Cron 定時執行
4. **報告自動發布** - 生成 Markdown/HTML 報告並自動提交到 GitHub

---

## 🏗️ 專案架構

```
market-intelligence-system/ (MIS)
├── scrapers/           # 爬蟲層 - 數據收集
├── analyzers/          # 分析層 - AI 智能分析
├── output/             # 原始數據輸出
├── analysis/           # 分析報告輸出
├── config/             # 配置檔案
└── cron/               # 定時任務配置
```

### 與 FAS 的分工

| 專案 | MIS (Market Intelligence System) | FAS (Financial Analysis System) |
|------|----------------------------------|----------------------------------|
| **定位** | 市場情報系統 | 財報分析系統 |
| **數據** | 市場指數、新聞、價格 | 公司財報、財務報表 |
| **分析** | 市場趨勢、技術面、情緒 | 基本面、財務健康度、估值 |

---

## ✅ Phase 0: 專案基礎建設 (已完成)

### 0.1 爬蟲系統獨立化

- [x] **建立獨立專案目錄** ✅
  ```bash
  market-intelligence-system/
  ```

- [x] **複製並重構爬蟲核心** ✅
  - `scrapers/` 目錄 (所有爬蟲腳本) ✅
  - `config/indices.yaml` ✅
  - `config/holdings.yaml` ✅
  - `requirements.txt` ✅
  - 路徑依賴重構 ✅

- [x] **建立分析引擎結構** ✅
  ```
  analyzers/
  ├── analyzer_base.py      # 抽象基類 ✅
  ├── claude_analyzer.py    # Claude 市場分析器 ✅
  ├── ollama_analyzer.py    # Ollama 市場分析器 ✅
  ├── __init__.py           # 模組入口 ✅
  └── README.md            # 文檔 ✅
  ```

- [x] **專案文檔撰寫** ✅
  - `README.md` - 專案總覽 ✅
  - `analyzers/README.md` - 分析引擎說明 ✅
  - `TODO.md` - 本檔案 ✅

---

## 🔵 Phase 1: AI 分析引擎整合 (進行中)

### 1.0 技術選型決策 ✅ 已決定

**最終決定: 使用 Claude CLI + Ollama CLI (本機執行)**

- [x] **已選擇方案 A: Claude CLI + Ollama CLI**

  **優勢**:
  - [x] **無需 API Key** - 直接使用 Claude CLI (已登入)
  - [x] **本機執行** - 通過 Bash 腳本 + Makefile + cronjob
  - [x] **簡單直接** - 純 Bash 腳本,易於維護和調試
  - [x] **成本透明** - Claude CLI 使用同樣計費,但無需管理 token
  - [x] **Ollama 免費** - 本機推論,零 API 成本
  - [x] **易於自動化** - 適合 cron 定時任務

  **實作內容**:
  - `utils/run_daily_analysis_claude_cli.sh` - Claude CLI 市場分析 ✅
  - `utils/run_daily_analysis_ollama_cli.sh` - Ollama 新聞預處理 ✅
  - Makefile targets: `analyze-daily`, `analyze-ollama`, `analyze-all` ✅

  **保留選項 B (Python SDK)** 供未來參考:
  - `analyzers/run_daily_analysis.py` (legacy)
  - `make analyze-daily-python` (需要 CLAUDE_API_KEY)

### 1.1 CLI 分析器測試與驗證

**前置需求**:
```bash
# 安裝 Claude CLI
npm install -g @anthropic-ai/claude-cli
claude login  # 登入你的 Claude 帳號

# 安裝 Ollama (可選,用於成本優化)
# macOS: brew install ollama
# Linux: curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.1:8b  # 或 qwen2.5:14b
```

- [ ] **測試 Claude CLI 分析**
  - 確保已執行 `claude login`
  - 執行 `make analyze-daily` (單獨測試 Claude)
  - 檢視生成的報告: `cat analysis/market-analysis-YYYY-MM-DD.md`
  - 評估報告品質

- [ ] **測試 Ollama 預處理** (可選)
  - 執行 `make analyze-ollama`
  - 檢視篩選後的新聞: `cat analysis/filtered-news-YYYY-MM-DD.md`
  - 檢視情緒分析: `cat analysis/sentiment-analysis-YYYY-MM-DD.md`

- [ ] **測試完整 daily 流程**
  - 執行 `make daily` (爬取 + Claude 分析)
  - 或執行 `make fetch-all && make analyze-all` (爬取 + Ollama + Claude)
  - 確認工作流程順暢

- [ ] **品質評估** (連續執行 3-5 天)
  - 評估報告品質是否符合需求
  - 觀察分析的穩定性和準確性
  - 決定是否需要調整 Prompt

### 1.2 分析腳本開發 ✅ 已完成

- [x] **建立 Claude CLI 分析腳本** ✅
  ```bash
  # utils/run_daily_analysis_claude_cli.sh
  - 讀取市場指數、持股價格、新聞數據
  - 生成完整的分析 Prompt
  - 調用 Claude CLI 進行深度分析
  - 儲存報告到 analysis/market-analysis-YYYY-MM-DD.md
  ```

- [x] **建立 Ollama 預處理腳本** ✅
  ```bash
  # utils/run_daily_analysis_ollama_cli.sh
  - 收集所有當日新聞
  - 使用 Ollama 篩選最重要的 10 則新聞
  - 進行市場情緒分析
  - 儲存結果供 Claude 使用 (降低 token 成本)
  ```

- [x] **整合到 Makefile** ✅
  ```makefile
  make analyze-daily   # Claude CLI 市場分析
  make analyze-ollama  # Ollama 新聞預處理
  make analyze-all     # 完整流程 (Ollama + Claude)
  make daily           # 爬取 + 分析完整工作流程
  ```

---

## 🟢 Phase 2: Docker 化與自動化 (計畫中)

### 2.1 爬蟲服務 Docker 化

- [ ] **建立 Dockerfile**
  - 基於 `python:3.11-slim`
  - 安裝 cron 和依賴
  - 設定時區 (Asia/Taipei)

- [ ] **建立 Cron 設定檔**
  ```
  cron/asia-market.cron:
  0 8 * * * root cd /app && python scrapers/fetch_all.py

  cron/us-market.cron:
  0 21 * * * root cd /app && python scrapers/fetch_all.py
  ```

- [ ] **建立 docker-compose.yml**
  ```yaml
  services:
    crawler:
      build: .
      volumes:
        - ./output:/app/output

    analyzer-ollama:
      image: ollama/ollama:latest
      volumes:
        - ollama-data:/root/.ollama

    analyzer-claude:
      build: ./analyzers
      depends_on:
        - crawler
      environment:
        - CLAUDE_API_KEY=${CLAUDE_API_KEY}
  ```

### 2.2 分析服務 Docker 化

- [ ] **Ollama 容器配置**
  - 使用官方 `ollama/ollama` image
  - 自動下載模型
  - 資源限制設定

- [ ] **Claude 分析器容器化**
  - 建立 `analyzers/Dockerfile`
  - 環境變數配置
  - 依賴安裝

- [ ] **整合測試**
  - 驗證爬蟲 → Ollama → Claude 流程
  - 檢查 volume 掛載正確性
  - 測試 Cron 定時執行

---

## 🟡 Phase 3: 分析品質優化 (未來)

### 3.1 Prompt 工程優化

- [ ] **Claude Prompt 優化**
  - 設計專業的市場分析 prompt
  - 加入結構化輸出要求
  - 測試不同 temperature 參數

- [ ] **Ollama Prompt 優化**
  - 優化新聞重要性評估 prompt
  - 改進情緒分析準確度
  - 測試不同模型 (llama vs qwen)

### 3.2 分析結果驗證

- [ ] **建立品質評估機制**
  - 人工抽樣檢查 (10%)
  - 分析結果一致性驗證
  - A/B 測試不同 prompts

- [ ] **成本與效益分析**
  - 記錄 Claude API token 使用量
  - 計算每日分析成本
  - 優化成本效益比

---

## 🔴 Phase 4: 報告生成與發布 (未來)

### 4.1 HTML 報告生成

- [ ] **建立報告生成器**
  ```
  tools/report_generator/
  ├── templates/          # Jinja2 模板
  ├── generator.py        # Markdown → HTML
  └── chart_builder.py    # Chart.js 圖表
  ```

- [ ] **設計報告模板**
  - 每日市場分析報告
  - 週報
  - 月報

### 4.2 GitHub Pages 自動發布

- [ ] **Git 自動化腳本**
  ```bash
  tools/git_automation/auto_commit.sh
  - 自動 commit 分析報告
  - 自動 push 到 GitHub
  ```

- [ ] **GitHub Actions CI/CD**
  ```yaml
  .github/workflows/deploy.yml
  - 觸發條件: push to main
  - 部署到 GitHub Pages
  ```

---

## 🟣 Phase 5: 進階功能 (未來)

### 5.1 通知機制

- [ ] **Email 通知**
  - 每日分析報告摘要
  - 重要市場事件警報

- [ ] **Telegram/Discord 整合**
  - Webhook 整合
  - 即時推送重要分析

### 5.2 技術指標分析

- [ ] **整合 TA-Lib**
  - RSI, MACD, 布林通道
  - 移動平均線
  - 成交量分析

- [ ] **回測系統**
  - 基於歷史數據回測
  - 策略驗證

---

## 📊 開發時程

### Week 1-2: Phase 1 完成
- [ ] Day 1-3: 分析器測試與驗證
- [ ] Day 4-7: 分析腳本開發與整合

### Week 3-4: Phase 2 完成
- [ ] Day 1-4: Docker 化
- [ ] Day 5-7: 自動化測試與調整

### Week 5-8: Phase 3-4 (根據需求調整)
- [ ] Phase 3: 分析品質優化
- [ ] Phase 4: 報告生成與發布

### Week 9+: Phase 5 (可選)
- [ ] 進階功能開發

---

## 🎯 近期目標 (本週)

1. **測試 Claude 分析器**
   - 設定 API key
   - 執行市場指數分析測試

2. **測試 Ollama 分析器**
   - 安裝 Ollama
   - 下載模型並測試

3. **實作第一個完整分析流程**
   - 讀取最新市場數據
   - 執行雙引擎分析
   - 產出第一份分析報告

---

## 🔗 相關專案

- [Financial Analysis System (FAS)](../financial-analysis-system/) - 財報分析系統 (基本面分析)

---

**專案狀態**: Phase 0 完成 ✅ | Phase 1 進行中 🔵

**最後更新**: 2025-12-01

---

*Market Intelligence System - AI 驅動的市場情報平台* 🚀
