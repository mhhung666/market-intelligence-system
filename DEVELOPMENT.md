# DEVELOPMENT.md - Market Intelligence System

內部開發筆記，整理最新目錄結構、工作流程與路線圖，取代舊的 TODO.md / SUMMARY.md。

## 路線圖狀態
- ✅ Phase 0: 基礎設置完成（爬蟲、CLI 分析腳本、Makefile 整合）
- 🔵 Phase 1: 架構梳理進行中（統一 src/，報告轉移到 reports/）
- 🎯 待辦焦點
  - 改進分析 Prompt 與輸出品質（Claude / Ollama）
  - 完成 GitHub Pages 流程與自動化
  - 追加測試覆蓋（scrapers/common.py 等核心函式）

## 專案架構（重構後）
```
market-intelligence-system/
├── src/
│   ├── scrapers/              # 爬蟲：市場指數、持倉價格、新聞
│   ├── scripts/
│   │   ├── analysis/          # Bash 分析腳本 (Claude / Ollama)
│   │   ├── deployment/        # GitHub Pages 更新腳本
│   │   └── tools/             # Markdown -> HTML 等工具
│   └── legacy/                # Python SDK (保留給未來需要)
├── config/                    # holdings.yaml, indices.yaml, settings.yaml
├── output/market-data/{YEAR}/ # 爬蟲輸出 (Daily/News/Stocks)
├── reports/markdown/          # 報告輸出 (市場 / 持倉 / 情緒)
├── docs/web/                  # GitHub Pages 靜態站點
├── tests/                     # 單元測試
└── Makefile                   # 常用工作流與自動化
```

## 工作流速覽
- 爬蟲：`make fetch-global` / `make fetch-holdings` / `make fetch-news` / `make fetch-all`
- 分析（CLI）：
  - Claude 雙報告：`./src/scripts/analysis/run_daily_analysis_claude_cli.sh`
  - Ollama 預處理：`./src/scripts/analysis/run_daily_analysis_ollama_cli.sh`
  - 快捷：`make analyze-daily`、`make analyze-ollama`、`make analyze-all`、`make daily`
- 報告位置：`reports/markdown/market-analysis-YYYY-MM-DD.md`、`reports/markdown/holdings-analysis-YYYY-MM-DD.md`
- GitHub Pages：`make update-pages`（生成 docs/web/*.html），`make preview-pages`
- 配置集中：`config/settings.yaml`（預設路徑與模型），`config/*.yaml`（市場/持倉設定）

## Legacy Python SDK（保留）
- 入口：`src/legacy/run_daily_analysis.py`
- 套件：`src/legacy/` (AnalyzerBase, ClaudeAnalyzer, OllamaAnalyzer)
- 執行：`make analyze-daily-python`（需要 CLAUDE_API_KEY）
- 產出：`reports/markdown/market-analysis-YYYY-MM-DD.md`

## 開發者備忘
- 建置：`make venv && make install`
- 測試：`make test`（重點覆蓋 scrapers/common.py）
- 代碼風格：保持 CLI 腳本可執行 (`chmod +x src/scripts/analysis/*.sh src/scripts/deployment/*.sh`)
- 資料輸出：預設寫入 `output/market-data/{YEAR}/...`，可透過 `OUTPUT_DIR` 環境變數覆寫

## 待改進的文檔 / 自動化
- README 與 QUICKSTART：更新路徑與新版架構
- GitHub Pages：確認 `make update-pages` 產出的 HTML 排版與鏈結
- 監控：考慮增加生成報告後的最終檢查（檔案大小/日期提示）

