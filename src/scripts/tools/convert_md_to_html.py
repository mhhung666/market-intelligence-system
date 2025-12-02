#!/usr/bin/env python3
"""
Markdown → HTML converter tailored for the Market Intelligence System.

- 保留 markdown 中的 emoji、程式碼區塊、表格、巢狀清單、blockquote
- 自動產生頁面框架 (導航列、TOC、Back to Top 按鈕)
- 依照頁面類型自動高亮導航 (market/holdings)
"""

from __future__ import annotations

import argparse
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Tuple

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
        date = file_match.group(1) if file_match else datetime.now().strftime("%Y-%m-%d")

    return title, date


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
    generated_at = datetime.now().strftime("%Y-%m-%d %H:%M")

    def active_class(target: str) -> str:
        return ' class="nav-link active"' if target == page_type else ' class="nav-link"'

    return f"""<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} | Market Intelligence System</title>
    <meta name="description" content="Markdown 報告自動轉換的 {current_page}">
    <link rel="stylesheet" href="styles.css">
</head>
<body class="page-{page_type}">
    <div class="page-shell">
        <nav class="top-nav">
            <span class="nav-brand">📊 Market Intelligence System</span>
            <div class="nav-links">
                <a href="index.html"{active_class("home")}>Home</a>
                <a href="market.html"{active_class("market")}>Market Analysis</a>
                <a href="holdings.html"{active_class("holdings")}>Holdings Analysis</a>
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

        <main class="page-layout">
            <button class="toc-mobile-toggle" id="tocMobileToggle" aria-label="開啟目錄">📑 目錄</button>

            <div class="toc-wrapper">
                <aside class="toc-sidebar" id="tocSidebar">
                    <div class="toc-header">
                        <span class="toc-title">📑 目錄</span>
                        <button class="toc-toggle" id="tocToggle" aria-label="收合目錄">×</button>
                    </div>
                    <nav class="toc-list" id="tocList"></nav>
                </aside>
            </div>

            <section class="content content-with-toc" id="mainContent">
{content_html}
            </section>
        </main>

        <button class="back-to-top" id="backToTop" aria-label="回到頂部">↑</button>

        <footer>
            <p>Powered by Market Intelligence System · Markdown Pipeline</p>
        </footer>
    </div>

    <script>
        // 產生 TOC
        function generateTOC() {{
            const content = document.getElementById('mainContent');
            const tocList = document.getElementById('tocList');
            const headings = content.querySelectorAll('h2, h3, h4');

            let tocHTML = '';
            headings.forEach((heading, index) => {{
                const level = heading.tagName.toLowerCase();
                const id = `section-${{index}}`;
                heading.id = id;
                tocHTML += `<li class="toc-item level-${{level.charAt(1)}}">
                    <a href="#${{id}}" class="toc-link">${{heading.textContent}}</a>
                </li>`;
            }});

            tocList.innerHTML = tocHTML;
        }}

        // TOC active 狀態
        function highlightActiveTOC() {{
            const headings = document.querySelectorAll('#mainContent h2, #mainContent h3, #mainContent h4');
            const tocLinks = document.querySelectorAll('.toc-link');
            let currentId = null;
            const offset = 160;

            headings.forEach((heading) => {{
                const rect = heading.getBoundingClientRect();
                if (rect.top <= offset && rect.bottom >= 0) {{
                    currentId = heading.id;
                }}
            }});

            tocLinks.forEach((link) => {{
                if (link.getAttribute('href') === `#${{currentId}}`) {{
                    link.classList.add('active');
                }} else {{
                    link.classList.remove('active');
                }}
            }});
        }}

        // TOC 顯示切換
        function toggleTOC() {{
            const sidebar = document.getElementById('tocSidebar');
            const toggle = document.getElementById('tocMobileToggle');
            sidebar.classList.toggle('hidden');
            toggle.classList.toggle('active');
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
            generateTOC();
            highlightActiveTOC();
            handleBackToTop();

            let scrollTimeout;
            window.addEventListener('scroll', () => {{
                clearTimeout(scrollTimeout);
                scrollTimeout = setTimeout(() => {{
                    highlightActiveTOC();
                    handleBackToTop();
                }}, 60);
            }});

            document.getElementById('tocToggle').addEventListener('click', toggleTOC);
            document.getElementById('tocMobileToggle').addEventListener('click', toggleTOC);

            document.getElementById('backToTop').addEventListener('click', () => {{
                window.scrollTo({{ top: 0, behavior: 'smooth' }});
            }});

            window.addEventListener('resize', () => {{
                const sidebar = document.getElementById('tocSidebar');
                const toggle = document.getElementById('tocMobileToggle');
                if (window.innerWidth > 900) {{
                    sidebar.classList.remove('hidden');
                    toggle.classList.remove('active');
                }} else {{
                    sidebar.classList.add('hidden');
                }}
            }});
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
