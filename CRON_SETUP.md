# Cron 設定說明

## 當前設定

系統已配置每日自動執行市場分析任務:

- **早上 08:00** - 亞洲市場收盤後執行
- **晚上 21:00** - 美國市場收盤後執行

## 設定狀態

✅ **2025-12-05 更新**: Crontab 已配置並修正環境變數問題
- Cron daemon 運行中
- 環境變數已正確設定 (PATH, HOME, SHELL)
- Claude CLI 可正常執行

## Crontab 配置

```bash
# 查看當前 crontab
crontab -l

# 編輯 crontab
crontab -e

# 刪除 crontab
crontab -r
```

### 當前 Crontab 內容

```cron
# Market Intelligence System - Daily Analysis
# 設定環境變數
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin:/Users/mhhung/.local/bin
HOME=/Users/mhhung

# 每天早上 8:00 執行 (亞洲市場收盤後)
0 8 * * * cd /Users/mhhung/Development/MH/market-intelligence-system && /usr/bin/make daily >> /tmp/mis.log 2>&1

# 每天晚上 21:00 執行 (美國市場收盤後)
0 21 * * * cd /Users/mhhung/Development/MH/market-intelligence-system && /usr/bin/make daily >> /tmp/mis.log 2>&1
```

**重要設定說明**:
- `SHELL=/bin/bash`: 確保使用 bash shell
- `PATH`: 包含 `/Users/mhhung/.local/bin` 以便找到 claude CLI
- `HOME`: 設定 HOME 目錄,讓 Claude CLI 可以讀取配置

## 監控與除錯

### 查看執行日誌
```bash
# 即時監控日誌
tail -f /tmp/mis.log

# 查看最近的日誌
tail -50 /tmp/mis.log

# 搜尋錯誤訊息
grep -i error /tmp/mis.log
```

### 測試 Cron 設定
```bash
# 執行環境檢查測試
./test_cron.sh

# 完整測試 daily workflow (模擬 cron 環境)
./test_daily_run.sh

# 手動執行一次完整流程
cd /Users/mhhung/Development/MH/market-intelligence-system
make daily
```

## 執行內容

每次 cron 任務會執行 `make daily`，包含:

1. **資料抓取** (`make fetch-all`)
   - 全球市場指數
   - 持倉股票價格
   - 相關新聞

2. **市場分析** (`make analyze-daily`)
   - 使用 Claude CLI 進行深度分析
   - 生成分析報告

## 常見問題

### Cron 沒有執行?

1. 檢查 cron daemon 是否運行:
   ```bash
   ps aux | grep -i cron | grep -v grep
   ```

2. 檢查 crontab 設定:
   ```bash
   crontab -l
   ```

3. 查看系統日誌:
   ```bash
   # macOS
   log show --predicate 'process == "cron"' --last 1h
   ```

### 執行失敗?

1. 檢查日誌: `tail -f /tmp/mis.log`
2. 手動測試: `make daily`
3. 檢查環境變數: 確保 Python、Make 等工具在 PATH 中

### 修改執行時間

編輯 crontab:
```bash
crontab -e
```

Cron 時間格式:
```
分 時 日 月 週
0  8  *  *  *   # 每天 08:00
0  21 *  *  *   # 每天 21:00
*/30 * * * *    # 每 30 分鐘
0  */6 * * *    # 每 6 小時
```

## 停用 Cron 任務

```bash
# 方法 1: 刪除整個 crontab
crontab -r

# 方法 2: 編輯並註解掉特定任務
crontab -e
# 在任務前加 # 註解
```

## 相關檔案

- Crontab 設定: `/var/at/tabs/mhhung` (使用 `crontab -l` 查看)
- 執行日誌: `/tmp/mis.log`
- 環境檢查腳本: `./test_cron.sh`
- 完整測試腳本: `./test_daily_run.sh`
- 除錯腳本: `./debug_cron_env.sh`
- Makefile: `./Makefile`

## 已知問題與解決方案

### 問題 1: Claude CLI 在 cron 環境下無法執行

**症狀**: Cron 任務執行到市場分析時失敗,日誌顯示 "❌ 市場分析失敗"

**原因**: Cron 執行時缺少完整的用戶環境變數,導致無法找到 claude CLI 或讀取配置

**解決方案**: 在 crontab 中明確設定環境變數
```cron
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin:/Users/mhhung/.local/bin
HOME=/Users/mhhung
```

### 問題 2: 資料抓取成功但分析失敗

**診斷步驟**:
1. 檢查日誌: `tail -50 /tmp/mis.log`
2. 測試 Claude CLI: `echo "test" | ~/.local/bin/claude`
3. 手動執行分析: `cd market-intelligence-system && make analyze-daily`

## 下次執行時間

下次自動執行:
- 明天早上 **08:00**
- 今晚/明晚 **21:00**

查看最近的執行記錄:
```bash
stat -f "Last executed: %Sm" /tmp/mis.log
```
