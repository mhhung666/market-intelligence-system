# Docker 部署指南

## 快速開始

### 1. 設定環境變數

複製 `.env.docker` 並填入你的 Claude token:

```bash
cp .env.docker .env
nano .env  # 編輯並填入 CLAUDE_TOKEN
```

#### 如何獲取 Claude Token

**方法 1: 使用 Claude CLI (推薦)**

```bash
# 在本機執行
npm install -g @anthropic-ai/claude-cli
claude login

# 登入後,查看 token
cat ~/.config/claude/config.json
# 複製 sessionKey 的值
```

**方法 2: 從瀏覽器獲取**

1. 登入 https://claude.ai
2. 開啟開發者工具 (F12)
3. 前往 Application/Storage → Cookies
4. 尋找 `sessionKey` 或相關的 session cookie
5. 複製該值到 `.env` 的 `CLAUDE_TOKEN`

### 2. 建立 Docker Image

```bash
docker-compose build
```

### 3. 運行方式

#### 方式 A: 手動執行 (推薦用於測試)

```bash
# 啟動容器
docker-compose up -d

# 執行完整分析
docker-compose exec mis make daily

# 只執行爬蟲
docker-compose exec mis make fetch-all

# 只執行 Claude 分析
docker-compose exec mis make analyze-daily

# 查看報告
docker-compose exec mis cat reports/markdown/market-analysis-$(date +%Y-%m-%d).md
```

#### 方式 B: 自動定時執行 (Cron)

```bash
# 啟動包含 cron 的服務
docker-compose --profile cron up -d

# 查看 cron 日誌
docker-compose logs -f mis-cron

# 查看執行記錄
docker-compose exec mis-cron tail -f /app/logs/cron.log
```

#### 方式 C: 單次執行後退出

```bash
# 執行完成後自動停止
docker-compose run --rm mis make daily
```

## 常用命令

### 容器管理

```bash
# 啟動服務
docker-compose up -d

# 停止服務
docker-compose down

# 重新建立 image
docker-compose build --no-cache

# 查看執行中的容器
docker-compose ps

# 查看日誌
docker-compose logs -f
```

### 進入容器執行命令

```bash
# 進入 bash
docker-compose exec mis bash

# 在容器內可執行任何 make 命令
docker-compose exec mis make fetch-global
docker-compose exec mis make analyze-daily
docker-compose exec mis make help
```

### 查看報告

```bash
# 列出所有報告
docker-compose exec mis ls -lh reports/markdown/

# 查看最新市場分析
docker-compose exec mis bash -c 'cat $(ls -t reports/markdown/market-analysis-*.md | head -1)'

# 查看最新持倉分析
docker-compose exec mis bash -c 'cat $(ls -t reports/markdown/holdings-analysis-*.md | head -1)'
```

## 數據持久化

以下目錄會自動掛載到宿主機,確保數據不會因容器重啟而丟失:

- `./output` - 爬蟲數據
- `./reports` - 分析報告
- `./config` - 配置檔案
- `./logs` - 執行日誌

## Cron 定時任務設定

編輯 `docker/crontab` 來調整執行時間:

```cron
# 每天早上 8:00 執行
0 8 * * * cd /app && make daily >> /app/logs/cron.log 2>&1

# 每天晚上 9:00 執行
0 21 * * * cd /app && make daily >> /app/logs/cron.log 2>&1
```

修改後重新啟動服務:

```bash
docker-compose --profile cron restart mis-cron
```

## 整合到現有 Cron (不使用 Docker Cron)

如果你想在宿主機使用 cron 呼叫 Docker:

```bash
# 編輯 crontab
crontab -e

# 加入以下內容
0 8 * * * cd /path/to/market-intelligence-system && docker-compose run --rm mis make daily >> logs/docker-cron.log 2>&1
0 21 * * * cd /path/to/market-intelligence-system && docker-compose run --rm mis make daily >> logs/docker-cron.log 2>&1
```

## 故障排除

### Claude CLI 無法認證

```bash
# 檢查 token 是否正確設定
docker-compose exec mis env | grep CLAUDE_TOKEN

# 測試 Claude CLI
docker-compose exec mis claude --version
docker-compose exec mis bash -c 'echo "test" | claude'
```

### 查看錯誤日誌

```bash
# 容器日誌
docker-compose logs mis

# Cron 日誌
docker-compose exec mis-cron cat /app/logs/cron.log

# Python 爬蟲日誌
docker-compose exec mis cat logs/*.log
```

### 重新建立容器

```bash
# 完全清理並重建
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

## 生產環境建議

### 1. 使用 Secrets 管理敏感資訊

不要直接在 `.env` 中寫入 token,建議使用:

- Docker Secrets
- 環境變數注入
- Vault 等密鑰管理工具

### 2. 設定日誌輪轉

```bash
# 在 docker-compose.yml 中加入
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 3. 健康檢查

```yaml
healthcheck:
  test: ["CMD", "claude", "--version"]
  interval: 1m
  timeout: 10s
  retries: 3
```

### 4. 資源限制

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 4G
    reservations:
      cpus: '1'
      memory: 2G
```

## 整合 GitHub Pages 自動部署

如果要在 Docker 中自動更新 GitHub Pages:

```bash
# 在容器內設定 git
docker-compose exec mis bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# 執行完整部署
docker-compose exec mis make deploy
```

或在 crontab 中加入:

```cron
# 每天分析完成後自動部署到 GitHub Pages
0 9 * * * cd /app && make deploy >> /app/logs/cron.log 2>&1
```

## 範例工作流程

### 開發/測試環境

```bash
# 1. 建立並啟動
docker-compose up -d

# 2. 測試爬蟲
docker-compose exec mis make fetch-all

# 3. 測試分析
docker-compose exec mis make analyze-daily

# 4. 查看結果
docker-compose exec mis ls -lh reports/markdown/
```

### 生產環境 (自動化)

```bash
# 1. 設定環境變數
cp .env.docker .env
nano .env  # 填入正確的 CLAUDE_TOKEN

# 2. 啟動 cron 服務
docker-compose --profile cron up -d

# 3. 驗證 cron 正在運行
docker-compose logs -f mis-cron

# 4. 定期檢查日誌
tail -f logs/cron.log
```

## 效能優化

### 使用本地 Ollama (可選)

如果宿主機有 GPU 且運行 Ollama:

```yaml
environment:
  - OLLAMA_HOST=http://host.docker.internal:11434
```

然後使用雙引擎分析:

```bash
docker-compose exec mis make analyze-all
```

這樣可以大幅降低 Claude API 成本!
