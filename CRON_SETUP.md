# Cron Job 設定指南

## 📋 概述

自動化執行市場分析並提交報告到 Git：

- **早上 08:00**: 執行分析（美國收盤後的新聞）
- **晚上 20:00**: 執行分析（亞洲收盤後的新聞）

每次執行會：
1. 爬取市場數據（指數、持股、新聞）
2. 生成市場分析報告
3. 生成持倉分析報告
4. 自動 commit markdown 報告到 Git
5. 自動 push 到 GitHub（需要設定認證）

---

## 🚀 快速安裝

### 1. 執行安裝腳本

```bash
cd /Users/mhhung/Development/MH/market-intelligence-system
chmod +x setup_cron.sh
./setup_cron.sh
```

安裝腳本會：
- ✅ 檢查依賴（Python, Make, Claude CLI）
- ✅ 創建 cron 執行腳本
- ✅ 備份現有 crontab
- ✅ 安裝新的 cron 任務

### 2. 確認安裝

查看已安裝的 cron 任務：

```bash
crontab -l
```

你應該會看到：

```
# ============================================================
# Market Intelligence System - 自動化市場分析
# ============================================================
# 早上 08:00 執行 (美國收盤後的新聞)
0 8 * * * /Users/mhhung/Development/MH/market-intelligence-system/run_daily_cron.sh

# 晚上 20:00 執行 (亞洲收盤後的新聞)
0 20 * * * /Users/mhhung/Development/MH/market-intelligence-system/run_daily_cron.sh
# ============================================================
```

---

## 🔧 Git 自動推送設定

### 方法 1: SSH Key（推薦）

如果你還沒設定 SSH key：

```bash
# 1. 生成 SSH key (如果還沒有)
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. 複製公鑰
cat ~/.ssh/id_ed25519.pub

# 3. 添加到 GitHub
# 前往 GitHub Settings > SSH and GPG keys > New SSH key
# 貼上公鑰內容

# 4. 測試連接
ssh -T git@github.com

# 5. 確認專案使用 SSH URL
cd /Users/mhhung/Development/MH/market-intelligence-system
git remote -v

# 如果是 HTTPS URL，改成 SSH URL
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_REPO.git
```

### 方法 2: GitHub CLI

```bash
# 安裝 GitHub CLI
brew install gh

# 登入
gh auth login

# 設定 Git 使用 GitHub CLI
gh auth setup-git
```

### 方法 3: Personal Access Token

```bash
# 1. 前往 GitHub Settings > Developer settings > Personal access tokens
# 2. 生成 token (需要 repo 權限)
# 3. 使用 credential helper 儲存 token

git config --global credential.helper osxkeychain

# 下次 git push 時輸入 token，會自動儲存
```

---

## 📊 監控和測試

### 手動測試執行

在安裝 cron 之前，先測試一次：

```bash
./run_daily_cron.sh
```

### 查看執行日誌

```bash
# 即時查看日誌
tail -f /tmp/market-intelligence-system.log

# 查看完整日誌
cat /tmp/market-intelligence-system.log

# 查看最近 50 行
tail -n 50 /tmp/market-intelligence-system.log
```

### 測試 Git 提交

```bash
# 檢查 Git 狀態
cd /Users/mhhung/Development/MH/market-intelligence-system
git status

# 測試推送（確保認證設定正確）
git push origin main
```

---

## 🛠️ 管理 Cron 任務

### 編輯 Cron 任務

```bash
crontab -e
```

### 移除 Cron 任務

```bash
crontab -e
# 然後刪除 Market Intelligence System 相關的行
```

### 還原備份

如果設定錯誤，可以還原：

```bash
# 查看備份檔案
ls -la /Users/mhhung/Development/MH/market-intelligence-system/crontab.backup.*

# 還原最新的備份
crontab /Users/mhhung/Development/MH/market-intelligence-system/crontab.backup.XXXXXXXXX
```

### 暫時停用

```bash
# 編輯 crontab
crontab -e

# 在任務前加上 # 註解
# 0 8 * * * /path/to/run_daily_cron.sh
# 0 20 * * * /path/to/run_daily_cron.sh
```

---

## ⚙️ Cron 時間說明

當前設定：

```
0 8 * * *   # 每天早上 08:00
0 20 * * *  # 每天晚上 20:00
```

### 修改執行時間

編輯 `setup_cron.sh` 中的這兩行：

```bash
# 格式: 分 時 日 月 星期
# 範例:
# 0 8 * * *    - 每天 08:00
# 30 20 * * *  - 每天 20:30
# 0 8,20 * * * - 每天 08:00 和 20:00
# 0 8 * * 1-5  - 週一到週五 08:00
```

---

## 📝 工作流程

每次 cron 執行時的完整流程：

```
1. 啟動任務 → 記錄日誌
2. 執行 make daily
   ├── fetch-all (爬取市場數據)
   │   ├── fetch-global (全球指數)
   │   ├── fetch-holdings (持股價格)
   │   └── fetch-news (市場新聞)
   └── analyze-daily (生成分析報告)
       ├── market-analysis-YYYY-MM-DD.md
       └── holdings-analysis-YYYY-MM-DD.md
3. Git 提交
   ├── git add reports/markdown/*.md
   ├── git commit -m "feat(daily): Update analysis reports..."
   └── git push origin main (如果設定認證)
4. 完成 → 記錄日誌
```

---

## 🔍 故障排除

### Cron 沒有執行

1. **檢查 cron 服務是否運行**:
   ```bash
   # macOS cron 服務應該默認運行
   ps aux | grep cron
   ```

2. **檢查日誌**:
   ```bash
   tail -f /tmp/market-intelligence-system.log
   ```

3. **確認腳本權限**:
   ```bash
   ls -la /Users/mhhung/Development/MH/market-intelligence-system/run_daily_cron.sh
   # 應該有 x (執行) 權限
   ```

### Git 推送失敗

1. **檢查認證設定**:
   ```bash
   ssh -T git@github.com
   # 或
   git push origin main
   ```

2. **查看錯誤訊息**:
   ```bash
   grep "Git 推送失敗" /tmp/market-intelligence-system.log
   ```

3. **暫時禁用自動推送**:
   編輯 `run_daily_cron.sh`，註解掉推送部分：
   ```bash
   # if git -C "${PROJECT_ROOT}" push origin main >> "${LOG_FILE}" 2>&1; then
   #     log "✅ Git 推送成功!"
   # else
   #     log "⚠️  Git 推送失敗 (可能需要手動推送或設定認證)"
   # fi
   ```

### Claude CLI 錯誤

1. **檢查 Claude CLI 是否已登入**:
   ```bash
   claude --version
   echo "test" | claude
   ```

2. **重新登入**:
   ```bash
   claude login
   ```

### Python 環境問題

1. **檢查虛擬環境**:
   ```bash
   ls -la /Users/mhhung/Development/MH/market-intelligence-system/.venv
   ```

2. **重新安裝依賴**:
   ```bash
   cd /Users/mhhung/Development/MH/market-intelligence-system
   make clean-venv
   make install
   ```

---

## 📧 通知設定（可選）

### macOS 桌面通知

在 `run_daily_cron.sh` 中添加：

```bash
# 成功通知
osascript -e 'display notification "市場分析報告已生成!" with title "Market Intelligence System"'

# 失敗通知
osascript -e 'display notification "執行失敗，請檢查日誌" with title "Market Intelligence System" sound name "Basso"'
```

### Email 通知（需要 mailx）

```bash
# 安裝 mailx
brew install mailutils

# 在腳本中添加
echo "分析完成" | mail -s "Market Intelligence Report" your@email.com
```

---

## 🎯 最佳實踐

1. **定期檢查日誌**: 每週查看一次日誌，確保正常運行
2. **測試後再部署**: 先手動執行 `./run_daily_cron.sh` 確認無誤
3. **保留備份**: 定期備份生成的報告
4. **監控 Git 提交**: 確認報告有正常提交到 GitHub
5. **更新 Claude CLI**: 定期更新到最新版本

---

## 📚 相關命令參考

```bash
# 查看 crontab
crontab -l

# 編輯 crontab
crontab -e

# 移除所有 cron 任務
crontab -r

# 手動執行
./run_daily_cron.sh

# 查看日誌
tail -f /tmp/market-intelligence-system.log

# 測試 Git 推送
cd /Users/mhhung/Development/MH/market-intelligence-system && git push

# 檢查最新報告
ls -lt reports/markdown/

# 查看最新市場分析
cat reports/markdown/market-analysis-$(date +%Y-%m-%d).md
```

---

**祝你使用愉快！如有問題請查看日誌或手動測試執行。** 🚀
