#!/usr/bin/env python3
"""
持倉股票價格獲取工具
從 holdings.md 檔案中提取股票代碼，並從 Yahoo Finance 獲取當天價格
"""

import re
from datetime import datetime
import yfinance as yf

from common import (
    create_argument_parser,
    write_output,
    print_status,
    print_error,
    print_warning,
    get_project_root,
    safe_exit,
)


def extract_holdings_from_md(holdings_file):
    """
    從 holdings.md 檔案中提取股票代碼

    Args:
        holdings_file: holdings.md 檔案路徑

    Returns:
        list: 股票代碼列表
    """
    holdings = []

    try:
        with open(holdings_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # 查找持倉明細表格
        # 匹配表格中的股票代碼行
        # 格式: | 股票代碼 | 公司名稱 | 股數 | ...
        # 支援: AAPL, SET.SI, BRK.B 等格式
        pattern = r'\|\s*([A-Z]+(?:\.[A-Z]+)?)\s*\|[^|]+\|[^|]+\|'

        in_holdings_section = False
        for line in content.split('\n'):
            # 偵測是否進入持倉明細區域
            if '## 📈 當前持倉' in line or '### 持倉明細' in line:
                in_holdings_section = True
                continue

            # 偵測是否離開持倉明細區域
            if in_holdings_section and line.startswith('##'):
                break

            # 在持倉明細區域內提取股票代碼
            if in_holdings_section:
                match = re.match(pattern, line)
                if match:
                    symbol = match.group(1)
                    # 排除表頭
                    if symbol not in ['股票代碼', 'Date', 'SYMBOL']:
                        holdings.append(symbol)

        print_status(f"從 {holdings_file} 中提取到 {len(holdings)} 隻股票")

    except FileNotFoundError:
        print_error(f"找不到檔案 {holdings_file}")
        safe_exit(False)
    except Exception as e:
        print_error(f"讀取檔案時發生錯誤: {e}")
        safe_exit(False)

    return holdings


def fetch_stock_price(symbol, verbose=False):
    """
    獲取單隻股票的當前價格資訊

    Args:
        symbol: 股票代碼
        verbose: 是否顯示詳細資訊

    Returns:
        dict: 包含股票資訊的字典，失敗返回 None
    """
    try:
        if verbose:
            print_status(f"正在獲取 {symbol} 的價格...")

        ticker = yf.Ticker(symbol)

        # 獲取最新價格資訊
        info = ticker.info

        # 獲取歷史數據（最近1天）
        hist = ticker.history(period='1d')

        if hist.empty:
            print_warning(f"{symbol} 無法獲取歷史數據")
            return None

        latest = hist.iloc[-1]

        # 提取關鍵資訊
        data = {
            'symbol': symbol,
            'name': info.get('longName', info.get('shortName', symbol)),
            'current_price': latest['Close'],
            'open': latest['Open'],
            'high': latest['High'],
            'low': latest['Low'],
            'volume': latest['Volume'],
            'previous_close': info.get('previousClose', latest['Close']),
            'market_cap': info.get('marketCap', None),
            'pe_ratio': info.get('trailingPE', None),
            'currency': info.get('currency', 'USD')
        }

        # 計算漲跌幅
        if data['previous_close'] and data['previous_close'] > 0:
            change = data['current_price'] - data['previous_close']
            change_percent = (change / data['previous_close']) * 100
            data['change'] = change
            data['change_percent'] = change_percent
        else:
            data['change'] = 0
            data['change_percent'] = 0

        return data

    except Exception as e:
        print_error(f"獲取 {symbol} 數據時發生錯誤: {e}")
        return None


def format_markdown_table(holdings_data):
    """
    將持倉數據格式化為 Markdown 表格

    Args:
        holdings_data: 包含股票數據的列表

    Returns:
        str: Markdown 格式的表格
    """
    lines = []

    # 添加標題和日期
    today = datetime.now().strftime('%Y-%m-%d')
    lines.append(f"# 📊 持倉股票價格分析")
    lines.append(f"\n> 更新時間: {today}\n")
    lines.append("---\n")

    # 表格頭部
    lines.append("| 代碼 | 名稱 | 當前價格 | 漲跌 | 漲跌幅 | 開盤 | 最高 | 最低 | 成交量 | 市值 |")
    lines.append("|------|------|----------|------|--------|------|------|------|--------|------|")

    # 統計數據
    total_stocks = len(holdings_data)
    up_count = 0
    down_count = 0
    flat_count = 0

    # 表格內容
    for data in holdings_data:
        if data is None:
            continue

        # 格式化價格
        price = f"${data['current_price']:.2f}"

        # 格式化漲跌
        change = data['change']
        change_percent = data['change_percent']

        if change > 0:
            change_str = f"+${change:.2f}"
            percent_str = f"🟢 +{change_percent:.2f}%"
            up_count += 1
        elif change < 0:
            change_str = f"-${abs(change):.2f}"
            percent_str = f"🔴 {change_percent:.2f}%"
            down_count += 1
        else:
            change_str = "$0.00"
            percent_str = "⚪ 0.00%"
            flat_count += 1

        # 格式化其他數值
        open_val = f"${data['open']:.2f}"
        high_val = f"${data['high']:.2f}"
        low_val = f"${data['low']:.2f}"
        volume_val = f"{int(data['volume']):,}" if data['volume'] > 0 else "—"

        # 格式化市值
        if data['market_cap']:
            market_cap_b = data['market_cap'] / 1_000_000_000
            market_cap_str = f"${market_cap_b:.2f}B"
        else:
            market_cap_str = "—"

        # 限制名稱長度
        name = data['name'][:30] + '...' if len(data['name']) > 30 else data['name']

        line = f"| {data['symbol']} | {name} | {price} | {change_str} | {percent_str} | {open_val} | {high_val} | {low_val} | {volume_val} | {market_cap_str} |"
        lines.append(line)

    # 添加統計資訊
    lines.append("\n---\n")
    lines.append("## 📈 市場概況\n")
    lines.append(f"- **總股票數**: {total_stocks}")
    lines.append(f"- **上漲**: 🟢 {up_count} ({up_count/total_stocks*100:.1f}%)")
    lines.append(f"- **下跌**: 🔴 {down_count} ({down_count/total_stocks*100:.1f}%)")
    lines.append(f"- **持平**: ⚪ {flat_count} ({flat_count/total_stocks*100:.1f}%)")

    return '\n'.join(lines)


def main():
    parser = create_argument_parser(
        description='獲取持倉股票的當天價格資訊',
        epilog="""
使用範例:
  # 分析預設的 holdings 檔案
  python fetch_holdings_prices.py

  # 指定 holdings 檔案並輸出到檔案
  python fetch_holdings_prices.py -i portfolio/2025/holdings.md -o portfolio/2025/prices-today.md

  # 顯示詳細資訊
  python fetch_holdings_prices.py -v
        """
    )

    parser.add_argument(
        '-i', '--input',
        type=str,
        default='portfolio/2025/holdings.md',
        help='holdings.md 檔案路徑 (預設: portfolio/2025/holdings.md)'
    )

    parser.add_argument(
        '-o', '--output',
        type=str,
        help='輸出檔案路徑 (若未指定則輸出到螢幕)'
    )

    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='顯示詳細資訊'
    )

    args = parser.parse_args()

    # 轉換為絕對路徑
    project_root = get_project_root()

    holdings_file = args.input
    if not holdings_file.startswith('/'):
        holdings_file = str(project_root / holdings_file)

    if args.verbose:
        print_status(f"專案根目錄: {project_root}")
        print_status(f"Holdings 檔案: {holdings_file}")

    # 提取股票代碼
    symbols = extract_holdings_from_md(holdings_file)

    if not symbols:
        print_error("未找到任何股票代碼")
        safe_exit(False)

    if args.verbose:
        print_status(f"找到的股票: {', '.join(symbols)}")

    # 獲取每隻股票的價格
    print_status(f"\n正在獲取 {len(symbols)} 隻股票的價格資訊...\n")

    holdings_data = []
    for i, symbol in enumerate(symbols, 1):
        print_status(f"[{i}/{len(symbols)}] {symbol}...")
        data = fetch_stock_price(symbol, verbose=args.verbose)
        if data:
            holdings_data.append(data)
            print_status("  ✓")
        else:
            print_status("  ✗")

    if not holdings_data:
        print_error("無法獲取任何股票數據")
        safe_exit(False)

    # 產生 Markdown 表格
    markdown_output = format_markdown_table(holdings_data)

    # 輸出結果
    from pathlib import Path
    output_path = None
    if args.output:
        output_file = args.output
        if not output_file.startswith('/'):
            output_path = project_root / output_file
        else:
            output_path = Path(output_file)

    write_output(markdown_output, output_path, verbose=True)

    print_status(f"\n成功獲取 {len(holdings_data)}/{len(symbols)} 隻股票的價格資訊")


if __name__ == '__main__':
    main()
