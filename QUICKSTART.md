# 🚀 Quick Start Guide

快速開始使用 Market Intelligence System (MIS) 進行市場分析。

---

## ⚡ 5 分鐘快速開始

### 1. 安裝依賴

```bash
# Python 依賴 (用於爬蟲)
make install

# Claude CLI (用於分析)
npm install -g @anthropic-ai/claude-cli
claude login
```

### 2. 執行完整分析

```bash
# 一鍵執行: 爬取數據 + Claude 分析
make daily
```

### 3. 查看結果

```bash
# 查看生成的市場分析報告
cat reports/markdown/market-analysis-$(date +%Y-%m-%d).md

# 或使用 less 分頁查看
less reports/markdown/market-analysis-$(date +%Y-%m-%d).md
```

✅ 完成！你已經獲得一份專業的市場情報分析報告。

---

## 📋 詳細步驟

### Step 1: 安裝 Python 依賴

```bash
# 創建虛擬環境並安裝依賴
make install
```

這會安裝爬蟲所需的套件:
- `yfinance` - Yahoo Finance 數據爬取
- `requests` - HTTP 請求
- 其他依賴 (見 [requirements.txt](requirements.txt))

### Step 2: 安裝 Claude CLI

```bash
# 使用 npm 安裝
npm install -g @anthropic-ai/claude-cli

# 登入你的 Claude 帳號
claude login
```

**重要**: 必須先登入 Claude CLI,才能使用分析功能。

### Step 3: 配置持股清單 (可選)

編輯 [config/holdings.yaml](config/holdings.yaml):

```yaml
holdings:
  # 美股
  - symbol: AAPL
    name: Apple Inc.
  - symbol: GOOGL
    name: Alphabet Inc.

  # 台股 (加 .TW)
  - symbol: 2330.TW
    name: 台積電
```

### Step 4: 執行分析

#### 選項 A: 完整工作流程 (推薦)

```bash
make daily
```

這會執行:
1. 爬取全球市場指數
2. 爬取持股價格
3. 爬取市場新聞
4. 使用 Claude 進行深度分析

#### 選項 B: 分步驟執行

```bash
# 1. 只爬取數據
make fetch-all

# 2. 只執行分析 (需先有數據)
make analyze-daily
```

### Step 5: 查看報告

```bash
# 查看最新報告
ls -lh reports/markdown/

# 讀取報告內容
cat reports/markdown/market-analysis-2025-12-01.md

# 使用 less 分頁查看
less reports/markdown/market-analysis-2025-12-01.md
```

---

## 🆕 進階功能: Ollama 預處理 (可選)

### 為什麼使用 Ollama?

- **降低成本**: 先用 Ollama 篩選新聞,減少 Claude token 使用
- **本機推論**: 完全免費,無 API 成本
- **情緒分析**: 額外獲得市場情緒分析報告

### 安裝 Ollama

```bash
# macOS
brew install ollama

# Linux
curl -fsSL https://ollama.com/install.sh | sh

# 下載模型 (推薦 llama3.1:8b)
ollama pull llama3.1:8b
```

### 使用 Ollama + Claude 完整流程

```bash
# 1. 爬取數據
make fetch-all

# 2. Ollama 預處理 (篩選新聞 + 情緒分析)
make analyze-ollama

# 3. Claude 深度分析
make analyze-daily

# 或使用組合指令
make analyze-all  # Ollama + Claude
```

### 查看 Ollama 分析結果

```bash
# 篩選後的重要新聞
cat reports/markdown/filtered-news-2025-12-01.md

# 市場情緒分析
cat reports/markdown/sentiment-analysis-2025-12-01.md
```

---

## 🤖 設定自動化 (Cron)

### 每日自動執行

```bash
# 編輯 crontab
crontab -e

# 添加以下內容 (調整路徑)
# 每天早上 8:00 執行
0 8 * * * cd /path/to/market-intelligence-system && make daily >> /tmp/mis.log 2>&1
```

### 檢查執行狀況

```bash
# 查看 cron 日誌
tail -f /tmp/mis.log

# 查看生成的報告
ls -lt reports/markdown/ | head -5
```

---

## 🛠️ 常用命令

### 爬蟲相關

```bash
make fetch-global    # 只爬取全球指數
make fetch-holdings  # 只爬取持股價格
make fetch-news      # 只爬取市場新聞
make fetch-all       # 爬取所有數據
```

### 分析相關

```bash
make analyze-daily   # Claude CLI 分析
make analyze-ollama  # Ollama 預處理
make analyze-all     # 完整分析流程
```

### 完整工作流程

```bash
make daily           # 爬取 + Claude 分析
```

### 其他

```bash
make help            # 顯示所有可用命令
make clean           # 清理 Python cache
make test            # 執行測試 (如有)
```

---

## 📊 輸出檔案

### 數據檔案 (output/)

```
output/market-data/2025/
├── Daily/
│   ├── global-indices-2025-12-01.md  # 全球指數
│   └── prices-2025-12-01.md          # 持股價格
└── News/
    ├── AAPL-2025-12-01.md            # 各股票新聞
    └── TSLA-2025-12-01.md
```

### 分析報告 (reports/markdown/)

```
reports/markdown/
├── market-analysis-2025-12-01.md     # Claude 市場分析報告
├── filtered-news-2025-12-01.md       # Ollama 篩選新聞 (可選)
└── sentiment-analysis-2025-12-01.md  # Ollama 情緒分析 (可選)
```

---

## 🐛 故障排除

### Claude CLI 未登入

```bash
# 重新登入
claude login

# 測試 Claude CLI
echo "Hello" | claude
```

### Ollama 服務未啟動

```bash
# 啟動 Ollama 服務
ollama serve

# 測試 Ollama
ollama run llama3.1:8b
```

### 爬蟲執行失敗

```bash
# 檢查 Python 環境
which python3
python3 --version

# 重新安裝依賴
make clean-venv
make install
```

### 找不到數據檔案

```bash
# 確認數據已爬取
ls -lh output/market-data/$(date +%Y)/Daily/

# 如果沒有,重新爬取
make fetch-all
```

---

## 📚 更多資訊

- [README.md](README.md) - 專案總覽
- [DEVELOPMENT.md](DEVELOPMENT.md) - 開發路線圖與架構說明
- [src/scripts/README.md](src/scripts/README.md) - 分析工具詳細說明
- [CHANGELOG.md](CHANGELOG.md) - 版本更新記錄

---

## 💡 使用建議

### 日常使用

推薦每天執行一次完整分析:

```bash
# 每天早上執行
make daily
```

### 成本優化

如果新聞量大 (>50 則),建議使用 Ollama 預處理:

```bash
# 使用 Ollama 篩選 + Claude 分析
make fetch-all && make analyze-all
```

### 快速測試

想快速測試分析功能:

```bash
# 假設已有數據,只執行分析
make analyze-daily
```

---

## 🎯 下一步

1. **評估報告品質**
   - 連續執行 3-5 天
   - 閱讀生成的報告
   - 評估是否符合需求

2. **調整配置**
   - 修改持股清單 ([config/holdings.yaml](config/holdings.yaml))
   - 調整新聞來源 (如需要)
   - 優化分析 Prompt ([src/scripts/run_daily_analysis_claude_cli.sh](src/scripts/run_daily_analysis_claude_cli.sh))

3. **設定自動化**
   - 配置 cron 定時任務
   - 監控執行狀況
   - 定期查看分析報告

---

**快速開始就這麼簡單！** 🎉

如有問題,請參考 [src/scripts/README.md](src/scripts/README.md) 的詳細說明。
