# 🔄 Market Intelligence System - 架構重構計劃

> **目標**: 將程式碼整理到 `/src` 目錄，優化架構，簡化文檔

**重構日期**: 2025-12-02
**當前狀態**: Phase 0 完成 ✅ | Phase 1 進行中 🔵

---

## 📋 目錄

1. [重構目標](#重構目標)
2. [新架構設計](#新架構設計)
3. [重構步驟](#重構步驟)
4. [文檔簡化計劃](#文檔簡化計劃)
5. [遷移檢查清單](#遷移檢查清單)

---

## 🎯 重構目標

### 核心問題
基於架構分析報告，當前專案存在以下問題：

1. ⚠️ **程式碼分散** - scrapers/, analyzers/, utils/ 三處散落
2. ⚠️ **文檔冗余** - 7個主要文檔，QUICKSTART.md vs QUICK_START.md 重複
3. ⚠️ **目錄職責不清** - utils/ 承載核心業務邏輯
4. ⚠️ **Legacy 代碼未整理** - Python SDK 完整保留但未來不明

### 重構目標

✅ **統一程式碼目錄** - 所有程式碼放入 `/src`
✅ **簡化文檔結構** - 精簡為 3-4 個核心文檔
✅ **明確職責劃分** - 清晰的分層架構
✅ **清理 Legacy 代碼** - 移動到 `/legacy` 或刪除

---

## 🏗️ 新架構設計

### 重構後的目錄結構

```
market-intelligence-system/
│
├── src/                          # 📁 所有程式碼 (新增)
│   ├── scrapers/                 # 爬蟲層 - 數據收集
│   │   ├── __init__.py
│   │   ├── common.py             # 共用模組 (265行)
│   │   ├── fetch_global_indices.py    # 全球指數爬蟲 (294行)
│   │   ├── fetch_holdings_prices.py   # 持倉價格爬蟲 (310行)
│   │   ├── fetch_market_data.py       # 歷史數據爬蟲 (194行)
│   │   ├── fetch_market_news.py       # 單一新聞爬蟲 (222行)
│   │   ├── fetch_all_news.py          # 批次新聞爬蟲 (142行)
│   │   └── README.md                  # 爬蟲文檔
│   │
│   ├── scripts/                  # 主要執行腳本 (重命名自 utils/)
│   │   ├── analysis/
│   │   │   ├── run_daily_analysis_claude_cli.sh   # Claude CLI 分析 (842行)
│   │   │   └── run_daily_analysis_ollama_cli.sh   # Ollama 預處理 (341行)
│   │   ├── deployment/
│   │   │   └── update_github_pages.sh             # GitHub Pages 更新 (148行)
│   │   ├── tools/
│   │   │   └── convert_md_to_html.py              # HTML 轉換工具
│   │   └── README.md
│   │
│   └── legacy/                   # Legacy 代碼 (Python SDK)
│       ├── README.md             # 說明 Legacy 代碼用途
│       ├── analyzer_base.py      # 抽象基類 (202行)
│       ├── claude_analyzer.py    # Claude 分析器
│       ├── ollama_analyzer.py    # Ollama 分析器
│       └── run_daily_analysis.py # Python SDK 執行腳本
│
├── config/                       # 配置文件
│   ├── holdings.yaml             # 投資組合配置
│   ├── indices.yaml              # 全球指數配置
│   └── settings.yaml             # 統一配置 (新增)
│
├── output/                       # 爬蟲數據輸出
│   └── market-data/{YEAR}/
│       ├── Daily/                # 每日指數和價格
│       ├── News/                 # 新聞數據
│       └── Stocks/               # 歷史數據
│
├── reports/                      # 所有報告 (重命名自 analysis/)
│   ├── markdown/                 # Markdown 報告
│   │   ├── market-analysis-{date}.md
│   │   └── holdings-analysis-{date}.md
│   └── html/                     # HTML 報告 (可選)
│
├── docs/                         # 文檔和網站
│   ├── guide/                    # 使用指南
│   │   └── GUIDE.md              # 完整使用指南
│   └── web/                      # GitHub Pages 資源
│       ├── index.html
│       ├── market.html
│       ├── holdings.html
│       └── styles.css
│
├── tests/                        # 測試文件
│   ├── conftest.py
│   ├── test_common.py
│   └── test_scrapers.py
│
├── .github/                      # GitHub 相關
│   └── workflows/
│       └── deploy.yml
│
├── README.md                     # 專案概覽 + 快速開始
├── QUICKSTART.md                 # 5分鐘快速上手指南
├── DEVELOPMENT.md                # 開發文檔 (整合 TODO.md + SUMMARY.md)
├── CHANGELOG.md                  # 統一版本歷史
├── Makefile                      # 任務自動化
├── requirements.txt              # Python 依賴
├── .env.example                  # 環境變數範例
└── .venv/                        # Python 虛擬環境
```

### 關鍵變更說明

| 原目錄/文件 | 新位置 | 原因 |
|------------|--------|------|
| `scrapers/` | `src/scrapers/` | 統一程式碼目錄 |
| `utils/` | `src/scripts/` | 明確主腳本職責 |
| `analyzers/` | `src/legacy/` | 標記為 Legacy |
| `analysis/` | `reports/markdown/` | 明確報告性質 |
| `docs/*.html` | `docs/web/` | 分離文檔和網站 |
| `QUICK_START.md` | ❌ 刪除 | 與 QUICKSTART.md 重複 |
| `SUMMARY.md` | → `DEVELOPMENT.md` | 整合開發文檔 |
| `TODO.md` | → `DEVELOPMENT.md` | 整合開發文檔 |
| `docs/CHANGELOG.md` + `docs/CHANGELOG-v2.md` | → `CHANGELOG.md` | 統一版本歷史 |

---

## 🔄 重構步驟

### Phase 1: 創建新目錄結構 (15分鐘)

```bash
# 1. 創建 src/ 主目錄
mkdir -p src/scrapers
mkdir -p src/scripts/{analysis,deployment,tools}
mkdir -p src/legacy

# 2. 創建 reports/ 目錄
mkdir -p reports/{markdown,html}

# 3. 創建 docs/ 子目錄
mkdir -p docs/{guide,web}

# 4. 創建統一配置文件
touch config/settings.yaml
```

### Phase 2: 移動程式碼文件 (30分鐘)

```bash
# 1. 移動爬蟲代碼
mv scrapers/* src/scrapers/

# 2. 移動分析腳本
mv utils/run_daily_analysis_claude_cli.sh src/scripts/analysis/
mv utils/run_daily_analysis_ollama_cli.sh src/scripts/analysis/
mv utils/update_github_pages.sh src/scripts/deployment/
mv utils/convert_md_to_html.py src/scripts/tools/
mv utils/README.md src/scripts/

# 3. 移動 Legacy 代碼
mv analyzers/* src/legacy/

# 4. 移動報告文件
mv analysis/*.md reports/markdown/

# 5. 重組 docs/
mv docs/*.html docs/web/
mv docs/styles.css docs/web/
```

### Phase 3: 更新路徑引用 (45分鐘)

需要更新以下文件中的路徑：

1. **Makefile** (最重要)
   ```makefile
   # 舊路徑
   $(PYTHON_BIN) scrapers/fetch_global_indices.py
   ./utils/run_daily_analysis_claude_cli.sh

   # 新路徑
   $(PYTHON_BIN) src/scrapers/fetch_global_indices.py
   ./src/scripts/analysis/run_daily_analysis_claude_cli.sh
   ```

2. **src/scrapers/common.py**
   - 更新 `get_project_root()` 函數
   - 確保路徑計算正確

3. **src/scripts/analysis/*.sh**
   - 更新數據讀取路徑
   - 更新報告輸出路徑

4. **src/scripts/deployment/update_github_pages.sh**
   - 更新報告來源路徑: `reports/markdown/`
   - 更新 HTML 輸出路徑: `docs/web/`

### Phase 4: 簡化文檔 (60分鐘)

#### 4.1 刪除重複文檔

```bash
# 刪除重複的 QUICK_START.md
rm QUICK_START.md

# 保留並優化 QUICKSTART.md
```

#### 4.2 合併文檔

**創建 DEVELOPMENT.md** (整合 TODO.md + SUMMARY.md):

```bash
# 1. 創建新文件
cat > DEVELOPMENT.md << 'EOF'
# 開發文檔

## 開發路線圖
[從 TODO.md 提取]

## 技術選型與演進
[從 SUMMARY.md 提取]

## 架構決策記錄
[記錄重要的架構決策]

## 貢獻指南
[開發流程說明]
EOF

# 2. 刪除舊文件
rm TODO.md SUMMARY.md
```

**統一 CHANGELOG.md**:

```bash
# 合併 docs/CHANGELOG.md 和 docs/CHANGELOG-v2.md
cat > CHANGELOG.md << 'EOF'
# Changelog

## [v2.0.0] - 2025-11-XX
### Added
- 雙報告系統 (市場分析 + 持倉分析)
- GitHub Pages 自動部署
- [從 CHANGELOG-v2.md 提取]

## [v1.0.0] - 2025-XX-XX
### Added
- Claude CLI 技術選型
- Ollama 預處理整合
- [從 CHANGELOG.md 提取]
EOF

# 刪除舊文件
rm docs/CHANGELOG.md docs/CHANGELOG-v2.md
```

#### 4.3 優化核心文檔

**README.md** - 保持簡潔 (目標: ~200行)
- 專案概覽
- 5分鐘快速開始
- 核心功能簡介
- 文檔導航

**QUICKSTART.md** - 詳細快速開始 (目標: ~300行)
- 環境設置
- 配置說明
- 常見用例
- 故障排除

**DEVELOPMENT.md** - 開發者文檔 (新增)
- 開發路線圖
- 技術選型
- 架構說明
- 貢獻指南

**CHANGELOG.md** - 版本歷史 (統一)
- 標準語義化版本
- 清晰的變更記錄

### Phase 5: 測試驗證 (30分鐘)

```bash
# 1. 測試爬蟲功能
make fetch-global
make fetch-holdings
make fetch-news

# 2. 測試分析功能
make analyze-daily

# 3. 測試完整流程
make daily

# 4. 測試 GitHub Pages 更新
make update-pages

# 5. 預覽網站
make preview-pages
```

### Phase 6: 清理舊目錄 (10分鐘)

```bash
# 確認所有文件已移動後，刪除空目錄
rmdir scrapers analyzers utils analysis

# 清理臨時文件
make clean
```

---

## 📚 文檔簡化計劃

### 當前文檔結構 (問題)

```
❌ 7個主要文檔 (~2,266 行)
├── README.md (465行)
├── TODO.md (357行)
├── QUICKSTART.md (364行)
├── QUICK_START.md (273行) ← 重複!
├── SUMMARY.md (302行)
├── GITHUB_PAGES_SETUP.md (224行)
├── docs/CHANGELOG.md (174行)
├── docs/CHANGELOG-v2.md (167行) ← 分散!
└── docs/WORKFLOW.md (281行)
```

### 優化後文檔結構 (解決方案)

```
✅ 4個核心文檔 (~1,200 行)
├── README.md (~200行)
│   - 專案概覽
│   - 5分鐘快速開始
│   - 文檔導航
│
├── QUICKSTART.md (~300行)
│   - 環境設置
│   - 配置說明
│   - 常見用例
│   - 故障排除
│
├── DEVELOPMENT.md (~500行) [新增]
│   - 開發路線圖 (from TODO.md)
│   - 技術選型 (from SUMMARY.md)
│   - 架構說明 (from REFACTORING_PLAN.md)
│   - 貢獻指南
│
└── CHANGELOG.md (~200行)
    - 統一版本歷史 (合併兩個 CHANGELOG)
    - 語義化版本格式

📁 docs/guide/
    └── GUIDE.md (~400行) [可選]
        - 詳細使用指南
        - 進階功能
        - 最佳實踐
```

### 文檔精簡原則

1. **刪除重複** - QUICK_START.md → 刪除，保留 QUICKSTART.md
2. **合併相關** - TODO.md + SUMMARY.md → DEVELOPMENT.md
3. **統一版本歷史** - 兩個 CHANGELOG → 單一 CHANGELOG.md
4. **移除施作細節** - 保留「是什麼」和「為什麼」，減少「怎麼做」的細節
5. **清晰分層** - 用戶文檔 vs 開發文檔

---

## ✅ 遷移檢查清單

### 程式碼遷移

- [ ] 創建 `src/` 目錄結構
- [ ] 移動 `scrapers/` → `src/scrapers/`
- [ ] 移動 `utils/` → `src/scripts/`
- [ ] 移動 `analyzers/` → `src/legacy/`
- [ ] 創建 `reports/` 並移動 `analysis/` 內容
- [ ] 重組 `docs/` 目錄結構

### 路徑更新

- [ ] 更新 `Makefile` 所有路徑引用
- [ ] 更新 `src/scrapers/common.py` 路徑函數
- [ ] 更新 `src/scripts/analysis/*.sh` 路徑
- [ ] 更新 `src/scripts/deployment/update_github_pages.sh`
- [ ] 更新 `.gitignore` (如果需要)

### 文檔整理

- [ ] 刪除 `QUICK_START.md`
- [ ] 創建 `DEVELOPMENT.md` (整合 TODO.md + SUMMARY.md)
- [ ] 統一 `CHANGELOG.md` (合併兩個文件)
- [ ] 簡化 `README.md` (目標 ~200行)
- [ ] 優化 `QUICKSTART.md` (移除過多細節)
- [ ] 創建 `src/legacy/README.md` (說明 Legacy 代碼)

### 配置管理

- [ ] 創建 `config/settings.yaml` 統一配置
- [ ] 更新腳本讀取統一配置
- [ ] 驗證環境變數配置

### 測試驗證

- [ ] 測試 `make fetch-all`
- [ ] 測試 `make analyze-daily`
- [ ] 測試 `make daily` (完整流程)
- [ ] 測試 `make update-pages`
- [ ] 測試 `make deploy` (如果使用 GitHub Pages)
- [ ] 檢查所有報告生成正確

### 清理工作

- [ ] 刪除空目錄 (scrapers/, analyzers/, utils/, analysis/)
- [ ] 刪除臨時文件 (`make clean`)
- [ ] 更新 `.gitignore`
- [ ] Commit 重構變更

### 文檔更新

- [ ] 更新所有文檔中的路徑引用
- [ ] 更新 README.md 架構圖
- [ ] 更新 DEVELOPMENT.md 技術棧說明
- [ ] 添加架構重構說明到 CHANGELOG.md

---

## 🚨 注意事項

### 破壞性變更

以下變更會影響現有腳本和 cron 任務：

1. **Makefile targets** - 大部分保持不變，但內部路徑改變
2. **手動執行腳本** - 如果有直接執行腳本，需要更新路徑
3. **Cron 任務** - 如果有 cron 任務，需要更新 `cd` 路徑

### 建議的遷移方式

**選項 A: 漸進式遷移 (推薦)**
1. 創建新目錄結構
2. 複製文件到新位置 (不刪除舊文件)
3. 更新 Makefile 指向新路徑
4. 測試驗證
5. 確認無誤後刪除舊目錄

**選項 B: 直接遷移**
1. 創建完整備份 `tar -czf backup.tar.gz market-intelligence-system/`
2. 執行所有遷移步驟
3. 測試驗證
4. 如有問題，從備份恢復

### Git 提交策略

建議分多個 commit 提交，便於回溯：

```bash
# Commit 1: 創建新目錄結構
git add src/ reports/ docs/
git commit -m "refactor: Create new directory structure with /src"

# Commit 2: 移動程式碼文件
git add src/
git commit -m "refactor: Move code to /src directory"

# Commit 3: 更新路徑引用
git add Makefile src/
git commit -m "refactor: Update path references in Makefile and scripts"

# Commit 4: 簡化文檔
git add README.md QUICKSTART.md DEVELOPMENT.md CHANGELOG.md
git rm QUICK_START.md TODO.md SUMMARY.md
git commit -m "docs: Simplify documentation structure"

# Commit 5: 清理舊目錄
git rm -r scrapers/ analyzers/ utils/ analysis/
git commit -m "refactor: Remove old directories after migration"
```

---

## 📊 重構效益

### 程式碼組織

✅ **統一入口** - 所有程式碼在 `/src`
✅ **清晰分層** - scrapers → scripts → reports
✅ **職責明確** - 每個目錄職責單一
✅ **易於擴展** - 新功能清楚應該放哪裡

### 文檔優化

✅ **減少冗余** - 7個文檔 → 4個核心文檔
✅ **統一風格** - 標準化文檔結構
✅ **降低維護成本** - 少 50% 文檔需要維護
✅ **提升可讀性** - 新用戶更容易上手

### 維護性提升

✅ **路徑管理簡化** - 統一 `src/` 前綴
✅ **測試更容易** - 明確的測試目標
✅ **部署更清晰** - 分離代碼和輸出
✅ **協作更友好** - 標準化專案結構

---

## 🔗 相關資源

- [專案架構分析報告](./docs/ARCHITECTURE_ANALYSIS.md) (如果生成的話)
- [Python 專案最佳實踐](https://docs.python-guide.org/writing/structure/)
- [Makefile 風格指南](https://clarkgrubb.com/makefile-style-guide)

---

**重構計劃制定**: 2025-12-02
**預計完成時間**: 3-4 小時
**建議執行時間**: 非交易時段，避免影響 cron 任務

---

*Market Intelligence System - 架構重構計劃* 🔄
