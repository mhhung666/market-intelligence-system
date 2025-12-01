# Market Data Crawler

市場數據爬蟲服務 - 獨立的微服務專案,用於自動化收集全球市場數據。

## 專案簡介

這是一個輕量級的市場數據爬蟲服務,可以:
- 爬取全球主要市場指數 (台灣、美國、日本、香港、中國、韓國、歐洲等)
- 獲取投資組合持倉價格
- 批次收集股票和指數市場新聞 (基於配置檔自動化)
- 支援 Docker 容器化部署
- 支援 Cron 定時任務
- 所有配置均基於 YAML,無需修改程式碼

## 專案結構

```
market-data-crawler/
├── scrapers/                    # 爬蟲腳本
│   ├── common.py               # 共用模組
│   ├── fetch_global_indices.py # 全球指數爬蟲
│   ├── fetch_holdings_prices.py# 持倉價格爬蟲
│   ├── fetch_market_news.py    # 單一股票/指數新聞爬蟲
│   ├── fetch_all_news.py       # 批次新聞爬蟲 (從配置檔讀取)
│   ├── fetch_market_data.py    # 通用市場數據爬蟲
│   └── README.md               # 爬蟲詳細說明
├── config/                      # 配置檔案
│   ├── indices.yaml            # 指數配置 (含 fetch_news 設定)
│   └── holdings.yaml           # 持倉配置 (含 fetch_news 設定)
├── tests/                       # 測試檔案
├── cron/                        # Cron 設定檔
├── output/                      # 輸出目錄 (gitignore)
│   └── market-data/
│       └── {YEAR}/
│           ├── Daily/          # 每日指數數據
│           ├── Stocks/         # 個股歷史數據
│           └── News/           # 新聞數據
├── Makefile                     # Make 快捷指令
├── Dockerfile                   # Docker 映像檔
├── docker-compose.yml          # Docker Compose 配置
├── requirements.txt            # Python 依賴
├── .env.example                # 環境變數範例
└── README.md                   # 本檔案
```

## 快速開始

### 1. 本地開發環境

#### 安裝依賴

```bash
# 建立虛擬環境
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# 安裝依賴
pip install -r requirements.txt
```

#### 執行爬蟲

**使用 Makefile (推薦):**
```bash
# 查看所有可用指令
make help

# 執行所有爬蟲
make fetch-all

# 只爬取全球指數
make fetch-global

# 只爬取持倉價格
make fetch-holdings

# 只爬取新聞 (從配置檔讀取)
make fetch-news

# 執行測試
make test
```

**直接執行腳本:**
```bash
# 爬取全球市場指數
python scrapers/fetch_global_indices.py

# 爬取持倉價格
python scrapers/fetch_holdings_prices.py

# 批次爬取新聞 (從配置檔自動讀取)
python scrapers/fetch_all_news.py

# 爬取單一股票新聞
python scrapers/fetch_market_news.py AAPL

# 查看詳細用法
python scrapers/fetch_global_indices.py --help
```

### 2. Docker 環境

#### 建置映像檔

```bash
docker-compose build
```

#### 啟動服務

```bash
docker-compose up -d
```

#### 查看日誌

```bash
docker-compose logs -f
```

#### 停止服務

```bash
docker-compose down
```

## 環境變數配置

複製 `.env.example` 為 `.env` 並修改:

```bash
cp .env.example .env
```

主要環境變數:

- `OUTPUT_DIR`: 輸出目錄路徑 (Docker 環境建議 `/app/output`)
- `TZ`: 時區設定 (預設 `Asia/Taipei`)

## 爬蟲腳本說明

### 1. 全球指數爬蟲 (fetch_global_indices.py)

爬取全球主要市場指數數據。

```bash
# 使用 Makefile
make fetch-global

# 直接執行腳本 (爬取所有市場)
python scrapers/fetch_global_indices.py

# 爬取特定區域
python scrapers/fetch_global_indices.py -r 台灣 美國 日本

# 查看所有支援的區域
python scrapers/fetch_global_indices.py --help
```

**配置檔案:** `config/indices.yaml`

**支援的市場:**
- 亞洲: 台灣、日本、韓國、中國、香港、新加坡、印度
- 美國: S&P 500、Nasdaq、道瓊、Russell 2000、VIX、費城半導體等
- 歐洲: 德DAX、法CAC、英FTSE、STOXX 50等
- 商品: 黃金、原油、比特幣、美元指數
- 債券: 美國10年期、2年期公債殖利率、高收益債ETF

### 2. 持倉價格爬蟲 (fetch_holdings_prices.py)

獲取投資組合的即時價格。

```bash
# 使用 Makefile
make fetch-holdings

# 直接執行腳本
python scrapers/fetch_holdings_prices.py

# 使用自訂配置檔
python scrapers/fetch_holdings_prices.py -i config/holdings.yaml

# 輸出到檔案
python scrapers/fetch_holdings_prices.py -o output/prices-today.md

# 顯示詳細資訊
python scrapers/fetch_holdings_prices.py -v
```

**配置檔案:** `config/holdings.yaml`

**功能:**
- 從 YAML 配置檔讀取所有 `enabled: true` 的股票
- 支援多個持股群組 (核心持倉、一般持倉、小倉位等)
- 獲取即時價格、漲跌幅、成交量、市值等資訊
- 自動計算市場概況統計 (上漲/下跌/持平比例)
- 輸出 Markdown 表格格式

### 3. 批次新聞爬蟲 (fetch_all_news.py) ⭐ 推薦

批次收集所有配置的股票和指數新聞。

```bash
# 使用 Makefile
make fetch-news

# 直接執行腳本
python scrapers/fetch_all_news.py
```

**配置檔案:** `config/holdings.yaml` 和 `config/indices.yaml`

**功能:**
- 自動讀取配置檔中 `fetch_news: true` 的項目
- 批次爬取多個股票和指數新聞
- 自動產生帶日期的檔名
- 顯示進度和成功/失敗統計

**配置範例:**
```yaml
# config/holdings.yaml
holdings:
  核心持倉:
    Tesla:
      symbol: "TSLA"
      fetch_news: true    # 啟用新聞爬取
      enabled: true

# config/indices.yaml
global_indices:
  美國:
    S&P 500:
      symbol: "^GSPC"
      fetch_news: true    # 啟用新聞爬取
```

### 4. 單一新聞爬蟲 (fetch_market_news.py)

爬取特定股票或指數的新聞。

```bash
# 爬取 Apple 新聞 (自動產生檔名)
python scrapers/fetch_market_news.py AAPL

# 爬取 Tesla 新聞並限制 5 則
python scrapers/fetch_market_news.py TSLA -l 5

# 爬取 S&P 500 新聞
python scrapers/fetch_market_news.py "^GSPC"

# 輸出為 JSON 格式
python scrapers/fetch_market_news.py AAPL --json
```

更多詳細說明請參考 [scrapers/README.md](scrapers/README.md)

## 輸出格式

所有爬蟲預設輸出 Markdown 格式,儲存至:

```
output/
└── market-data/
    └── 2025/
        ├── Daily/              # 每日數據
        ├── Stocks/             # 個股數據
        └── News/               # 新聞數據
```

檔名格式: `{prefix}-{YYYY-MM-DD}.md`

例如: `global-indices-2025-11-28.md`

## Cron 定時任務

在 Docker 環境中,系統會自動執行定時任務:

- **亞洲市場**: 每天 08:00 (GMT+8)
- **美歐市場**: 每天 21:00 (GMT+8)

配置檔案位於 `cron/` 目錄。

## 整合到其他專案

### 作為 Docker 服務

在你的專案中引用此爬蟲服務:

```yaml
# your-project/docker-compose.yml
version: '3.8'

services:
  crawler:
    build: ../market-data-crawler
    volumes:
      - ./data:/app/output    # 掛載到你的數據目錄
    environment:
      - OUTPUT_DIR=/app/output
      - TZ=Asia/Taipei
```

### 作為 Python 模組

```python
from scrapers.fetch_global_indices import fetch_indices

# 程式化調用
data = fetch_indices(regions=['台灣', '美國'])
```

## 測試

```bash
# 執行所有測試
pytest

# 執行特定測試
pytest tests/test_common.py

# 查看覆蓋率
pytest --cov=scrapers
```

## 技術棧

- Python 3.11+
- yfinance - Yahoo Finance API
- pandas - 資料處理
- pyyaml - 配置解析
- requests - HTTP 請求
- Docker - 容器化
- Cron - 定時任務

## 配置檔案說明

所有爬蟲的配置都基於 YAML 檔案,無需修改程式碼即可自訂追蹤的市場、股票和新聞來源。

### config/indices.yaml

全球市場指數配置:

```yaml
global_indices:
  美國:
    S&P 500:
      symbol: "^GSPC"
      fetch_news: true    # 是否爬取該指數新聞
```

- 新增/移除市場指數: 直接編輯 YAML 檔案
- `fetch_news: true`: 該指數會被 `fetch_all_news.py` 爬取新聞
- `fetch_news: false`: 不爬取新聞,僅在 `fetch_global_indices.py` 中顯示指數數據

### config/holdings.yaml

投資組合持倉配置:

```yaml
holdings:
  核心持倉:
    Tesla:
      symbol: "TSLA"
      fetch_news: true    # 是否爬取該股票新聞
      enabled: true       # 是否啟用 (用於暫停某些股票)
      position: 3.4%
```

- `enabled: true/false`: 控制該股票是否出現在 `fetch_holdings_prices.py` 中
- `fetch_news: true/false`: 控制該股票是否被 `fetch_all_news.py` 爬取新聞
- `position`: 持倉比例 (可選,僅用於記錄)

## 常見問題

### Q: 如何新增要追蹤的股票?

A: 編輯 `config/holdings.yaml`,新增股票配置:
```yaml
holdings:
  核心持倉:
    Apple:
      symbol: "AAPL"
      fetch_news: true
      enabled: true
      position: 5.0%
```

重新執行 `make fetch-holdings` 或 `make fetch-news` 即可生效,無需修改程式碼。

### Q: 如何暫停某隻股票而不刪除配置?

A: 將 `enabled` 設為 `false`:
```yaml
Tesla:
  symbol: "TSLA"
  fetch_news: true
  enabled: false  # 暫停追蹤,不會出現在價格報表中
  position: 3.4%
```

設為 `enabled: false` 的股票不會被 `fetch_holdings_prices.py` 處理,但配置保留方便日後重新啟用。

### Q: 如何只爬取特定股票的新聞?

A: 使用單一新聞爬蟲:
```bash
python scrapers/fetch_market_news.py AAPL
```

或在 `config/holdings.yaml` 中設定 `fetch_news: true`,然後執行:
```bash
make fetch-news
```

### Q: 爬蟲執行失敗?

A: 檢查:
1. 網路連線是否正常
2. Yahoo Finance API 是否可訪問
3. 輸出目錄權限是否正確
4. 股票代碼是否正確 (例如非美股需要市場後綴如 `.SI`)

### Q: 輸出檔案在哪裡?

A:
- 本地環境: `output/market-data/{year}/`
  - Daily: 每日指數數據
  - Stocks: 個股歷史數據
  - News: 新聞數據
- Docker 環境: 由 `OUTPUT_DIR` 環境變數指定

### Q: 如何新增自訂市場指數?

A: 編輯 `config/indices.yaml`,新增市場配置:
```yaml
global_indices:
  台灣:
    台積電:
      symbol: "2330.TW"
      fetch_news: true
```

## 授權

MIT License

## 維護者

Financial Analysis System Team
