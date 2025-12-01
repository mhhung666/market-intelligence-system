# 🛠️ Utils - 分析工具腳本

這個目錄包含市場分析的 Bash 工具腳本,使用 CLI 工具進行本機分析。

---

## 📋 腳本列表

### 1. `run_daily_analysis_claude_cli.sh`

使用 **Claude CLI** 進行每日市場情報深度分析。

**功能**:
- 讀取市場指數、持股價格、新聞數據
- 生成結構化的市場分析 Prompt
- 調用 Claude CLI 進行深度分析
- 生成專業的市場情報報告 (Markdown)

**前置需求**:
```bash
# 安裝 Claude CLI
npm install -g @anthropic-ai/claude-cli

# 登入你的 Claude 帳號
claude login
```

**使用方式**:
```bash
# 直接執行
./utils/run_daily_analysis_claude_cli.sh

# 或通過 Makefile
make analyze-daily
```

**輸出**:
```
analysis/market-analysis-YYYY-MM-DD.md
```

**報告內容**:
- 📊 執行摘要 (市場概況、關鍵數據)
- 🌍 全球市場分析 (美國、亞洲、歐洲)
- 💼 持倉股票分析
- 📰 重要新聞解讀
- ⚠️ 風險與機會
- 💡 投資策略建議
- 🔮 後市展望

---

### 2. `run_daily_analysis_ollama_cli.sh`

使用 **Ollama CLI** 進行新聞預處理和情緒分析 (可選,用於成本優化)。

**功能**:
- 從大量新聞中篩選出最重要的 10 則
- 進行市場情緒分析
- 本機推論,零 API 成本
- 結果可作為 Claude 分析的輸入 (降低 token 使用)

**前置需求**:
```bash
# 安裝 Ollama
# macOS
brew install ollama

# Linux
curl -fsSL https://ollama.com/install.sh | sh

# 下載模型 (推薦 llama3.1:8b 或 qwen2.5:14b)
ollama pull llama3.1:8b
```

**使用方式**:
```bash
# 直接執行
./utils/run_daily_analysis_ollama_cli.sh

# 或通過 Makefile
make analyze-ollama

# 也可以指定不同模型
OLLAMA_MODEL=qwen2.5:14b ./utils/run_daily_analysis_ollama_cli.sh
```

**輸出**:
```
analysis/filtered-news-YYYY-MM-DD.md      # 篩選後的重要新聞
analysis/sentiment-analysis-YYYY-MM-DD.md  # 市場情緒分析
```

**情緒分析內容**:
- 😊 整體市場情緒評分 (1-10)
- 📊 樂觀/悲觀/中性因素分解
- 🏭 產業情緒分布
- ⚠️ 市場風險指標

---

## 🔄 工作流程

### 選項 A: 僅使用 Claude (簡單直接)

適合日常使用,直接獲得完整分析。

```bash
# 1. 爬取市場數據
make fetch-all

# 2. Claude 分析
make analyze-daily

# 或一步完成
make daily
```

### 選項 B: Ollama + Claude (成本優化)

適合新聞量大時,先用 Ollama 篩選,再用 Claude 深度分析。

```bash
# 1. 爬取市場數據
make fetch-all

# 2. Ollama 預處理 (篩選新聞 + 情緒分析)
make analyze-ollama

# 3. Claude 深度分析
make analyze-daily

# 或使用組合指令
make fetch-all && make analyze-all
```

**成本比較**:

| 方案 | Claude Token 使用 | Ollama 成本 | 總成本 |
|------|------------------|-------------|--------|
| 僅 Claude | 100% | $0 | 較高 |
| Ollama + Claude | ~30-50% | $0 (本機) | 較低 |

---

## 🤖 自動化執行 (Cron)

### 設定 Cron 任務

編輯 crontab:
```bash
crontab -e
```

添加每日執行任務:
```bash
# 每天早上 8:00 執行 (亞洲市場收盤後)
0 8 * * * cd /path/to/market-intelligence-system && make daily >> /tmp/mis-cron.log 2>&1

# 每天晚上 21:00 執行 (美國市場收盤後)
0 21 * * * cd /path/to/market-intelligence-system && make daily >> /tmp/mis-cron.log 2>&1
```

使用 Ollama 預處理的版本:
```bash
# 完整分析流程 (Ollama + Claude)
0 8 * * * cd /path/to/market-intelligence-system && make fetch-all && make analyze-all >> /tmp/mis-cron.log 2>&1
```

### 檢查 Cron 日誌

```bash
# 查看執行日誌
tail -f /tmp/mis-cron.log

# 查看生成的報告
ls -lh analysis/
```

---

## 🔧 腳本配置

### Claude CLI 腳本

可以通過修改 [run_daily_analysis_claude_cli.sh](run_daily_analysis_claude_cli.sh) 調整:

- **資料路徑**: 修改 `OUTPUT_DIR`, `ANALYSIS_DIR`
- **Prompt 模板**: 修改 `generate_analysis_prompt()` 函數
- **Claude 參數**: 修改 `claude` 命令選項 (例如 `--model`)

### Ollama CLI 腳本

可以通過環境變數或修改 [run_daily_analysis_ollama_cli.sh](run_daily_analysis_ollama_cli.sh) 調整:

**環境變數**:
```bash
# 使用不同模型
OLLAMA_MODEL=qwen2.5:14b make analyze-ollama

# 調整溫度 (更精確/更創意)
TEMPERATURE=0.1 make analyze-ollama
```

**腳本內配置**:
```bash
OLLAMA_MODEL="${OLLAMA_MODEL:-llama3.1:8b}"  # 預設模型
TEMPERATURE="${TEMPERATURE:-0.3}"             # 溫度參數
MAX_NEWS_TO_ANALYZE=50                        # 最多分析前 N 則新聞
TOP_K=10                                      # 篩選出前 K 則重要新聞
```

---

## 📊 輸出範例

### Claude 分析報告結構

```markdown
# 📈 市場情報分析 - 2025-12-01

> **報告生成時間**: 2025-12-01 08:00 UTC
> **分析引擎**: Market Intelligence System (Claude CLI)
> **報告類型**: 每日市場情報

---

## 📊 執行摘要

### 市場概況
[2-3 段文字總結全球市場]

### 關鍵數據
| 指標 | 數值 | 變化 | 狀態 |
|------|------|------|------|
| S&P 500 | 4,850.25 | +1.23% | 🟢 續創新高 |
| ... | ... | ... | ... |

## 🌍 全球市場分析
[詳細分析...]

## 💼 持倉股票分析
[持股表現...]

## 📰 重要新聞解讀
[新聞解析...]

## 💡 投資策略建議
[可執行建議...]
```

### Ollama 篩選新聞範例

```markdown
# 今日最重要的 10 則市場新聞

## 1. Fed 宣布維持利率不變

**重要性評分**: 9/10
**影響範圍**: 全球市場
**市場影響**: 中性偏樂觀
**選擇理由**: 央行政策決議直接影響市場流動性和利率環境

## 2. NVIDIA 財報超預期
[...]
```

---

## 🐛 故障排除

### Claude CLI 相關

**問題**: `command not found: claude`
```bash
# 確認已安裝
npm install -g @anthropic-ai/claude-cli

# 檢查安裝
which claude
```

**問題**: Claude CLI 未登入
```bash
# 重新登入
claude login

# 檢查登入狀態
claude --help
```

### Ollama 相關

**問題**: `command not found: ollama`
```bash
# 訪問 https://ollama.com 安裝
# 或使用包管理器
brew install ollama  # macOS
```

**問題**: 模型未下載
```bash
# 列出已安裝模型
ollama list

# 下載模型
ollama pull llama3.1:8b
```

**問題**: Ollama 服務未啟動
```bash
# 啟動 Ollama 服務
ollama serve

# 或在背景執行
ollama serve &
```

### 腳本執行權限

```bash
# 確保腳本可執行
chmod +x utils/*.sh

# 檢查權限
ls -l utils/
```

---

## 📚 相關文檔

- [TODO.md](../TODO.md) - 專案開發路線圖
- [analyzers/README.md](../analyzers/README.md) - Python SDK 版本 (legacy)
- [Claude CLI 官方文檔](https://github.com/anthropics/claude-cli)
- [Ollama 官方文檔](https://ollama.com/docs)

---

**最後更新**: 2025-12-01
