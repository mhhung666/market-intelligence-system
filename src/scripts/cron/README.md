# Cron 自動化腳本

這個目錄包含所有 cron 自動化相關的腳本。

## 📁 檔案說明

### 設定腳本

| 檔案 | 用途 | 使用引擎 | 成本 |
|------|------|----------|------|
| **setup_cron.sh** | 設定 Claude CLI 版本的 cron | Claude API | 付費 |
| **setup_cron_ollama.sh** | 設定 Ollama 版本的 cron | Ollama 本地 | 免費 ✅ |

### 執行腳本

| 檔案 | 用途 | 由誰調用 |
|------|------|----------|
| **run_daily_cron.sh** | Claude 版本的每日任務 | cron |
| **run_daily_cron_ollama.sh** | Ollama 版本的每日任務 | cron |

### 測試腳本

| 檔案 | 用途 |
|------|------|
| **test_cron.sh** | 測試 cron 環境設定 |

## 🚀 快速開始

### 選項 1: 使用 Ollama (免費推薦) ⭐

```bash
# 1. 進入專案目錄
cd /Users/mhhung/Development/MH/market-intelligence-system

# 2. 執行 Ollama 版本的設定腳本
./src/scripts/cron/setup_cron_ollama.sh

# 3. 按提示輸入 'y' 確認
```

**優點**:
- ✅ 完全免費
- ✅ 本地運行，數據私密
- ✅ 無網路依賴

**缺點**:
- ⚠️ 需要 16GB+ RAM
- ⚠️ 執行時間較長 (5-10 分鐘)

### 選項 2: 使用 Claude CLI (高質量)

```bash
# 1. 確保已登入 Claude CLI
claude login

# 2. 執行 Claude 版本的設定腳本
./src/scripts/cron/setup_cron.sh

# 3. 按提示輸入 'y' 確認
```

**優點**:
- ✅ 最高質量分析
- ✅ 速度快 (2-3 分鐘)

**缺點**:
- 💰 需要付費 (約 $0.10-0.50/次)
- 🌐 需要網路連接

## 📋 Cron 執行時間

兩個版本都會在以下時間自動執行：

- **早上 08:00** - 美國股市收盤後的新聞分析
- **晚上 20:00** - 亞洲股市收盤後的新聞分析

## 🔍 查看和管理

### 查看已安裝的 cron 任務

```bash
crontab -l
```

### 查看執行日誌

```bash
# Ollama 版本
tail -f /tmp/market-intelligence-system-ollama.log

# Claude 版本
tail -f /tmp/market-intelligence-system.log
```

### 手動測試執行

```bash
# 測試 Ollama 版本
./src/scripts/cron/run_daily_cron_ollama.sh

# 測試 Claude 版本
./src/scripts/cron/run_daily_cron.sh
```

### 測試環境設定

```bash
./src/scripts/cron/test_cron.sh
```

### 移除 cron 任務

```bash
# 編輯 crontab
crontab -e

# 刪除 Market Intelligence System 相關的行
# 或還原備份
crontab /path/to/backup/file
```

## 🔄 切換版本

你可以隨時在 Claude 和 Ollama 之間切換：

```bash
# 切換到 Ollama (免費)
./src/scripts/cron/setup_cron_ollama.sh

# 切換到 Claude (高質量)
./src/scripts/cron/setup_cron.sh
```

新的設定會覆蓋舊的 cron 任務。

## 📊 輸出結果

無論使用哪個版本，都會生成相同格式的報告：

```
reports/markdown/
├── market-analysis-2025-12-02.md      # 市場分析
└── holdings-analysis-2025-12-02.md    # 持倉分析
```

報告會自動 commit 並 push 到 Git repository。

## ⚙️ 自訂設定

### 修改 Ollama 模型

編輯 `run_daily_cron_ollama.sh`：

```bash
export OLLAMA_MODEL="gpt-oss:20b"  # 改成你想要的模型
```

### 修改執行時間

編輯 cron 時間（在 setup 腳本中）：

```bash
# 格式: 分 時 日 月 星期
0 8 * * *   # 每天 08:00
0 20 * * *  # 每天 20:00
```

## 🐛 故障排除

### Cron 沒有執行

1. 檢查 cron 服務：`ps aux | grep cron`
2. 檢查日誌：`tail -f /tmp/market-intelligence-system*.log`
3. 手動測試：`./src/scripts/cron/run_daily_cron_ollama.sh`

### Ollama 記憶體不足

```bash
# 使用較小的模型
export OLLAMA_MODEL="qwen2.5:7b"
```

### Git 推送失敗

確認 Git 認證設定：

```bash
# 檢查 credential helper
git config --get credential.helper

# 測試推送
git push origin main
```

## 📚 更多資訊

- [CRON_SETUP.md](../../../CRON_SETUP.md) - Claude 版本詳細指南
- [OLLAMA_GUIDE.md](../../../OLLAMA_GUIDE.md) - Ollama 完整使用指南

---

**建議**: 如果你是首次設定，建議使用 **Ollama 版本**（免費且完全自動化）。如果需要最高質量的分析，再考慮切換到 Claude 版本。
