# Market Intelligence System - 最終 Cron 設定

## ✅ 配置完成

**完成時間**: 2025-12-05 22:41
**狀態**: 已上線運行

---

## 📋 自動化流程

### 完整工作流程
執行腳本: `./run_daily_workflow.sh`

**包含步驟**:
1. **資料抓取與分析** (`make daily`)
   - 抓取全球市場指數
   - 抓取持倉股票價格
   - 抓取市場新聞 (23 個來源)
   - 使用 Claude Sonnet 4.5 進行分析
   - 生成市場分析報告
   - 生成個股分析報告
   - 生成持倉分析報告

2. **更新 GitHub Pages** (`make update-pages`)
   - 將最新報告轉換為 HTML
   - 更新 docs/ 目錄
   - 準備發布到 GitHub Pages

3. **Git Commit** (`make commit-auto`)
   - 自動 commit 新的報告和 pages
   - Commit 訊息格式: `feat(daily): Update analysis reports and GitHub Pages for YYYY-MM-DD`

4. **Push to GitHub** (`make push`)
   - 推送到 GitHub `main` 分支
   - 觸發 GitHub Pages 自動部署

---

## ⏰ 執行排程

### 平日自動執行 (週一到週五)

| 時間 | 說明 | 目的 |
|------|------|------|
| 08:00 | 早上 8 點 | 亞洲市場收盤後,分析隔夜市場 |
| 21:00 | 晚上 9 點 | 美國市場收盤後,分析當日市場 |

### 週末不執行
- **週六** (6): ❌ 不執行
- **週日** (0): ❌ 不執行

理由: 股市週末休市,無新數據

---

## 🔐 認證設定

### Claude Code OAuth Token
- **Token 類型**: Long-lived OAuth Token
- **有效期**: 1 年 (到期日: 2026-12-05)
- **環境變數**: `CLAUDE_CODE_OAUTH_TOKEN`
- **儲存位置**: crontab 環境變數

---

## 📊 Crontab 配置

```cron
# Market Intelligence System - Daily Automation
# 設定環境變數
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin:/Users/mhhung/.local/bin
HOME=/Users/mhhung
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-UutRc... (已隱藏)

# 完整每日工作流程 (平日執行)
# 早上 8:00 - 亞洲市場收盤後 (週一到週五)
0 8 * * 1-5 cd /Users/mhhung/Development/MH/market-intelligence-system && ./run_daily_workflow.sh >> /tmp/mis.log 2>&1

# 晚上 21:00 - 美國市場收盤後 (週一到週五)
0 21 * * 1-5 cd /Users/mhhung/Development/MH/market-intelligence-system && ./run_daily_workflow.sh >> /tmp/mis.log 2>&1
```

**Cron 語法說明**:
- `0 8 * * 1-5`: 分鐘=0, 小時=8, 每天, 每月, 週一到週五
- `1-5`: 1=週一, 2=週二, 3=週三, 4=週四, 5=週五

---

## 📄 相關檔案

### 執行腳本
- **主要腳本**: `./run_daily_workflow.sh`
  - 完整的自動化流程
  - 包含錯誤處理
  - 彩色輸出日誌

### 日誌檔案
- **生產日誌**: `/tmp/mis.log`
  - 記錄所有執行輸出
  - 包含成功和錯誤訊息
  - 每次執行會 append

### 監控腳本
- **環境檢查**: `./test_cron.sh`
- **監控測試**: `./monitor_workflow_test.sh` (測試用)

### 文件
- **Cron 設定**: `./CRON_SETUP.md`
- **認證說明**: `./setup_claude_for_cron.md`
- **測試狀態**: `./CRON_TEST_STATUS.md`
- **本文件**: `./FINAL_CRON_SETUP.md`

---

## 🔍 監控與維護

### 查看執行日誌
```bash
# 即時監控
tail -f /tmp/mis.log

# 查看最近執行
tail -100 /tmp/mis.log

# 搜尋錯誤
grep -i error /tmp/mis.log

# 查看最後執行時間
stat -f "Last executed: %Sm" /tmp/mis.log
```

### 檢查 Crontab
```bash
# 查看當前設定
crontab -l

# 編輯設定
crontab -e

# 檢查 cron daemon
ps aux | grep cron | grep -v grep
```

### 手動執行測試
```bash
# 切換到專案目錄
cd /Users/mhhung/Development/MH/market-intelligence-system

# 執行完整工作流程
./run_daily_workflow.sh

# 或分步執行
make daily           # 只執行分析
make update-pages    # 只更新 Pages
make commit-auto     # 只 commit
make push           # 只 push
```

---

## 📈 輸出結果

### 生成的報告
- **位置**: `reports/markdown/`
- **格式**: Markdown
- **檔案**:
  - `market-analysis-YYYY-MM-DD-HHMM.md` - 市場分析
  - `holdings-analysis-YYYY-MM-DD-HHMM.md` - 持倉分析
  - `stock-{SYMBOL}-YYYY-MM-DD-HHMM.md` - 個股分析 (有近期新聞的持股)

### GitHub Pages
- **URL**: https://{username}.github.io/{repo}/
- **更新時間**: 每次 push 後 1-2 分鐘
- **內容**:
  - `docs/market.html` - 最新市場分析
  - `docs/holdings.html` - 最新持倉分析
  - `docs/index.html` - 首頁

### Git History
- **分支**: `main`
- **Commit 訊息**: `feat(daily): Update analysis reports and GitHub Pages for YYYY-MM-DD`
- **Co-Author**: Claude (AI 輔助生成標記)

---

## ⚠️ 注意事項

### Token 安全
1. ⚠️ OAuth token 存儲在 crontab 中
2. ⚠️ 不要分享 `crontab -l` 的輸出
3. ⚠️ Token 有效期 1 年,需在 2026-12-05 前更新
4. ⚠️ 如需撤銷,執行 `claude setup-token` 重新生成

### Git 操作
1. 確保 Git 遠端 `origin` 已設定
2. 確保有 `main` 分支的 push 權限
3. 如果 commit 失敗,檢查是否有變更
4. 如果 push 失敗,檢查網路和權限

### 資源使用
1. 每次執行約需 **10-20 分鐘**
2. Claude API 呼叫約 **3-5 次** (市場分析 + 持倉分析 + 個股分析)
3. 網路流量約 **10-50 MB** (新聞抓取)

---

## 🔄 更新與修改

### 修改執行時間
```bash
# 編輯 crontab
crontab -e

# 修改時間 (例如改為早上 7:00 和晚上 22:00)
0 7 * * 1-5 cd /Users/mhhung/Development/MH/market-intelligence-system && ./run_daily_workflow.sh >> /tmp/mis.log 2>&1
0 22 * * 1-5 cd /Users/mhhung/Development/MH/market-intelligence-system && ./run_daily_workflow.sh >> /tmp/mis.log 2>&1
```

### 修改工作流程
編輯 `./run_daily_workflow.sh`,可以:
- 新增或移除步驟
- 修改錯誤處理邏輯
- 調整日誌輸出

### 暫時停用
```bash
# 方法 1: 註解掉 crontab 任務
crontab -e
# 在任務前加 #

# 方法 2: 完全移除 crontab
crontab -r

# 方法 3: 重新命名執行腳本
mv run_daily_workflow.sh run_daily_workflow.sh.disabled
```

---

## 📊 執行歷史

### 第一次執行
- **日期**: 下一個平日 08:00 或 21:00
- **預期**: 完整執行所有步驟
- **檢查**: 查看 `/tmp/mis.log` 確認成功

### 後續執行
- **頻率**: 每個工作日 2 次
- **每週**: 10 次 (週一到週五,每天 2 次)
- **每月**: 約 40-44 次

---

## ✅ 檢查清單

### 執行前檢查
- [x] Cron daemon 運行中
- [x] OAuth token 已設定
- [x] 執行腳本有執行權限
- [x] Git 設定正確
- [x] GitHub 連線正常
- [x] Python 虛擬環境已建立

### 執行後檢查 (首次執行後)
- [ ] 日誌檔案已創建 (`/tmp/mis.log`)
- [ ] 報告已生成 (`reports/markdown/`)
- [ ] GitHub Pages 已更新 (`docs/`)
- [ ] Git commit 已創建
- [ ] Push 到 GitHub 成功

---

**建立時間**: 2025-12-05 22:41
**下次執行**: 明天早上 08:00 (如果是工作日) 或 週一 08:00
**狀態**: ✅ 已上線運行
