# 📝 Changelog

---

## [2025-12-01] 技術選型決策: Claude CLI + Ollama CLI

### ✅ 重大決策

**改用 CLI 工具替代 Python SDK + API Key**

- **原因**: 簡化本機執行,適合 cronjob 自動化
- **優勢**:
  - 無需管理 `CLAUDE_API_KEY` 環境變數
  - 純 Bash 腳本,易於維護和調試
  - Ollama 本機推論,零 API 成本
  - 適合 cron 定時任務

---

### 🆕 新增功能

#### 1. Claude CLI 分析腳本

**檔案**: [utils/run_daily_analysis_claude_cli.sh](utils/run_daily_analysis_claude_cli.sh)

**功能**:
- 讀取市場指數、持股價格、新聞數據
- 生成結構化分析 Prompt
- 調用 Claude CLI 進行深度市場分析
- 輸出專業的 Markdown 報告

**使用方式**:
```bash
make analyze-daily
```

---

#### 2. Ollama CLI 預處理腳本 (可選)

**檔案**: [utils/run_daily_analysis_ollama_cli.sh](utils/run_daily_analysis_ollama_cli.sh)

**功能**:
- 從大量新聞中篩選最重要的 10 則
- 進行市場情緒分析
- 本機推論,零成本
- 結果可供 Claude 使用,降低 token 成本

**使用方式**:
```bash
make analyze-ollama
```

---

#### 3. Makefile 整合

**新增指令**:
```makefile
make analyze-daily   # Claude CLI 市場分析
make analyze-ollama  # Ollama 新聞預處理
make analyze-all     # 完整流程 (Ollama + Claude)
make daily           # 爬取 + 分析
```

**保留 Python SDK 版本** (legacy):
```makefile
make analyze-daily-python  # 需要 CLAUDE_API_KEY
```

---

### 📁 檔案結構變更

```
market-intelligence-system/
├── utils/                              # 🆕 新增工具目錄
│   ├── README.md                       # 🆕 使用說明
│   ├── run_daily_analysis_claude_cli.sh   # 🆕 Claude CLI 腳本
│   └── run_daily_analysis_ollama_cli.sh   # 🆕 Ollama CLI 腳本
├── analyzers/                          # Python SDK 版本 (legacy)
│   ├── analyzer_base.py
│   ├── claude_analyzer.py
│   ├── ollama_analyzer.py
│   └── run_daily_analysis.py          # 保留但非預設
├── Makefile                            # ✏️ 更新為 CLI 版本
└── TODO.md                             # ✏️ 反映技術決策
```

---

### 📚 文檔更新

- [TODO.md](TODO.md): 更新技術選型決策 (Phase 1.0 ✅ 已完成)
- [utils/README.md](utils/README.md): 新增完整的 CLI 工具使用說明
- [Makefile](Makefile): 更新 help 訊息

---

### 🔄 工作流程

#### 選項 A: 僅 Claude (簡單)

```bash
make daily  # fetch + Claude 分析
```

#### 選項 B: Ollama + Claude (成本優化)

```bash
make fetch-all
make analyze-all  # Ollama 預處理 + Claude 深度分析
```

---

### 🤖 自動化建議

設定 cron 定時任務:

```bash
# 每天早上 8:00 (亞洲市場收盤)
0 8 * * * cd /path/to/mis && make daily >> /tmp/mis.log 2>&1

# 每天晚上 21:00 (美國市場收盤)
0 21 * * * cd /path/to/mis && make daily >> /tmp/mis.log 2>&1
```

---

### 🧪 測試清單

- [ ] 安裝並登入 Claude CLI (`claude login`)
- [ ] 測試 `make analyze-daily`
- [ ] (可選) 安裝 Ollama 並下載模型
- [ ] (可選) 測試 `make analyze-ollama`
- [ ] 測試完整流程 `make daily`
- [ ] 檢視生成的報告 (`cat analysis/market-analysis-*.md`)

---

### 💡 下一步

1. **測試分析品質** (Phase 1.1)
   - 連續執行 3-5 天
   - 評估報告品質
   - 調整 Prompt (如需要)

2. **Docker 化** (Phase 2)
   - 建立 Dockerfile
   - 整合 Cron
   - 配置 docker-compose

3. **報告發布** (Phase 4)
   - 生成 HTML 報告
   - 自動提交到 GitHub
   - 部署到 GitHub Pages

---

**技術堆疊**:
- ✅ Claude CLI (市場深度分析)
- ✅ Ollama CLI (新聞預處理,可選)
- ✅ Bash (自動化腳本)
- ✅ Makefile (任務管理)
- ⏳ Python SDK (保留,legacy)

**成本**:
- Claude CLI: 按 token 計費 (~$0.15/日)
- Ollama: 免費 (本機推論)

---

**最後更新**: 2025-12-01
