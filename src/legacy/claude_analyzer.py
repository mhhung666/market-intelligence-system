"""
Claude 市場分析器
使用 Anthropic Claude API 進行深度市場數據分析
專注於市場指數、趨勢、新聞等市場層面的分析
"""

import os
from typing import Dict, List, Optional, Any
from pathlib import Path
from datetime import datetime

try:
    from anthropic import Anthropic
    ANTHROPIC_AVAILABLE = True
except ImportError:
    ANTHROPIC_AVAILABLE = False
    print("警告: anthropic 套件未安裝,請執行: pip install anthropic")

from .analyzer_base import AnalyzerBase


class ClaudeAnalyzer(AnalyzerBase):
    """
    Claude 市場分析器

    負責深度市場分析任務:
    - 全球市場指數趨勢分析
    - 市場新聞解讀與影響評估
    - 持股表現與市場關聯分析
    - 結構化市場報告生成
    """

    def __init__(self, api_key: Optional[str] = None, model: str = "claude-sonnet-4-20250514", config: Optional[Dict[str, Any]] = None):
        """
        初始化 Claude 分析器

        Args:
            api_key: Anthropic API Key (若為 None 則從環境變數讀取)
            model: Claude 模型名稱
            config: 配置字典
        """
        super().__init__(name="Claude", config=config)
        self.api_key = api_key or os.environ.get('CLAUDE_API_KEY') or os.environ.get('ANTHROPIC_API_KEY')
        self.model = model
        self.client = None
        self._token_usage = {'input': 0, 'output': 0}

    def initialize(self) -> bool:
        """
        初始化 Claude 客戶端

        Returns:
            bool: 初始化是否成功
        """
        if not ANTHROPIC_AVAILABLE:
            print("錯誤: anthropic 套件未安裝")
            return False

        if not self.api_key:
            print("錯誤: 未設定 CLAUDE_API_KEY 或 ANTHROPIC_API_KEY 環境變數")
            return False

        try:
            self.client = Anthropic(api_key=self.api_key)
            self._initialized = True
            print(f"✓ Claude 市場分析器初始化成功 (模型: {self.model})")
            return True
        except Exception as e:
            print(f"錯誤: Claude 初始化失敗 - {e}")
            return False

    def _call_claude(self, system_prompt: str, user_prompt: str, max_tokens: int = 4096, temperature: float = 0.7) -> Optional[str]:
        """
        呼叫 Claude API

        Args:
            system_prompt: 系統提示
            user_prompt: 使用者提示
            max_tokens: 最大 token 數
            temperature: 溫度參數

        Returns:
            Optional[str]: Claude 的回應,失敗返回 None
        """
        if not self._initialized or not self.client:
            print("錯誤: Claude 分析器未初始化")
            return None

        try:
            response = self.client.messages.create(
                model=self.model,
                max_tokens=max_tokens,
                temperature=temperature,
                system=system_prompt,
                messages=[
                    {"role": "user", "content": user_prompt}
                ]
            )

            # 記錄 token 使用量
            self._token_usage['input'] += response.usage.input_tokens
            self._token_usage['output'] += response.usage.output_tokens

            return response.content[0].text

        except Exception as e:
            print(f"錯誤: Claude API 呼叫失敗 - {e}")
            return None

    def analyze_market_indices(self, data_path: str, **kwargs) -> str:
        """
        分析市場指數數據

        Args:
            data_path: 市場指數數據檔案路徑 (例如: output/global-indices-2025-12-01.md)
            **kwargs: 額外參數
                - regions: 關注的地區列表 (例如: ['美國', '台灣', '日本'])
                - focus: 分析重點 (trend/volatility/correlation)

        Returns:
            str: 分析結果 (Markdown 格式)
        """
        if not self._initialized:
            return "錯誤: Claude 分析器未初始化"

        try:
            # 讀取市場指數數據
            with open(data_path, 'r', encoding='utf-8') as f:
                market_data = f.read()

            regions = kwargs.get('regions', ['全球'])
            focus = kwargs.get('focus', 'trend')

            system_prompt = """你是一位專業的市場分析師,擅長解讀全球市場指數數據並識別趨勢。

你的任務是:
1. 分析各地區市場指數的漲跌趨勢
2. 識別市場間的關聯性和領先滯後關係
3. 評估市場波動性和風險
4. 提供結構化的市場觀點

分析要客觀、專業,基於數據說話。"""

            user_prompt = f"""請分析以下全球市場指數數據:

{market_data}

關注地區: {', '.join(regions)}
分析重點: {focus}

請提供:
1. 市場概況摘要 (各地區主要指數漲跌)
2. 關鍵趨勢分析 (哪些市場領先?哪些落後?)
3. 波動性評估 (市場是否穩定?)
4. 市場關聯性 (是否同步移動?)
5. 風險與機會 (需要注意什麼?)

使用 Markdown 格式,包含清晰的標題和項目符號。"""

            result = self._call_claude(system_prompt, user_prompt, max_tokens=4096)
            return result or "分析失敗"

        except FileNotFoundError:
            return f"錯誤: 找不到檔案 {data_path}"
        except Exception as e:
            return f"錯誤: 分析市場指數時發生錯誤 - {e}"

    def analyze_market_news(self, news_items: List[Dict[str, Any]], **kwargs) -> str:
        """
        分析市場新聞

        Args:
            news_items: 新聞項目列表
            **kwargs: 額外參數
                - top_k: 只分析前 K 則重要新聞 (預設: 10)
                - sentiment: 是否包含情緒分析 (預設: True)

        Returns:
            str: 分析結果 (Markdown 格式)
        """
        if not self._initialized:
            return "錯誤: Claude 分析器未初始化"

        top_k = kwargs.get('top_k', 10)
        include_sentiment = kwargs.get('sentiment', True)
        news_to_analyze = news_items[:top_k]

        system_prompt = """你是一位新聞分析專家,擅長從市場新聞中提取關鍵資訊。

你的任務:
1. 識別最重要的市場新聞
2. 分析新聞對市場的潛在影響
3. 提取關鍵主題和趨勢
4. 評估整體市場情緒

保持客觀,區分事實和推測。"""

        news_text = self._format_news_items(news_to_analyze)

        user_prompt = f"""請分析以下市場新聞:

{news_text}

請提供:
1. 最重要的 3-5 則新聞摘要及影響
2. 關鍵主題分析 (有哪些重複出現的主題?)
3. 市場情緒評估 (整體偏樂觀/悲觀/中性?)
4. 潛在市場影響 (這些新聞可能如何影響市場走勢?)

使用 Markdown 格式。"""

        result = self._call_claude(system_prompt, user_prompt, max_tokens=3072)
        return result or "分析失敗"

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
        if not self._initialized:
            return "錯誤: Claude 分析器未初始化"

        benchmark = kwargs.get('benchmark', '^GSPC')

        system_prompt = """你是一位投資組合分析師,擅長評估持股表現與市場關聯。

你的任務:
1. 評估各持股的表現
2. 與基準指數對比
3. 識別表現優異和落後的持股
4. 提供持股調整建議

保持客觀,基於數據分析。"""

        holdings_text = self._format_holdings_data(holdings_data)

        user_prompt = f"""請分析以下持股表現:

{holdings_text}

基準指數: {benchmark}

請提供:
1. 整體表現摘要 (總報酬率、勝率)
2. 表現最佳的前 3 名持股
3. 表現最差的後 3 名持股
4. 與基準對比分析
5. 持股調整建議

使用 Markdown 格式。"""

        result = self._call_claude(system_prompt, user_prompt, max_tokens=3072)
        return result or "分析失敗"

    def _format_news_items(self, news_items: List[Dict[str, Any]]) -> str:
        """格式化新聞項目為可讀文字"""
        lines = []
        for i, item in enumerate(news_items, 1):
            title = item.get('title', '無標題')
            summary = item.get('summary', item.get('description', ''))
            source = item.get('source', '未知來源')
            lines.append(f"{i}. **{title}** (來源: {source})")
            if summary:
                lines.append(f"   {summary}")
            lines.append("")
        return '\n'.join(lines)

    def _format_holdings_data(self, holdings_data: Dict[str, Any]) -> str:
        """格式化持股數據為可讀文字"""
        lines = []
        for ticker, data in holdings_data.items():
            lines.append(f"### {ticker}")
            for key, value in data.items():
                lines.append(f"- {key}: {value}")
            lines.append("")
        return '\n'.join(lines)

    def get_token_usage(self) -> Dict[str, int]:
        """
        取得 token 使用統計

        Returns:
            Dict[str, int]: token 使用量
        """
        return self._token_usage.copy()

    def reset_token_usage(self):
        """重置 token 使用統計"""
        self._token_usage = {'input': 0, 'output': 0}

    def get_status(self) -> Dict[str, Any]:
        """
        取得分析器狀態

        Returns:
            Dict[str, Any]: 狀態字典
        """
        status = super().get_status()
        status['model'] = self.model
        status['token_usage'] = self._token_usage
        status['api_key_set'] = bool(self.api_key)
        return status
