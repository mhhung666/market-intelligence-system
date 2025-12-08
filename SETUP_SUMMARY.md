# 自動化設定總結

**完成時間**：2025-12-08
**狀態**：✅ 文檔已整理完成，等待你回到 Mac 上設定

---

## 已完成的工作

### 1. 研究 macOS launchd ✅

深入研究了 launchd 的所有功能：
- 為什麼 launchd 優於 cron
- 完整的 plist 語法和欄位說明
- 載入、管理、除錯的所有命令
- 常見問題和最佳實踐

### 2. 創建完整文檔 ✅

創建了兩個新文檔：

#### [LAUNCHD_SETUP.md](LAUNCHD_SETUP.md)
- **目的**：macOS launchd 詳細設定指南
- **內容**：
  - 快速開始（複製即用的 plist 範例）
  - 完整的欄位說明
  - 管理命令速查
  - 日誌查看和除錯技巧
  - 測試流程
  - 從 cron 遷移指南
- **長度**：約 12KB，非常詳細

#### [AUTOMATION_SETUP.md](AUTOMATION_SETUP.md)
- **目的**：自動化方案完整比較與選擇指南
- **內容**：
  - 三種方案比較表（launchd / Docker / cron）
  - 每種方案的完整設定步驟
  - 監控與維護
  - 故障排除
  - 常用命令速查
- **長度**：約 7.5KB

### 3. 整理舊文檔 ✅

已歸檔的文件（移到 `archive/` 目錄）：

**舊文檔**：
- `CRON_SETUP.md`
- `CRON_TEST_STATUS.md`
- `FINAL_CRON_SETUP.md`
- `setup_claude_for_cron.md`

**測試腳本**：
- `debug_cron_env.sh`
- `monitor_claude_test.sh`
- `monitor_cron_test.sh`
- `monitor_workflow_test.sh`
- `test_cron.sh`
- `test_daily_run.sh`

### 4. 更新主文檔 ✅

更新了 [README.md](README.md)：
- 核心功能說明中加入三種自動化方案
- 自動化執行章節完全重寫
- 引導到新的文檔

---

## 晚上回到 Mac 後的設定步驟

### 選項 A: 使用 launchd（推薦）

```bash
# 1. 進入專案目錄
cd ~/Development/MH/market-intelligence-system

# 2. 打開 LAUNCHD_SETUP.md
open LAUNCHD_SETUP.md

# 3. 按照「快速開始」章節設定
# 主要步驟：
#   - 創建 ~/Library/LaunchAgents/com.market-intelligence.daily.plist
#   - 替換 YOUR_USERNAME 和 YOUR_OAUTH_TOKEN_HERE
#   - 載入：launchctl load -w ~/Library/LaunchAgents/com.market-intelligence.daily.plist
#   - 驗證：launchctl list | grep market-intelligence

# 4. 測試執行
launchctl start com.market-intelligence.daily

# 5. 查看日誌
tail -f ~/logs/market-intelligence.log
```

### 選項 B: 使用 Docker cron

```bash
# 1. 設定環境變數
cp .env.docker .env
nano .env  # 填入 CLAUDE_TOKEN

# 2. 啟動 Docker cron
make docker-cron-up

# 3. 查看日誌
docker-compose logs -f mis-cron
```

### 選項 C: 比較所有方案後再決定

```bash
# 打開完整指南
open AUTOMATION_SETUP.md
```

---

## 重要提醒

### 需要準備的資訊

1. **你的 macOS 使用者名稱**
   ```bash
   whoami
   ```

2. **Claude OAuth Token**
   ```bash
   cat ~/.config/claude/credentials.json
   ```
   找到 `accessToken` 欄位

3. **專案完整路徑**
   ```bash
   pwd  # 在專案目錄執行
   ```

### 設定檢查清單

使用 launchd 時：
- [ ] 創建 plist 檔案
- [ ] 替換所有 `YOUR_USERNAME`
- [ ] 替換 `YOUR_OAUTH_TOKEN_HERE`
- [ ] 創建日誌目錄 `mkdir -p ~/logs`
- [ ] 載入 plist
- [ ] 驗證載入成功
- [ ] 測試執行
- [ ] 查看日誌確認成功

使用 Docker 時：
- [ ] 設定 `.env` 檔案
- [ ] 建立 Docker image
- [ ] 啟動 cron 服務
- [ ] 查看日誌確認運行

---

## 文檔結構

```
market-intelligence-system/
├── AUTOMATION_SETUP.md      ← 【新】自動化完整指南
├── LAUNCHD_SETUP.md          ← 【新】launchd 詳細設定
├── README.md                 ← 【已更新】引導到新文檔
├── QUICKSTART.md             ← 快速開始
├── docker/
│   └── README.md             ← Docker 部署指南
└── archive/                  ← 【新】已歸檔的舊文檔
    ├── README.md             ← 歸檔說明
    ├── CRON_*.md             ← 舊 cron 文檔
    └── *.sh                  ← 測試腳本
```

---

## 為什麼選擇 launchd？

1. **Apple 官方推薦**：cron 在新版 macOS 已被標記為 legacy
2. **更可靠**：系統重啟後自動恢復
3. **補執行機制**：Mac 休眠錯過的任務會在喚醒後執行
4. **更好的日誌**：StandardOutPath/StandardErrorPath 更容易除錯
5. **原生整合**：與 macOS 系統更好的整合

---

## 快速參考

### launchd 常用命令

```bash
# 載入
launchctl load -w ~/Library/LaunchAgents/com.market-intelligence.daily.plist

# 卸載
launchctl unload ~/Library/LaunchAgents/com.market-intelligence.daily.plist

# 查看狀態
launchctl list | grep market-intelligence

# 手動執行
launchctl start com.market-intelligence.daily

# 查看日誌
tail -f ~/logs/market-intelligence.log

# 重新載入（修改 plist 後）
launchctl unload ~/Library/LaunchAgents/com.market-intelligence.daily.plist && \
launchctl load -w ~/Library/LaunchAgents/com.market-intelligence.daily.plist
```

### Docker 常用命令

```bash
# 啟動 cron
docker-compose --profile cron up -d

# 停止
docker-compose down

# 查看日誌
docker-compose logs -f mis-cron

# 手動執行
docker-compose exec mis make daily
```

---

## 需要幫助？

查看對應的文檔：

- **launchd 設定**：[LAUNCHD_SETUP.md](LAUNCHD_SETUP.md)
- **方案比較**：[AUTOMATION_SETUP.md](AUTOMATION_SETUP.md)
- **Docker 部署**：[docker/README.md](docker/README.md)
- **舊文檔歸檔說明**：[archive/README.md](archive/README.md)

---

**準備好了嗎？**

晚上回到 Mac 後，從 [LAUNCHD_SETUP.md](LAUNCHD_SETUP.md) 的「快速開始」章節開始！

整個設定過程大約 **5-10 分鐘**即可完成。

---

**建立時間**：2025-12-08
**下次更新**：設定完成後記錄實際執行結果
