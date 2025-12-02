# 市場分析引擎模組

統一的市場分析器介面,支援多種 AI 分析引擎,專注於市場趨勢、指數、新聞等市場層面的分析。

## 架構設計

```
analyzers/
├── __init__.py           # 模組入口
├── analyzer_base.py      # 抽象基類
├── claude_analyzer.py    # Claude 市場分析器
├── ollama_analyzer.py    # Ollama 市場分析器
└── README.md            # 本檔案
```

## 分析器對比

| 功能 | Claude | Ollama |
|------|--------|--------|
| **深度分析** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **速度** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **成本** | 付費 API | 免費 (本地) |
| **適用場景** | 深度市場趨勢分析、投資建議、風險評估 | 大量新聞篩選、情緒分析、快速摘要 |

## 雙引擎協作流程

```
┌─────────────┐
│ 大量市場新聞 │ (例如: 100 則新聞)
└──────┬──────┘
       │
       ▼
┌──────────────┐
│   Ollama     │ 快速篩選 (本地免費)
│ - 評估重要性  │
│ - 情緒分析   │
│ - 關鍵字提取 │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ 篩選後資料   │ (例如: 10 則重要新聞)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Claude     │ 深度分析 (付費精準)
│ - 市場趨勢   │
│ - 影響評估   │
│ - 投資洞察   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ 市場分析報告  │
└──────────────┘
```

## 安裝依賴

```bash
# Claude 分析器
pip install anthropic

# Ollama 分析器
pip install ollama

# 本地安裝 Ollama (如果還沒安裝)
# macOS/Linux:
curl -fsSL https://ollama.com/install.sh | sh

# 下載模型
ollama pull llama3.1:8b
# 或中文友好的模型:
ollama pull qwen2.5:14b
```

## 快速開始

### 1. Claude 分析器

```python
from analyzers import ClaudeAnalyzer

# 初始化 (自動從環境變數讀取 CLAUDE_API_KEY)
analyzer = ClaudeAnalyzer()

if analyzer.initialize():
    # 分析市場指數
    result = analyzer.analyze_market_indices(
        "output/global-indices-2025-12-01.md",
        regions=['美國', '台灣', '日本'],
        focus='trend'
    )
    print(result)

    # 查看 token 使用量
    print(analyzer.get_token_usage())
```

### 2. Ollama 分析器

```python
from analyzers import OllamaAnalyzer

# 初始化
analyzer = OllamaAnalyzer(model="llama3.1:8b")

if analyzer.initialize():
    # 篩選重要新聞 (從 100 則篩選出 10 則)
    important_news = analyzer.analyze_market_news(
        all_news_items,
        top_k=10,
        sentiment=True
    )
    print(important_news)

    # 情緒分析
    sentiment = analyzer.sentiment_analysis("市場今日大幅上漲...")
    print(sentiment)
    # {'sentiment': 'positive', 'score': 0.7, 'confidence': 0.8}
```

### 3. 雙引擎協作範例

```python
from analyzers import ClaudeAnalyzer, OllamaAnalyzer

# 初始化兩個分析器
ollama = OllamaAnalyzer()
claude = ClaudeAnalyzer()

ollama.initialize()
claude.initialize()

# Step 1: Ollama 快速篩選 100 則新聞 → 10 則重要新聞
all_news = load_all_news()  # 100 則新聞
important_news = ollama.analyze_market_news(all_news, top_k=10)

# Step 2: Claude 深度分析這 10 則新聞
analysis = claude.analyze_market_news(important_news)

print(analysis)

# 成本節省: 只用 Claude 分析 10 則,而非 100 則!
print(f"Ollama 推論次數: {ollama.get_inference_count()}")
print(f"Claude Token 使用: {claude.get_token_usage()}")
```

## API 參考

### AnalyzerBase (基類)

所有分析器的抽象基類,定義統一介面。

#### 核心方法

- `initialize() -> bool`: 初始化分析器
- `analyze_market_indices(data_path, **kwargs) -> str`: 分析市場指數
- `analyze_market_news(news_items, **kwargs) -> str`: 分析市場新聞
- `analyze_holdings_performance(holdings_data, **kwargs) -> str`: 分析持股表現

#### 輔助方法

- `summarize(text, max_length) -> str`: 摘要生成
- `extract_keywords(text, top_k) -> List[str]`: 關鍵字提取
- `sentiment_analysis(text) -> Dict`: 情緒分析
- `get_status() -> Dict`: 取得狀態

### ClaudeAnalyzer

深度市場分析引擎。

#### 初始化

```python
analyzer = ClaudeAnalyzer(
    api_key="sk-ant-...",  # 可選,預設從環境變數讀取
    model="claude-sonnet-4-20250514",
    config={}
)
```

#### 特殊方法

- `get_token_usage() -> Dict[str, int]`: 取得 token 使用統計
- `reset_token_usage()`: 重置統計

### OllamaAnalyzer

快速預處理引擎。

#### 初始化

```python
analyzer = OllamaAnalyzer(
    model="llama3.1:8b",  # 或 "qwen2.5:14b", "mistral:7b"
    host="http://localhost:11434",
    config={}
)
```

#### 特殊方法

- `get_inference_count() -> int`: 取得推論次數
- `reset_inference_count()`: 重置統計

## 環境變數

```bash
# Claude API Key
export CLAUDE_API_KEY="sk-ant-..."
# 或
export ANTHROPIC_API_KEY="sk-ant-..."

# Ollama 服務地址 (可選)
export OLLAMA_HOST="http://localhost:11434"
```

## 最佳實踐

### 1. 成本優化

```python
# ❌ 不好的做法: 直接用 Claude 分析 100 則新聞
for news in all_100_news:
    claude.analyze_market_news([news])  # 高成本!

# ✅ 好的做法: 先用 Ollama 篩選
top_10 = ollama.analyze_market_news(all_100_news, top_k=10)
claude.analyze_market_news(top_10)  # 成本降低 90%!
```

### 2. 錯誤處理

```python
analyzer = ClaudeAnalyzer()

if not analyzer.initialize():
    print("初始化失敗,請檢查 API key")
    exit(1)

try:
    result = analyzer.analyze_market_indices("output/global-indices-2025-12-01.md")
except Exception as e:
    print(f"分析失敗: {e}")
```

### 3. 批次處理

```python
# 批次分析多個市場指數檔案
from pathlib import Path

indices_files = Path("output").glob("global-indices-*.md")
for file in indices_files:
    result = analyzer.analyze_market_indices(str(file))
    # 儲存分析結果
    output_path = Path("analysis") / f"analysis-{file.stem}.md"
    analyzer.save_analysis(result, output_path)
```

## 常見問題

### Q: Claude API key 要去哪裡取得?

A: 前往 [Anthropic Console](https://console.anthropic.com/) 註冊並建立 API key。

### Q: Ollama 推論很慢怎麼辦?

A:
1. 使用更小的模型 (例如 `llama3.1:8b` 而非 `14b`)
2. 確保有足夠的 RAM (建議 16GB+)
3. 考慮使用 GPU 加速

### Q: 如何新增自訂分析器?

A: 繼承 `AnalyzerBase` 並實作抽象方法:

```python
from analyzers import AnalyzerBase

class MyAnalyzer(AnalyzerBase):
    def initialize(self):
        # 實作初始化邏輯
        pass

    def analyze_market_indices(self, data_path, **kwargs):
        # 實作分析邏輯
        pass

    def analyze_market_news(self, news_items, **kwargs):
        # 實作分析邏輯
        pass

    def analyze_holdings_performance(self, holdings_data, **kwargs):
        # 實作分析邏輯
        pass
```

## 開發狀態

- [x] 抽象基類設計
- [x] Claude 市場分析器實作
- [x] Ollama 市場分析器實作
- [ ] 更多分析器 (OpenAI GPT, Gemini 等)
- [ ] 快取機制
- [ ] 並行處理
- [ ] 分析品質評估

## 授權

MIT License
