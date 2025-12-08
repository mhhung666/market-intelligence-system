# 為 Cron 設定 Claude CLI 認證

## 問題說明

Claude Code CLI 預設使用**會話認證**,在 cron 環境中無法使用,會出現:
```
Invalid API key · Please run /login
```

## ✅ 解決方案 (已完成)

### 方案 1: 使用 OAuth Token (已配置) ⭐

使用 `claude setup-token` 生成的 OAuth token,有效期 1 年。

**配置步驟** (已完成):

1. 生成 OAuth token:
   ```bash
   ~/.local/bin/claude setup-token
   ```

2. 將 token 加入 crontab 環境變數:
   ```cron
   CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-UutRc...
   ```

3. ✅ **當前狀態**: 已配置並測試成功

### 方案 2: 使用 Ollama (本地 LLM,已配置)

**優點**:
- ✅ 完全本地運行,無需網路
- ✅ 無使用次數限制
- ✅ 已經配置完成,可立即使用
- ✅ 你已經有 deepseek-r1:70b 和 gemini-3-pro-preview 模型

**缺點**:
- ❌ 分析品質可能不如 Claude Sonnet 4.5
- ❌ 需要本機資源 (GPU/CPU)

**當前 Cron 設定**:
已更新為使用 Ollama (`make analyze-ollama`)

### 方案 3: 混合使用

- **Cron 自動化**: 使用 Ollama (穩定可靠)
- **手動分析**: 使用 Claude Code CLI (高品質分析)

## 測試狀態

- ⏰ 測試 Cron (Ollama): 將在 22:03 執行
- 📄 測試日誌: `/tmp/mis_ollama_test.log`

## 監控測試

```bash
# 即時監控
tail -f /tmp/mis_ollama_test.log

# 檢查執行狀態
watch -n 5 "ls -lh /tmp/mis_ollama_test.log 2>/dev/null || echo 'Waiting...'"
```

## 如果想使用 Claude CLI

1. 執行 `claude setup-token` 設定長效認證
2. 更新 crontab 改回使用 `make analyze-daily`
3. 重新測試

## 當前建議

**保持使用 Ollama 進行自動化分析**,原因:
- 已經配置完成
- 不依賴外部 API
- 適合定時自動執行
- 可以隨時手動使用 Claude 進行深度分析
