"""
市場分析引擎模組

提供統一的市場分析器介面,支援多種 AI 分析引擎。
"""

from .analyzer_base import AnalyzerBase
from .claude_analyzer import ClaudeAnalyzer
from .ollama_analyzer import OllamaAnalyzer

__all__ = [
    'AnalyzerBase',
    'ClaudeAnalyzer',
    'OllamaAnalyzer',
]

__version__ = '1.0.0'
