# Ollama 完整分析指南

## 📋 概述

Ollama 現在可以執行與 Claude CLI **完全相同**的分析任務，包括：
1. 市場分析報告 (`market-analysis-ollama-{date}.md`)
2. 持倉分析報告 (`holdings-analysis-ollama-{date}.md`)

## 🆕 更新內容 (2025-12-02)

- ❌ **移除**: 舊的 `run_daily_analysis_ollama_cli.sh` (僅做新聞篩選)
- ✅ **新增**: 完整分析腳本，與 Claude CLI 功能對等
- ✅ **更新**: Makefile 說明，反映新功能

## 🚀 使用方式

### 基本使用

```bash
# 使用 make 命令（推薦）
make analyze-ollama

# 或直接執行腳本
./src/scripts/analysis/run_daily_analysis_ollama_cli.sh
```

### 指定模型

```bash
# 使用你已安裝的模型
OLLAMA_MODEL="gpt-oss:20b" make analyze-ollama

# 使用其他模型
OLLAMA_MODEL="gemini-3-pro-preview:latest" ./src/scripts/analysis/run_daily_analysis_ollama_cli.sh
```

### 完整工作流程

```bash
# 方案 1: 只使用 Ollama (完全免費)
make fetch-all && make analyze-ollama

# 方案 2: 同時使用 Ollama + Claude (對比分析)
make fetch-all && make analyze-all

# 方案 3: 只使用 Claude (最高質量)
make daily
```

## 📊 推薦模型

根據你的硬體配置選擇：

| 模型 | 大小 | RAM 需求 | 速度 | 質量 | 推薦度 |
|------|------|----------|------|------|--------|
| **gpt-oss:20b** | 13 GB | 16 GB | 中 | 優秀 | ⭐⭐⭐⭐⭐ |
| qwen2.5:14b | 9 GB | 12 GB | 快 | 良好 | ⭐⭐⭐⭐ |
| llama3.1:70b | 40 GB | 64 GB | 慢 | 非常好 | ⭐⭐⭐⭐⭐ (高階) |
| gemma2:27b | 16 GB | 24 GB | 中 | 優秀 | ⭐⭐⭐⭐ |

你目前已安裝：
- ✅ `gpt-oss:20b` (13 GB) - **推薦使用**
- ✅ `gemini-3-pro-preview:latest`

## 📁 輸出檔案

執行後會生成以下報告：

```
reports/markdown/
├── market-analysis-ollama-2025-12-02.md      # Ollama 市場分析
├── holdings-analysis-ollama-2025-12-02.md    # Ollama 持倉分析
├── market-analysis-2025-12-02.md             # Claude 市場分析（如有執行）
└── holdings-analysis-2025-12-02.md           # Claude 持倉分析（如有執行）
```

**注意**：Ollama 版本的報告檔名有 `-ollama-` 後綴，與 Claude 版本區分。

## 💡 Ollama vs Claude CLI

### Ollama 的優勢

- ✅ **完全免費** - 無 API 成本
- ✅ **本地運行** - 數據完全私密
- ✅ **無網路依賴** - 離線也能使用
- ✅ **無限使用** - 不受 API 限制

### Ollama 的限制

- ⚠️ **需要硬體** - 至少 16GB RAM
- ⚠️ **速度較慢** - 本地推論需要時間
- ⚠️ **質量可能較低** - 取決於模型大小

### Claude CLI 的優勢

- ✅ **最高質量** - Sonnet 4.5 是最先進的模型
- ✅ **速度快** - 雲端推論，秒級回應
- ✅ **硬體無關** - 不需要強大的本地硬體

### Claude CLI 的限制

- 💰 **按 token 計費** - 每次分析約 $0.10-0.50
- 🌐 **需要網路** - 依賴雲端服務
- 📤 **數據上傳** - 敏感數據會傳到 Anthropic

## 🎯 使用場景建議

### 使用 Ollama 的場景

1. **日常分析** - 每天例行的市場掃描
2. **練習測試** - 調整 prompt，測試效果
3. **成本敏感** - 不想支付 API 費用
4. **數據隱私** - 敏感的投資組合資訊
5. **離線環境** - 無網路或網路不穩定

### 使用 Claude CLI 的場景

1. **重要決策** - 需要最高質量的分析
2. **緊急情況** - 需要快速得到結果
3. **硬體受限** - 沒有足夠的本地運算資源
4. **對比驗證** - 與 Ollama 結果交叉驗證

### 雙引擎策略（推薦）

```bash
# 每天使用 Ollama 做日常分析（免費）
make fetch-all && make analyze-ollama

# 每週使用 Claude 做深度分析（付費）
make fetch-all && make analyze-daily

# 重要時刻同時使用兩者（對比）
make fetch-all && make analyze-all
```

## 🔧 進階配置

### 調整溫度參數

```bash
# 更保守的輸出（更確定性）
TEMPERATURE=0.1 make analyze-ollama

# 更創意的輸出（更多樣化）
TEMPERATURE=0.7 make analyze-ollama
```

### 下載更多模型

```bash
# 下載推薦模型
ollama pull qwen2.5:14b
ollama pull llama3.1:70b
ollama pull gemma2:27b

# 查看已安裝模型
ollama list

# 刪除不需要的模型
ollama rm <model-name>
```

### 性能優化

```bash
# 監控 Ollama 資源使用
top -pid $(pgrep ollama)

# 限制 Ollama CPU 使用（如果系統卡頓）
# 在 ~/.ollama/config.json 中設定
{
  "num_threads": 4  // 限制使用的 CPU 核心數
}
```

## 📈 效果對比

以下是同一天的分析報告對比：

| 指標 | Claude CLI | Ollama (gpt-oss:20b) |
|------|-----------|---------------------|
| 報告長度 | 30-40 KB | 25-35 KB |
| 生成時間 | 2-3 分鐘 | 5-8 分鐘 |
| 分析深度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 數據準確性 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 洞察質量 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 繁體中文 | 完美 | 良好 |

## 🐛 故障排除

### Ollama 服務未啟動

```bash
# 檢查服務狀態
ps aux | grep ollama

# 手動啟動服務
ollama serve &
```

### 模型下載失敗

```bash
# 重試下載
ollama pull gpt-oss:20b

# 檢查磁碟空間
df -h
```

### 記憶體不足

```bash
# 檢查可用記憶體
free -h  # Linux
vm_stat  # macOS

# 使用較小的模型
OLLAMA_MODEL="qwen2.5:7b" make analyze-ollama
```

### 生成的報告是簡體中文

目前腳本已經在 Prompt 中明確要求使用繁體中文：
```
**重要：請使用繁體中文（Traditional Chinese）回答，不要使用簡體中文。**
```

如果仍然出現簡體中文，可以嘗試：
1. 使用 `gpt-oss:20b` 模型（繁體中文效果更好）
2. 在系統環境變數設定 `LANG=zh_TW.UTF-8`

## 📚 更多資源

- [Ollama 官方網站](https://ollama.com)
- [模型列表](https://ollama.com/library)
- [Ollama GitHub](https://github.com/ollama/ollama)

---

**最後更新**: 2025-12-02
**維護者**: Market Intelligence System
