"""
Ollama 市場分析器
使用本地 Ollama 模型進行快速市場數據預處理和篩選
"""

import os
import re
from typing import Dict, List, Optional, Any
from pathlib import Path
from datetime import datetime

try:
    import ollama
    OLLAMA_AVAILABLE = True
except ImportError:
    OLLAMA_AVAILABLE = False
    print("警告: ollama 套件未安裝,請執行: pip install ollama")

from .analyzer_base import AnalyzerBase


class OllamaAnalyzer(AnalyzerBase):
    """
    Ollama 市場分析器

    負責快速處理市場分析任務:
    - 市場指數快速摘要
    - 大量新聞初步篩選
    - 新聞情緒分析
    - 關鍵字提取

    優勢: 本地運行、免費、快速
    用途: 預處理大量市場資料,減少 Claude API 調用成本
    """

    def __init__(self, model: str = "llama3.1:8b", host: str = "http://localhost:11434", config: Optional[Dict[str, Any]] = None):
        """
        初始化 Ollama 分析器

        Args:
            model: Ollama 模型名稱 (推薦: llama3.1:8b, qwen2.5:14b)
            host: Ollama 服務地址
            config: 配置字典
        """
        super().__init__(name="Ollama", config=config)
        self.model = model
        self.host = host
        self._inference_count = 0

    def initialize(self) -> bool:
        """
        初始化 Ollama 客戶端並檢查模型可用性

        Returns:
            bool: 初始化是否成功
        """
        if not OLLAMA_AVAILABLE:
            print("錯誤: ollama 套件未安裝")
            return False

        try:
            # 檢查 Ollama 服務是否運行
            models = ollama.list()
            available_models = [m['name'] for m in models.get('models', [])]

            if not any(self.model in m for m in available_models):
                print(f"警告: 模型 {self.model} 未安裝")
                print(f"可用模型: {', '.join(available_models)}")
                print(f"請執行: ollama pull {self.model}")
                return False

            self._initialized = True
            print(f"✓ Ollama 市場分析器初始化成功 (模型: {self.model})")
            return True

        except Exception as e:
            print(f"錯誤: Ollama 初始化失敗 - {e}")
            print("請確認 Ollama 服務正在運行: ollama serve")
            return False

    def _generate(self, prompt: str, system: Optional[str] = None, max_tokens: int = 2048, temperature: float = 0.7) -> Optional[str]:
        """
        呼叫 Ollama 生成

        Args:
            prompt: 提示文字
            system: 系統提示 (可選)
            max_tokens: 最大 token 數
            temperature: 溫度參數

        Returns:
            Optional[str]: 生成的文字,失敗返回 None
        """
        if not self._initialized:
            print("錯誤: Ollama 分析器未初始化")
            return None

        try:
            options = {
                'num_predict': max_tokens,
                'temperature': temperature,
            }

            response = ollama.generate(
                model=self.model,
                prompt=prompt,
                system=system,
                options=options
            )

            self._inference_count += 1
            return response['response']

        except Exception as e:
            print(f"錯誤: Ollama 生成失敗 - {e}")
            return None

    def analyze_market_indices(self, data_path: str, **kwargs) -> str:
        """
        分析市場指數數據 (快速摘要)

        Args:
            data_path: 市場指數數據檔案路徑
            **kwargs: 額外參數
                - regions: 關注的地區列表
                - focus: 分析重點

        Returns:
            str: 分析結果 (Markdown 格式)
        """
        if not self._initialized:
            return "錯誤: Ollama 分析器未初始化"

        try:
            with open(data_path, 'r', encoding='utf-8') as f:
                market_data = f.read()

            regions = kwargs.get('regions', ['全球'])
            focus = kwargs.get('focus', 'trend')

            system = "你是一位市場分析助手。請提供簡潔的市場摘要,重點關注關鍵趨勢和異常變化。"

            prompt = f"""請分析以下全球市場指數數據並提供簡短摘要 (300字以內):

{market_data}

關注地區: {', '.join(regions)}
分析重點: {focus}

請提供:
1. 整體市場走勢 (漲/跌)
2. 表現最好和最差的地區
3. 需要注意的異常變化

摘要:"""

            result = self._generate(prompt, system=system, max_tokens=512, temperature=0.5)
            return result or "分析失敗"

        except Exception as e:
            return f"錯誤: 分析市場指數時發生錯誤 - {e}"

    def analyze_market_news(self, news_items: List[Dict[str, Any]], **kwargs) -> str:
        """
        分析市場新聞 (篩選重要新聞)

        Args:
            news_items: 新聞項目列表
            **kwargs: 額外參數
                - top_k: 返回前 K 則新聞 (預設: 10)
                - sentiment: 是否包含情緒分析

        Returns:
            str: 篩選後的重要新聞 (Markdown 格式)
        """
        if not self._initialized:
            return "錯誤: Ollama 分析器未初始化"

        top_k = kwargs.get('top_k', 10)
        include_sentiment = kwargs.get('sentiment', True)

        # 使用 Ollama 評估每則新聞的重要性
        scored_news = []
        print(f"開始篩選 {len(news_items)} 則新聞...")

        for i, item in enumerate(news_items, 1):
            if i % 10 == 0:
                print(f"  處理進度: {i}/{len(news_items)}")

            title = item.get('title', '')
            importance = self._rate_news_importance(title, item.get('summary', ''))

            result = {
                'news': item,
                'importance': importance
            }

            if include_sentiment:
                sentiment = self.sentiment_analysis(title)
                result['sentiment'] = sentiment

            scored_news.append(result)

        # 排序並取前 K 則
        scored_news.sort(key=lambda x: x['importance'], reverse=True)
        top_news = scored_news[:top_k]

        # 格式化輸出
        lines = ["# 重要新聞篩選結果\n"]
        lines.append(f"> 從 {len(news_items)} 則新聞中篩選出最重要的 {len(top_news)} 則\n")

        for i, item in enumerate(top_news, 1):
            news = item['news']
            importance = item['importance']
            lines.append(f"## {i}. {news.get('title', '無標題')} (重要性: {importance}/10)")

            if include_sentiment and 'sentiment' in item:
                sentiment_emoji = {'positive': '📈', 'negative': '📉', 'neutral': '➡️'}
                sentiment = item['sentiment']['sentiment']
                lines.append(f"**情緒**: {sentiment_emoji.get(sentiment, '➡️')} {sentiment}")

            if summary := news.get('summary'):
                lines.append(f"\n{summary}\n")

            if source := news.get('source'):
                lines.append(f"*來源: {source}*\n")

        return '\n'.join(lines)

    def analyze_holdings_performance(self, holdings_data: Dict[str, Any], **kwargs) -> str:
        """
        分析持股表現 (快速評估)

        Args:
            holdings_data: 持股價格數據
            **kwargs: 額外參數
                - benchmark: 基準指數

        Returns:
            str: 分析結果 (Markdown 格式)
        """
        if not self._initialized:
            return "錯誤: Ollama 分析器未初始化"

        benchmark = kwargs.get('benchmark', '^GSPC')

        system = "你是一位投資組合分析助手。提供簡潔的持股表現評估。"

        holdings_text = self._format_holdings_data(holdings_data)

        prompt = f"""請簡要分析以下持股表現 (200字以內):

{holdings_text}

基準指數: {benchmark}

請提供:
1. 整體表現評估
2. 表現最好的 2-3 檔
3. 表現最差的 2-3 檔

評估:"""

        result = self._generate(prompt, system=system, max_tokens=512, temperature=0.5)
        return result or "分析失敗"

    def _rate_news_importance(self, title: str, summary: str) -> int:
        """
        評估新聞重要性

        Args:
            title: 新聞標題
            summary: 新聞摘要

        Returns:
            int: 重要性評分 (1-10)
        """
        system = "你是新聞分析專家。評估新聞對市場的重要性。"

        prompt = f"""請評估以下新聞的市場重要性 (1-10分):

標題: {title}
摘要: {summary[:200]}

只回答一個數字 (1-10),不需要其他文字。

評分:"""

        result = self._generate(prompt, system=system, max_tokens=10, temperature=0.3)

        # 提取數字
        if result:
            match = re.search(r'\d+', result)
            if match:
                score = int(match.group())
                return min(max(score, 1), 10)  # 限制在 1-10 之間

        return 5  # 預設中等重要性

    def sentiment_analysis(self, text: str, **kwargs) -> Dict[str, Any]:
        """
        情緒分析

        Args:
            text: 要分析的文字
            **kwargs: 額外參數

        Returns:
            Dict[str, Any]: 情緒分析結果
        """
        if not self._initialized:
            return super().sentiment_analysis(text, **kwargs)

        system = "你是情緒分析專家。分析文字的整體情緒傾向。"

        prompt = f"""請分析以下文字的情緒:

{text[:500]}

只回答以下格式:
情緒: [positive/negative/neutral]
分數: [-1.0 到 1.0]
信心: [0.0 到 1.0]

分析:"""

        result = self._generate(prompt, system=system, max_tokens=128, temperature=0.3)

        # 解析結果
        if result:
            sentiment = 'neutral'
            score = 0.0
            confidence = 0.5

            if 'positive' in result.lower():
                sentiment = 'positive'
                score = 0.7
            elif 'negative' in result.lower():
                sentiment = 'negative'
                score = -0.7

            # 嘗試提取數值
            score_match = re.search(r'分數[:\s]+([-+]?\d*\.?\d+)', result)
            if score_match:
                score = float(score_match.group(1))

            conf_match = re.search(r'信心[:\s]+(\d*\.?\d+)', result)
            if conf_match:
                confidence = float(conf_match.group(1))

            return {
                'sentiment': sentiment,
                'score': score,
                'confidence': confidence
            }

        return super().sentiment_analysis(text, **kwargs)

    def extract_keywords(self, text: str, top_k: int = 5, **kwargs) -> List[str]:
        """
        關鍵字提取

        Args:
            text: 要提取關鍵字的文字
            top_k: 提取前 K 個關鍵字
            **kwargs: 額外參數

        Returns:
            List[str]: 關鍵字列表
        """
        if not self._initialized:
            return super().extract_keywords(text, top_k, **kwargs)

        system = "你是關鍵字提取專家。從文字中提取最重要的關鍵字。"

        prompt = f"""請從以下文字中提取 {top_k} 個最重要的關鍵字:

{text[:1000]}

只列出關鍵字,用逗號分隔,不需要其他文字。

關鍵字:"""

        result = self._generate(prompt, system=system, max_tokens=128, temperature=0.3)

        if result:
            # 解析關鍵字
            keywords = [k.strip() for k in result.split(',')]
            return keywords[:top_k]

        return []

    def summarize(self, text: str, max_length: int = 200, **kwargs) -> str:
        """
        摘要生成

        Args:
            text: 要摘要的文字
            max_length: 最大長度
            **kwargs: 額外參數

        Returns:
            str: 摘要文字
        """
        if not self._initialized:
            return super().summarize(text, max_length, **kwargs)

        system = "你是摘要生成專家。提供簡潔準確的摘要。"

        prompt = f"""請將以下文字摘要為 {max_length} 字以內:

{text}

摘要:"""

        result = self._generate(prompt, system=system, max_tokens=512, temperature=0.5)
        return result or super().summarize(text, max_length, **kwargs)

    def _format_holdings_data(self, holdings_data: Dict[str, Any]) -> str:
        """格式化持股數據為可讀文字"""
        lines = []
        for ticker, data in holdings_data.items():
            lines.append(f"### {ticker}")
            for key, value in data.items():
                lines.append(f"- {key}: {value}")
            lines.append("")
        return '\n'.join(lines)

    def get_inference_count(self) -> int:
        """
        取得推論次數

        Returns:
            int: 推論次數
        """
        return self._inference_count

    def reset_inference_count(self):
        """重置推論次數"""
        self._inference_count = 0

    def get_status(self) -> Dict[str, Any]:
        """
        取得分析器狀態

        Returns:
            Dict[str, Any]: 狀態字典
        """
        status = super().get_status()
        status['model'] = self.model
        status['host'] = self.host
        status['inference_count'] = self._inference_count
        return status
