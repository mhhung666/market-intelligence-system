# 已歸檔的文件

此目錄包含已被整合或取代的舊文檔和測試腳本。

## 已整合到新文檔

這些舊文檔的內容已經整合到以下新文檔中：

- **[AUTOMATION_SETUP.md](../AUTOMATION_SETUP.md)** - 自動化設定完整指南（取代所有 CRON_*.md）
- **[LAUNCHD_SETUP.md](../LAUNCHD_SETUP.md)** - macOS launchd 詳細設定（新增）

## 歸檔文件列表

### 文檔
- `CRON_SETUP.md` - 舊 cron 設定說明（已整合）
- `CRON_TEST_STATUS.md` - cron 測試狀態記錄（已過時）
- `FINAL_CRON_SETUP.md` - cron 最終設定（已整合）
- `setup_claude_for_cron.md` - Claude cron 認證說明（已整合）

### 測試腳本
- `debug_cron_env.sh` - cron 環境除錯腳本
- `monitor_claude_test.sh` - Claude 測試監控腳本
- `monitor_cron_test.sh` - cron 測試監控腳本
- `monitor_workflow_test.sh` - 工作流程測試監控腳本
- `test_cron.sh` - cron 測試腳本
- `test_daily_run.sh` - 每日執行測試腳本

## 為什麼歸檔？

1. **文檔重複**：多個 cron 相關文檔內容重複，造成混淆
2. **測試完成**：測試腳本已完成其任務，不再需要
3. **更好的組織**：新文檔結構更清晰，涵蓋所有自動化方案

## 需要這些文件嗎？

如果你需要：
- **設定自動化**：請查看 [AUTOMATION_SETUP.md](../AUTOMATION_SETUP.md) 或 [LAUNCHD_SETUP.md](../LAUNCHD_SETUP.md)
- **測試腳本**：可以參考這些歸檔的腳本，但建議直接使用 `make` 命令
- **歷史記錄**：這些文件保留了之前的設定歷史，可供參考

---

**歸檔日期**：2025-12-08
