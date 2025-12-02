#!/usr/bin/env python3
"""
每日市場分析腳本 - Market Intelligence System (MIS)
使用 Claude + Ollama 雙引擎分析當日市場數據

作者: Market Intelligence System Team
用途: 自動讀取市場指數、持股價格、新聞,調用 AI 分析並生成市場情報報告
"""

import os
import sys
from pathlib import Path
from datetime import datetime
from typing import List, Optional

# 將 src 目錄加入 Python 路徑，便於引用 legacy 套件
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from legacy import ClaudeAnalyzer, OllamaAnalyzer


class DailyMarketAnalyzer:
    """每日市場分析器"""

    def __init__(self):
        self.today = datetime.now().strftime("%Y-%m-%d")
        self.year = datetime.now().strftime("%Y")

        # 資料路徑
        self.output_dir = Path("output/market-data") / self.year
        self.daily_dir = self.output_dir / "Daily"
        self.news_dir = self.output_dir / "News"
        self.analysis_dir = Path("reports/markdown")

        # 檔案路徑
        self.global_indices_file = self.daily_dir / f"global-indices-{self.today}.md"
        self.prices_file = self.daily_dir / f"holdings-prices-{self.today}.md"
        self.analysis_output = self.analysis_dir / f"market-analysis-{self.today}.md"

        # 初始化分析器
        self.claude = None
        self.ollama = None

    def check_data_files(self) -> bool:
        """檢查必要的資料檔案是否存在"""
        missing_files = []

        if not self.global_indices_file.exists():
            missing_files.append(f"全球指數檔案: {self.global_indices_file}")

        if not self.prices_file.exists():
            missing_files.append(f"持倉價格檔案: {self.prices_file}")

        if missing_files:
            print("⚠️  警告: 以下資料檔案不存在:")
            for file in missing_files:
                print(f"  - {file}")
            print("\n請先執行爬蟲腳本:")
            print("  make fetch-all")
            return False

        return True

    def collect_news_files(self) -> List[Path]:
        """收集當日新聞檔案"""
        print("📰 收集當日新聞檔案...")

        news_files = list(self.news_dir.glob(f"*-{self.today}.md"))
        print(f"   找到 {len(news_files)} 個新聞檔案")

        return news_files

    def initialize_analyzers(self, use_ollama: bool = True) -> bool:
        """初始化 AI 分析器"""
        print("🤖 初始化 AI 分析引擎...")

        # 初始化 Claude 分析器
        self.claude = ClaudeAnalyzer()
        if not self.claude.initialize():
            print("   ❌ Claude 初始化失敗")
            return False
        print("   ✅ Claude 分析器已就緒")

        # 初始化 Ollama 分析器 (可選)
        if use_ollama:
            self.ollama = OllamaAnalyzer()
            if self.ollama.initialize():
                print("   ✅ Ollama 分析器已就緒")
            else:
                print("   ⚠️  Ollama 未安裝,將跳過預處理步驟")
                self.ollama = None

        return True

    def generate_market_analysis_prompt(self, news_files: List[Path]) -> str:
        """生成市場分析 Prompt"""
        print("📝 生成分析 Prompt...")

        # 讀取全球指數數據
        with open(self.global_indices_file, 'r', encoding='utf-8') as f:
            indices_data = f.read()

        # 讀取持倉價格數據
        with open(self.prices_file, 'r', encoding='utf-8') as f:
            prices_data = f.read()

        # 讀取新聞數據
        news_data = ""
        for news_file in news_files:
            symbol = news_file.stem.replace(f"-{self.today}", "")
            with open(news_file, 'r', encoding='utf-8') as f:
                news_content = f.read()
            news_data += f"\n\n### {symbol} 新聞\n{news_content}"

        # 生成 Prompt
        prompt = f"""你是一位專業的市場情報分析師,擅長解讀全球市場數據和新聞,提供深度市場洞察。

## 📋 分析任務

請根據以下今日市場數據,生成一份完整的**市場情報分析報告**。

### 核心要求:
1. **市場趨勢分析**: 識別全球市場的主要趨勢和驅動因素
2. **新聞影響評估**: 深度解讀重要新聞對市場的潛在影響
3. **持倉表現分析**: 評估持股表現並提供操作建議
4. **風險與機會**: 識別當前市場風險和投資機會
5. **可執行建議**: 提供具體、可操作的投資策略

### 報告風格:
- 專業但易懂
- 數據驅動,洞察為先
- 結構清晰,重點突出
- 避免模糊建議,提供具體方向

---

## 📊 今日市場數據

### 全球市場指數
```markdown
{indices_data}
```

### 持倉股票價格
```markdown
{prices_data}
```

### 市場新聞
```markdown
{news_data}
```

---

## 📄 報告結構

請按照以下結構生成報告:

# 📈 市場情報分析 - {self.today}

> **報告生成時間**: {datetime.now().strftime("%Y-%m-%d %H:%M UTC")}
> **分析引擎**: Market Intelligence System
> **報告類型**: 每日市場情報

---

## 📊 執行摘要

### 市場概況
[用 2-3 段文字總結今日全球市場表現,包含:]
- 主要市場趨勢 (美股、亞股、歐股)
- 關鍵驅動因素
- 市場情緒指標 (VIX)
- 重要事件或數據

### 關鍵數據

| 指標 | 數值 | 變化 | 狀態 |
|------|------|------|------|
| S&P 500 | X,XXX.XX | +X.XX% | 🟢/🔴 描述 |
| Nasdaq | XX,XXX.XX | +X.XX% | 🟢/🔴 描述 |
| VIX | XX.XX | +X.XX% | 🟢/🔴 描述 |
| 台股加權 | XX,XXX.XX | +X.XX% | 🟢/🔴 描述 |
| 黃金 | $X,XXX | +X.XX% | 🟢/🔴 描述 |

### 市場情緒評估

| 類別 | 評分 (1-10) | 說明 |
|------|-------------|------|
| 整體市場情緒 | X | 簡短說明 |
| 科技股情緒 | X | 簡短說明 |
| 波動性風險 | X | 簡短說明 |

---

## 🌍 全球市場分析

### 美國市場 🇺🇸

**主要指數表現**

| 指數 | 收盤價 | 漲跌幅 | 技術狀態 |
|------|--------|--------|----------|
| S&P 500 | X,XXX.XX | +X.XX% | 描述 |
| Nasdaq | XX,XXX.XX | +X.XX% | 描述 |
| Dow Jones | XX,XXX.XX | +X.XX% | 描述 |

**市場分析**:
[深入分析美國市場的表現,包含:]
- 主要驅動因素
- 產業輪動情況
- 技術面關鍵水平
- 後市展望

### 亞洲市場 🌏

**主要市場表現**

| 市場 | 指數 | 收盤價 | 漲跌幅 |
|------|------|--------|--------|
| 🇹🇼 台灣 | 加權指數 | XX,XXX.XX | +X.XX% |
| 🇯🇵 日本 | 日經225 | XX,XXX.XX | +X.XX% |
| 🇰🇷 韓國 | KOSPI | X,XXX.XX | +X.XX% |

**市場分析**:
[分析亞洲市場趨勢和關鍵因素]

### 歐洲市場 🇪🇺

**市場分析**:
[簡要分析歐洲市場]

---

## 💼 持倉股票分析

### 整體表現

| 分類 | 數量 | 平均漲跌 | 說明 |
|------|------|----------|------|
| 強勢上漲 (>+2%) | X 檔 | +X.XX% | 概述 |
| 穩健上漲 (+0%~+2%) | X 檔 | +X.XX% | 概述 |
| 輕微下跌 (0%~-2%) | X 檔 | -X.XX% | 概述 |
| 重大虧損 (<-2%) | X 檔 | -X.XX% | 概述 |

### 重點持股分析

[針對表現突出的股票 (漲跌幅 > 2%) 進行詳細分析:]

#### 📈 TICKER - 公司名稱 (+X.XX%)

**價格資訊**:
- 收盤價: $XXX.XX
- 變化: +X.XX% (+$X.XX)
- 當日區間: $XXX.XX - $XXX.XX

**分析**:
[結合新聞和市場數據,深入分析漲跌原因]

**操作建議**:
- **建議**: 持有 / 加碼 / 減碼 / 觀望
- **理由**: 具體說明
- **目標價**: $XXX.XX (如適用)

---

## 📰 重要新聞解讀

[按主題或產業分類,深入解讀影響市場的重要新聞:]

### 科技產業

#### 新聞標題
[深度分析新聞內容、市場影響、投資啟示]

### 其他產業

#### 新聞標題
[同上]

---

## ⚠️ 風險與機會

### 市場風險

1. **風險1**: 詳細說明
2. **風險2**: 詳細說明

### 投資機會

1. **機會1**: 詳細說明
2. **機會2**: 詳細說明

### VIX 恐慌指數分析

- **當前值**: XX.XX
- **變化**: ±X.XX%
- **解讀**: [分析市場情緒]

---

## 💡 投資策略建議

### 短期策略 (1-2週)

**市場觀點**: [總結短期看法]

**具體建議**:
1. **建議1**: 詳細說明操作方向和條件
2. **建議2**: 詳細說明

**觸發式指令**:
- 如果 XXX,則執行 YYY 操作

### 中長期策略

**配置建議**: [說明配置方向]

---

## 🔮 後市展望

### 關鍵催化劑

**未來一週關注**:
1. 事件1: 時間、預期影響
2. 事件2: 時間、預期影響

### 情境分析

#### 樂觀情境 (機率: XX%)
[條件、預期影響、策略]

#### 基準情境 (機率: XX%)
[同上]

#### 悲觀情境 (機率: XX%)
[同上]

---

## ✅ 行動清單

### 立即執行 (本週)

- [ ] **行動1**: 具體描述
- [ ] **行動2**: 具體描述

### 中期追蹤

- [ ] **行動1**: 具體描述

---

## ⚠️ 免責聲明

本報告僅供參考,不構成投資建議。投資有風險,請根據自身情況做出獨立決策。

---

**報告製作**: Market Intelligence System
**分析引擎**: Claude AI + Ollama AI
**數據來源**: Yahoo Finance
**報告版本**: v1.0

---

請直接開始生成完整的市場情報分析報告,從標題開始,不要有任何前置說明或詢問。
"""

        return prompt

    def run_analysis(self) -> bool:
        """執行完整的市場分析流程"""
        print("=" * 60)
        print("📊 Market Intelligence System - 每日市場分析")
        print("=" * 60)
        print(f"\n📅 分析日期: {self.today}\n")

        # 1. 檢查資料檔案
        print("🔍 檢查資料檔案...")
        if not self.check_data_files():
            return False
        print("   ✅ 資料檔案完整\n")

        # 2. 收集新聞檔案
        news_files = self.collect_news_files()
        print()

        # 3. 初始化分析器
        if not self.initialize_analyzers(use_ollama=False):  # 暫時不使用 Ollama
            return False
        print()

        # 4. 確保分析目錄存在
        self.analysis_dir.mkdir(parents=True, exist_ok=True)

        # 5. 生成分析 Prompt
        prompt = self.generate_market_analysis_prompt(news_files)
        print("   ✅ Prompt 已生成\n")

        # 6. 調用 Claude 進行分析
        print("🧠 調用 Claude 進行市場分析...")
        print("   這可能需要幾分鐘,請稍候...\n")

        try:
            # 使用 Claude 進行分析
            result = self.claude._call_claude(
                system_prompt="你是一位專業的市場情報分析師,擅長深度市場分析和投資洞察。",
                user_prompt=prompt,
                max_tokens=8192,  # 長報告需要更多 tokens
                temperature=0.7
            )

            if result:
                # 儲存分析結果
                with open(self.analysis_output, 'w', encoding='utf-8') as f:
                    f.write(result)

                print("   ✅ 分析完成!\n")
                print("=" * 60)
                print("📄 分析報告已保存至:")
                print(f"   {self.analysis_output}")
                print("=" * 60)
                print()

                # 顯示 token 使用統計
                token_usage = self.claude.get_token_usage()
                print(f"📊 Token 使用統計:")
                print(f"   Input: {token_usage['input']:,} tokens")
                print(f"   Output: {token_usage['output']:,} tokens")
                print(f"   Total: {token_usage['input'] + token_usage['output']:,} tokens")
                print()

                # 顯示報告前 30 行預覽
                print("📋 報告預覽 (前 30 行):")
                print("-" * 60)
                with open(self.analysis_output, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                    for line in lines[:30]:
                        print(line.rstrip())
                print("-" * 60)
                print()
                print(f"💡 查看完整報告: cat {self.analysis_output}")

                return True
            else:
                print("   ❌ 分析失敗")
                return False

        except Exception as e:
            print(f"   ❌ 分析過程發生錯誤: {e}")
            return False


def main():
    """主程式"""
    analyzer = DailyMarketAnalyzer()
    success = analyzer.run_analysis()

    if success:
        print("\n✅ 每日市場分析完成!")
        sys.exit(0)
    else:
        print("\n❌ 分析失敗")
        sys.exit(1)


if __name__ == "__main__":
    main()
