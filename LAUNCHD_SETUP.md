# macOS launchd 自動化設定指南

## 為什麼使用 launchd 而非 cron？

在 macOS 上，**launchd** 是 Apple 官方推薦的任務排程系統，相比 cron 有以下優勢：

- **自動執行錯過的任務**：如果 Mac 在排程時間休眠，launchd 會在喚醒後執行任務（cron 會直接跳過）
- **更好的系統整合**：原生 macOS 服務，重啟後自動恢復
- **完整的日誌管理**：更容易除錯和監控
- **官方支援**：cron 在新版 macOS 已被標記為 legacy，需要特別啟用

---

## 快速開始

### 方案選擇：環境變數設定方式

你可以選擇以下兩種方式之一來設定環境變數（推薦方案 A）：

#### 方案 A: 使用 .env 檔案（推薦）✅

**優點**：
- Token 不會出現在 plist 中，更安全
- 可以被 `.gitignore` 排除，不會意外提交到 Git
- 與手動執行時的環境一致
- 更新 token 只需修改 `.env`，不用重新載入 plist

**設定步驟**：

1. 創建 `.env` 檔案：
   ```bash
   cd ~/Development/MH/market-intelligence-system
   cp .env.example.local .env
   nano .env
   ```

2. 填入你的 token：
   ```bash
   CLAUDE_TOKEN=你的token內容
   TZ=Asia/Taipei
   ```

3. 使用簡化版 plist（見下方範例）

#### 方案 B: 在 plist 中直接設定

**優點**：
- 設定集中在一個檔案
- 不依賴 `.env` 檔案

**缺點**：
- Token 明文存在 plist 中
- 更新 token 需要重新載入 plist

### 1. 創建 plist 檔案

在 `~/Library/LaunchAgents/` 創建你的排程檔案：

```bash
nano ~/Library/LaunchAgents/com.market-intelligence.daily.plist
```

### 2. 完整設定範例

#### 方案 A: 使用 .env 檔案（推薦）

腳本會自動從 `.env` 讀取 token，plist 只需設定 PATH：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.market-intelligence.daily</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>/Users/YOUR_USERNAME/Development/MH/market-intelligence-system/run_daily_workflow.sh</string>
  </array>

  <key>WorkingDirectory</key>
  <string>/Users/YOUR_USERNAME/Development/MH/market-intelligence-system</string>

  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/usr/local/bin:/usr/bin:/bin:/Users/YOUR_USERNAME/.local/bin</string>
  </dict>

  <key>StandardOutPath</key>
  <string>/Users/YOUR_USERNAME/logs/market-intelligence.log</string>

  <key>StandardErrorPath</key>
  <string>/Users/YOUR_USERNAME/logs/market-intelligence-error.log</string>

  <key>StartCalendarInterval</key>
  <array>
    <!-- 週一到週五 早上 8:00 -->
    <dict>
      <key>Weekday</key>
      <integer>1</integer>
      <key>Hour</key>
      <integer>8</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Weekday</key>
      <integer>2</integer>
      <key>Hour</key>
      <integer>8</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Weekday</key>
      <integer>3</integer>
      <key>Hour</key>
      <integer>8</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Weekday</key>
      <integer>4</integer>
      <key>Hour</key>
      <integer>8</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Weekday</key>
      <integer>5</integer>
      <key>Hour</key>
      <integer>8</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <!-- 週一到週五 晚上 21:00 (9:00 PM) -->
    <dict>
      <key>Weekday</key>
      <integer>1</integer>
      <key>Hour</key>
      <integer>21</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Weekday</key>
      <integer>2</integer>
      <key>Hour</key>
      <integer>21</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Weekday</key>
      <integer>3</integer>
      <key>Hour</key>
      <integer>21</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Weekday</key>
      <integer>4</integer>
      <key>Hour</key>
      <integer>21</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <dict>
      <key>Weekday</key>
      <integer>5</integer>
      <key>Hour</key>
      <integer>21</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
  </array>
</dict>
</plist>
```

**重要**：請替換以下內容：
- `YOUR_USERNAME` → 你的 macOS 使用者名稱
- `YOUR_OAUTH_TOKEN_HERE` → 你的 Claude OAuth token

### 3. 創建日誌目錄

```bash
mkdir -p ~/logs
```

### 4. 設定檔案權限

```bash
chmod 644 ~/Library/LaunchAgents/com.market-intelligence.daily.plist
```

### 5. 載入並啟用

```bash
launchctl load -w ~/Library/LaunchAgents/com.market-intelligence.daily.plist
```

### 6. 驗證載入成功

```bash
launchctl list | grep market-intelligence
```

應該會看到類似：
```
-       0       com.market-intelligence.daily
```

---

## 管理命令

### 查看所有任務

```bash
launchctl list
```

### 查看特定任務

```bash
launchctl list | grep market-intelligence
```

### 重新載入（修改 plist 後）

```bash
launchctl unload ~/Library/LaunchAgents/com.market-intelligence.daily.plist
launchctl load -w ~/Library/LaunchAgents/com.market-intelligence.daily.plist
```

### 停用任務

```bash
launchctl unload -w ~/Library/LaunchAgents/com.market-intelligence.daily.plist
```

### 手動觸發執行（測試用）

```bash
launchctl start com.market-intelligence.daily
```

---

## 查看日誌

### 即時監控執行日誌

```bash
tail -f ~/logs/market-intelligence.log
```

### 查看錯誤日誌

```bash
tail -f ~/logs/market-intelligence-error.log
```

### 查看最近 50 行日誌

```bash
tail -50 ~/logs/market-intelligence.log
```

### 搜尋錯誤

```bash
grep -i error ~/logs/market-intelligence.log
```

---

## 除錯技巧

### 1. 測試模式：立即執行

在 plist 中暫時加入：

```xml
<key>RunAtLoad</key>
<true/>
```

然後重新載入，任務會立即執行一次。

### 2. 檢查檔案權限

```bash
ls -la ~/Library/LaunchAgents/com.market-intelligence.daily.plist
```

應該是：
```
-rw-r--r--  1 yourusername  staff  ...
```

### 3. 驗證 XML 格式

```bash
plutil -lint ~/Library/LaunchAgents/com.market-intelligence.daily.plist
```

### 4. 啟用系統日誌

```bash
launchctl log level debug
```

---

## 常見問題

### Q: 為什麼任務沒有執行？

**檢查清單**：

1. 確認任務已載入：
   ```bash
   launchctl list | grep market-intelligence
   ```

2. 檢查日誌檔案是否存在：
   ```bash
   ls -l ~/logs/market-intelligence*.log
   ```

3. 驗證腳本路徑正確：
   ```bash
   ls -l /Users/YOUR_USERNAME/Development/MH/market-intelligence-system/run_daily_workflow.sh
   ```

4. 確認腳本有執行權限：
   ```bash
   chmod +x run_daily_workflow.sh
   ```

### Q: 如何測試不等到排程時間？

使用 `RunAtLoad` 或手動啟動：

```bash
launchctl start com.market-intelligence.daily
```

### Q: 環境變數有設定但還是不生效？

launchd 不會讀取 `.bashrc` 或 `.zshrc`，必須在 plist 的 `EnvironmentVariables` 中明確設定。

### Q: 如何獲取 Claude OAuth Token？

執行：
```bash
cat ~/.config/claude/credentials.json
```

找到 `accessToken` 欄位的值。

---

## plist 重要欄位說明

| 欄位 | 說明 | 必填 |
|------|------|------|
| `Label` | 唯一識別名稱（reverse domain 格式） | 是 |
| `ProgramArguments` | 執行的程式和參數（第一個是程式路徑） | 是 |
| `WorkingDirectory` | 工作目錄 | 否 |
| `EnvironmentVariables` | 環境變數（包含 PATH、tokens 等） | 否 |
| `StandardOutPath` | 標準輸出日誌路徑 | 否 |
| `StandardErrorPath` | 錯誤日誌路徑 | 否 |
| `StartCalendarInterval` | 排程時間（可為陣列） | 否 |
| `RunAtLoad` | 載入時立即執行 | 否 |

### StartCalendarInterval 時間設定

- `Weekday`：0-7（0 和 7 都是星期日，1=週一...5=週五）
- `Hour`：0-23（24 小時制）
- `Minute`：0-59
- `Day`：1-31（月份中的日期）
- `Month`：1-12

**注意**：省略的欄位會被視為「任意值」（萬用字元）

---

## 完整測試流程

### 1. 創建測試腳本

```bash
cat > ~/test_workflow.sh << 'EOF'
#!/bin/bash
echo "=== Test started at $(date) ==="
echo "Current directory: $(pwd)"
echo "User: $(whoami)"
echo "PATH: $PATH"
echo "=== Test completed ==="
EOF

chmod +x ~/test_workflow.sh
```

### 2. 創建測試 plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.test.workflow</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>/Users/YOUR_USERNAME/test_workflow.sh</string>
  </array>

  <key>StandardOutPath</key>
  <string>/Users/YOUR_USERNAME/logs/test.log</string>

  <key>StandardErrorPath</key>
  <string>/Users/YOUR_USERNAME/logs/test_error.log</string>

  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
```

### 3. 載入並測試

```bash
# 創建日誌目錄
mkdir -p ~/logs

# 載入測試任務
launchctl load ~/Library/LaunchAgents/com.test.workflow.plist

# 等待幾秒後查看日誌
sleep 3
cat ~/logs/test.log
```

### 4. 清理測試

```bash
launchctl unload ~/Library/LaunchAgents/com.test.workflow.plist
rm ~/Library/LaunchAgents/com.test.workflow.plist
rm ~/test_workflow.sh
```

---

## 從 cron 遷移

### 原 crontab 設定

```cron
0 8 * * 1-5 cd /path/to/project && ./run_daily_workflow.sh
0 21 * * 1-5 cd /path/to/project && ./run_daily_workflow.sh
```

### 對應的 launchd 設定

已在上面的「完整設定範例」中提供，主要差異：

1. **時間格式**：cron 用 `1-5` 表示週一到週五，launchd 需要 5 個獨立的 dict
2. **環境變數**：cron 繼承部分 shell 環境，launchd 需要明確設定
3. **工作目錄**：cron 用 `cd`，launchd 用 `WorkingDirectory`
4. **日誌**：cron 用 `>>`，launchd 用 `StandardOutPath`

---

## 進階設定

### 條件性執行（只在網路連線時執行）

```xml
<key>StartOnMount</key>
<true/>
```

### 監控檔案變更

```xml
<key>WatchPaths</key>
<array>
  <string>/path/to/watch</string>
</array>
```

### 保持常駐（服務模式）

```xml
<key>KeepAlive</key>
<true/>
```

### 資源限制

```xml
<key>SoftResourceLimits</key>
<dict>
  <key>NumberOfFiles</key>
  <integer>1024</integer>
</dict>
```

---

## 安全建議

1. **不要在 plist 中直接寫入敏感 token**
   - 考慮使用 macOS Keychain
   - 或從安全的設定檔讀取

2. **確認檔案權限正確**
   ```bash
   chmod 644 ~/Library/LaunchAgents/*.plist
   ```

3. **定期檢查日誌**
   ```bash
   ls -lh ~/logs/
   ```

4. **避免使用 sudo**
   - LaunchAgents 應該以使用者身份執行
   - LaunchDaemons 才需要 root 權限

---

## 參考連結

- [Apple 官方文件：Creating Launch Daemons and Agents](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
- [launchd.plist man page](https://keith.github.io/xcode-man-pages/launchd.plist.5.html)
- [launchctl man page](https://ss64.com/mac/launchctl.html)

---

## 快速命令參考

```bash
# 載入並啟用
launchctl load -w ~/Library/LaunchAgents/com.example.plist

# 卸載
launchctl unload ~/Library/LaunchAgents/com.example.plist

# 查看狀態
launchctl list | grep example

# 手動執行
launchctl start com.example.job

# 查看日誌
tail -f ~/logs/example.log

# 驗證 plist 格式
plutil -lint ~/Library/LaunchAgents/com.example.plist

# 重新載入（修改後）
launchctl unload ~/Library/LaunchAgents/com.example.plist && \
launchctl load -w ~/Library/LaunchAgents/com.example.plist
```

---

**最後更新**：2025-12-08
**適用版本**：macOS 10.10 及以上
