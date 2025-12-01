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

### 全球指數爬蟲 (fetch_global_indices.py)

爬取全球主要市場指數數據。

```bash
# 基本用法
python scrapers/fetch_global_indices.py -r 台灣 美國

# 查看所有支援的區域
python scrapers/fetch_global_indices.py --help
```

支援的區域:
- 台灣: 台股加權、櫃買、台灣50等
- 美國: S&P 500、Nasdaq、道瓊等
- 日本: 日經225、TOPIX等
- 香港: 恆生指數、國企指數等
- 中國: 上證、深證、創業板等
- 韓國: KOSPI、KOSDAQ等
- 歐洲: 德DAX、法CAC、英FTSE等

### 持倉價格爬蟲 (fetch_holdings_prices.py)

獲取投資組合的即時價格。

```bash
python scrapers/fetch_holdings_prices.py
```

配置檔案: `config/holdings.yaml`

### 市場新聞爬蟲 (fetch_market_news.py)

收集市場新聞與消息。

```bash
python scrapers/fetch_market_news.py
```

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

## 常見問題

### Q: 爬蟲執行失敗?

A: 檢查:
1. 網路連線是否正常
2. Yahoo Finance API 是否可訪問
3. 輸出目錄權限是否正確

### Q: 輸出檔案在哪裡?

A:
- 本地環境: `output/market-data/{year}/`
- Docker 環境: 由 `OUTPUT_DIR` 環境變數指定

### Q: 如何新增自訂市場?

A: 編輯 `config/indices.yaml`,新增你的市場配置。

## 授權

MIT License

## 維護者

Financial Analysis System Team
