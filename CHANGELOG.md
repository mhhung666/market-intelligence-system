# Changelog

## [v2.0.0] - 2025-12-02
### Added
- 雙報告流程：市場分析 `market-analysis-YYYY-MM-DD.md` 與持倉分析 `holdings-analysis-YYYY-MM-DD.md` 分離
- CLI 腳本移至 `src/scripts/analysis/`，報告輸出改為 `reports/markdown/`
- GitHub Pages 靜態站點集中在 `docs/` (index/market/holdings/styles)
- 新增 `config/settings.yaml` 以集中預設路徑與模型設定

### Changed
- 目錄統一至 `src/`（scrapers/scripts/legacy）並引入 `reports/` 報告目錄
- Makefile 與部署腳本更新為新路徑（Claude/Ollama/Pages）

### Notes
- 若使用 cron 或手動腳本，請更新路徑指向 `src/scripts/...` 與 `reports/markdown/`

## [v1.0.0] - 2025-12-01
### Added
- 決定使用 Claude CLI + Ollama CLI 取代 Python SDK 作為預設分析途徑
- Bash 分析腳本（Claude / Ollama）與 Makefile 目標 (`analyze-*`, `daily`)
- 初版文檔：README、QUICKSTART、utils/README

### Deprecated
- Python SDK 流程標記為 Legacy（仍可透過 `make analyze-daily-python` 執行）
