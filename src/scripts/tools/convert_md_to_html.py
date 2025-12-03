#!/usr/bin/env python3
"""
Markdown → HTML converter tailored for the Market Intelligence System.

- 保留 markdown 中的 emoji、程式碼區塊、表格、巢狀清單、blockquote
- 自動產生頁面框架 (導航列、TOC、Back to Top 按鈕)
- 依照頁面類型自動高亮導航 (market/holdings)
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Tuple
from zoneinfo import ZoneInfo

try:
    from markdown import Markdown
except ImportError:  # pragma: no cover - runtime dependency check
    print(
        "❌ 需要安裝 markdown 套件才能轉換。請執行 `pip install markdown` 後再試一次。",
        file=sys.stderr,
    )
    sys.exit(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert a markdown report into the styled HTML used by docs/*.html",
    )
    parser.add_argument("input", type=Path, help="來源 markdown 檔案")
    parser.add_argument("output", type=Path, help="輸出 HTML 檔案路徑")
    parser.add_argument(
        "page_type",
        nargs="?",
        default="market",
        choices=["market", "holdings", "home"],
        help="用於設定導航高亮, 預設 market",
    )
    return parser.parse_args()


def read_file(filepath: Path) -> str:
    return filepath.read_text(encoding="utf-8")


def slugify_heading(value: str, separator: str = "-") -> str:
    """為中文/英文混合標題建立 slug, 供 markdown toc 使用。"""
    cleaned = re.sub(r"[^\w\s\-\u4e00-\u9fff]", "", value).strip().lower()
    cleaned = re.sub(r"\s+", separator, cleaned)
    return cleaned.strip(separator)


def extract_title_and_date(content: str, source_path: Path) -> Tuple[str, str]:
    """從 markdown 抓 title 與日期 (優先抓正文, 再退回檔名)."""
    title_match = re.search(r"^#\s+(.+?)$", content, re.MULTILINE)
    title = title_match.group(1).strip() if title_match else "Analysis Report"

    date_match = re.search(r"(\d{4}-\d{2}-\d{2})", content)
    if date_match:
        date = date_match.group(1)
    else:
        file_match = re.search(r"(\d{4}-\d{2}-\d{2})", source_path.name)
        date = file_match.group(1) if file_match else localized_now().strftime("%Y-%m-%d")

    return title, date


def localized_now() -> datetime:
    """Return current time with a stable tz (default Asia/Taipei, overridable via env)."""
    tz_name = os.environ.get("MIS_REPORT_TZ") or os.environ.get("TZ") or "Asia/Taipei"
    try:
        return datetime.now(ZoneInfo(tz_name))
    except Exception:
        return datetime.now()


def post_process_html(html: str) -> str:
    """附加一些 markdown 無法處理的細節樣式。"""

    def wrap_tables(match: re.Match[str]) -> str:
        return f'<div class="table-wrapper">{match.group(0)}</div>'

    html = re.sub(r"<table>.*?</table>", wrap_tables, html, flags=re.DOTALL)

    def wrap_percentages(match: re.Match[str]) -> str:
        value = match.group(1)
        css_class = "status-positive" if value.startswith("+") else "status-negative"
        return f'<span class="{css_class}">{value}</span>'

    html = re.sub(r"(?<![\w\-])([+-]\d+(?:\.\d+)?%)", wrap_percentages, html)
    return html


def markdown_to_html(md_content: str) -> str:
    """使用 python-markdown 轉換, 支援表格/程式碼/巢狀清單/blockquote。"""
    md = Markdown(
        extensions=[
            "fenced_code",
            "tables",
            "sane_lists",
            "toc",
            "smarty",
            "attr_list",
            "md_in_html",
        ],
        extension_configs={"toc": {"slugify": slugify_heading, "permalink": False}},
        output_format="html5",
    )
    html = md.convert(md_content)
    return post_process_html(html)


def create_html_page(title: str, date: str, content_html: str, page_type: str) -> str:
    """建立完整頁面 HTML。"""
    page_names = {"market": "Market Analysis", "holdings": "Holdings Analysis", "home": "Home"}
    current_page = page_names.get(page_type, "Analysis")
    generated_at_dt = localized_now()
    generated_at = generated_at_dt.strftime("%Y-%m-%d %H:%M %Z%z").strip()

    def active_class(target: str) -> str:
        return ' class="nav-link active"' if target == page_type else ' class="nav-link"'

    return f"""<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} | Market Intelligence System</title>
    <meta name="description" content="Markdown 報告自動轉換的 {current_page}">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" integrity="sha512-bx1RjgqPsuwZuC9Anb3iqN+EgZScFTG49YB35G5FbKFtE+08sZzIcGcav6pDgZuuWpbOEtxzKqrD+9Y+YrbMtw==" crossorigin="anonymous" referrerpolicy="no-referrer">
    <link rel="stylesheet" href="styles.css">
</head>
<body class="page-{page_type} theme-dark">
    <div class="page-shell">
        <nav class="top-nav">
            <span class="nav-brand">📊 Market Intelligence System</span>
            <div class="nav-links">
                <a href="index.html"{active_class("home")}>Home</a>
                <a href="market.html"{active_class("market")}>Market Analysis</a>
                <a href="holdings.html"{active_class("holdings")}>Holdings Analysis</a>
            </div>
            <div class="nav-actions">
                <button class="theme-toggle" id="themeToggle" aria-label="切換深/淺色模式">
                    <i class="fa-solid fa-moon" id="themeIcon" aria-hidden="true"></i>
                    <span id="themeLabel">夜間模式</span>
                </button>
            </div>
        </nav>

        <header class="report-hero">
            <div>
                <p class="eyebrow">{current_page}</p>
                <h1>{title}</h1>
                <p class="hero-note">自動轉換 Markdown → HTML, 完整保留表格、程式碼、emoji 與列表格式。</p>
                <div class="hero-meta">
                    <span class="pill">報告日期 {date}</span>
                    <span class="pill pill-ghost">生成時間 {generated_at}</span>
                    <span class="pill pill-outline">{current_page}</span>
                </div>
            </div>
        </header>

        <main class="page-layout no-toc">
            <section class="content" id="mainContent">
{content_html}
            </section>
        </main>

        <button class="back-to-top" id="backToTop" aria-label="回到頂部">↑</button>

        <footer>
            <p>Powered by Market Intelligence System · Markdown Pipeline</p>
        </footer>
    </div>

    <script>
        // 主題切換
        function getPreferredTheme() {{
            const stored = localStorage.getItem('mis-theme');
            if (stored === 'light' || stored === 'dark') return stored;
            return window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
        }}

        function applyTheme(theme) {{
            const body = document.body;
            body.classList.toggle('theme-light', theme === 'light');
            body.classList.toggle('theme-dark', theme === 'dark');
            localStorage.setItem('mis-theme', theme);

            const toggle = document.getElementById('themeToggle');
            const icon = document.getElementById('themeIcon');
            const label = document.getElementById('themeLabel');
            if (toggle) {{
                if (icon) {{
                    icon.className = theme === 'light' ? 'fa-solid fa-moon' : 'fa-solid fa-sun';
                }}
                if (label) {{
                    label.textContent = theme === 'light' ? '夜間模式' : '白天模式';
                }}
                toggle.setAttribute('aria-label', `切換為${{theme === 'light' ? '夜間' : '日間'}}模式`);
            }}
        }}

        // Back to top
        function handleBackToTop() {{
            const btn = document.getElementById('backToTop');
            if (window.pageYOffset > 320) {{
                btn.classList.add('visible');
            }} else {{
                btn.classList.remove('visible');
            }}
        }}

        document.addEventListener('DOMContentLoaded', () => {{
            applyTheme(getPreferredTheme());
            handleBackToTop();

            let scrollTimeout;
            window.addEventListener('scroll', () => {{
                clearTimeout(scrollTimeout);
                scrollTimeout = setTimeout(() => {{
                    handleBackToTop();
                }}, 60);
            }});

            document.getElementById('backToTop').addEventListener('click', () => {{
                window.scrollTo({{ top: 0, behavior: 'smooth' }});
            }});

            const themeToggle = document.getElementById('themeToggle');
            if (themeToggle) {{
                themeToggle.addEventListener('click', () => {{
                    const nextTheme = document.body.classList.contains('theme-light') ? 'dark' : 'light';
                    applyTheme(nextTheme);
                }});
            }}
        }});
    </script>
</body>
</html>
"""


def main() -> None:
    args = parse_args()
    input_file: Path = args.input
    output_file: Path = args.output
    page_type: str = args.page_type

    if not input_file.exists():
        print(f"❌ 找不到來源檔案: {input_file}", file=sys.stderr)
        sys.exit(1)

    print(f"Converting {input_file} → {output_file} ({page_type})")

    md_content = read_file(input_file)
    title, date = extract_title_and_date(md_content, input_file)
    content_html = markdown_to_html(md_content)
    html_page = create_html_page(title, date, content_html, page_type)

    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(html_page, encoding="utf-8")

    print(f"✅ Conversion complete: {output_file}")
    print(f"   Title: {title}")
    print(f"   Date: {date}")
    print(f"   Type: {page_type}")


if __name__ == "__main__":
    main()
