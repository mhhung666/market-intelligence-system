"""
市場數據分析引擎抽象基類
定義所有市場分析器的統一介面
"""

from abc import ABC, abstractmethod
from typing import Dict, List, Optional, Any
from pathlib import Path
from datetime import datetime


class AnalyzerBase(ABC):
    """
    市場分析器抽象基類

    所有市場分析器(Claude, Ollama等)都必須繼承此類並實作其抽象方法
    專注於市場趨勢、指數、新聞等市場數據的分析
    """

    def __init__(self, name: str, config: Optional[Dict[str, Any]] = None):
        """
        初始化分析器

        Args:
            name: 分析器名稱
            config: 配置字典 (可選)
        """
        self.name = name
        self.config = config or {}
        self._initialized = False

    @abstractmethod
    def initialize(self) -> bool:
        """
        初始化分析器 (例如檢查 API key、載入模型等)

        Returns:
            bool: 初始化是否成功
        """
        pass

    @abstractmethod
    def analyze_market_indices(self, data_path: str, **kwargs) -> str:
        """
        分析市場指數數據

        Args:
            data_path: 市場指數數據檔案路徑 (例如: output/global-indices-2025-12-01.md)
            **kwargs: 額外參數
                - regions: 關注的地區列表
                - focus: 分析重點 (trend/volatility/correlation)

        Returns:
            str: 分析結果 (Markdown 格式)
        """
        pass

    @abstractmethod
    def analyze_market_news(self, news_items: List[Dict[str, Any]], **kwargs) -> str:
        """
        分析市場新聞

        Args:
            news_items: 新聞項目列表
            **kwargs: 額外參數
                - top_k: 篩選出最重要的 K 則新聞
                - sentiment: 是否包含情緒分析

        Returns:
            str: 分析結果 (Markdown 格式)
        """
        pass

    @abstractmethod
    def analyze_holdings_performance(self, holdings_data: Dict[str, Any], **kwargs) -> str:
        """
        分析持股表現

        Args:
            holdings_data: 持股價格數據
            **kwargs: 額外參數
                - benchmark: 基準指數 (例如: ^GSPC)

        Returns:
            str: 分析結果 (Markdown 格式)
        """
        pass

    def summarize(self, text: str, max_length: int = 200, **kwargs) -> str:
        """
        摘要生成 (可選實作)

        Args:
            text: 要摘要的文字
            max_length: 最大長度
            **kwargs: 額外參數

        Returns:
            str: 摘要文字
        """
        # 預設實作: 簡單截斷
        if len(text) <= max_length:
            return text
        return text[:max_length] + "..."

    def extract_keywords(self, text: str, top_k: int = 5, **kwargs) -> List[str]:
        """
        關鍵字提取 (可選實作)

        Args:
            text: 要提取關鍵字的文字
            top_k: 提取前 K 個關鍵字
            **kwargs: 額外參數

        Returns:
            List[str]: 關鍵字列表
        """
        # 預設實作: 返回空列表
        return []

    def sentiment_analysis(self, text: str, **kwargs) -> Dict[str, Any]:
        """
        情緒分析 (可選實作)

        Args:
            text: 要分析的文字
            **kwargs: 額外參數

        Returns:
            Dict[str, Any]: 情緒分析結果
            {
                'sentiment': 'positive' | 'negative' | 'neutral',
                'score': float,  # -1.0 到 1.0
                'confidence': float  # 0.0 到 1.0
            }
        """
        # 預設實作: 返回中性
        return {
            'sentiment': 'neutral',
            'score': 0.0,
            'confidence': 0.0
        }

    def batch_analyze(self, items: List[Any], analyze_fn: callable, **kwargs) -> List[Any]:
        """
        批次分析

        Args:
            items: 要分析的項目列表
            analyze_fn: 分析函數
            **kwargs: 額外參數

        Returns:
            List[Any]: 分析結果列表
        """
        results = []
        for item in items:
            try:
                result = analyze_fn(item, **kwargs)
                results.append(result)
            except Exception as e:
                print(f"分析項目時發生錯誤: {e}")
                results.append(None)
        return results

    def save_analysis(self, content: str, output_path: Path, **kwargs) -> bool:
        """
        儲存分析結果

        Args:
            content: 分析內容
            output_path: 輸出路徑
            **kwargs: 額外參數

        Returns:
            bool: 是否成功儲存
        """
        try:
            output_path.parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        except Exception as e:
            print(f"儲存分析結果時發生錯誤: {e}")
            return False

    def get_status(self) -> Dict[str, Any]:
        """
        取得分析器狀態

        Returns:
            Dict[str, Any]: 狀態字典
        """
        return {
            'name': self.name,
            'initialized': self._initialized,
            'config': self.config
        }

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(name='{self.name}')"
