#!/usr/bin/env python3
"""
Convert markdown analysis reports to HTML for GitHub Pages.

This script reads markdown analysis files and converts them to beautiful
HTML pages with TOC, dark theme, and responsive design.
"""

import sys
import re
from pathlib import Path
from datetime import datetime


def read_file(filepath: Path) -> str:
    """Read file content."""
    return filepath.read_text(encoding='utf-8')


def extract_title_and_date(content: str) -> tuple[str, str]:
    """Extract title and date from markdown content."""
    title_match = re.search(r'^#\s+(.+?)$', content, re.MULTILINE)
    title = title_match.group(1) if title_match else "Analysis Report"

    date_match = re.search(r'(\d{4}-\d{2}-\d{2})', content)
    date = date_match.group(1) if date_match else datetime.now().strftime('%Y-%m-%d')

    return title, date


def markdown_to_html(md_content: str) -> str:
    """Convert markdown content to HTML."""
    html = md_content

    # Convert headers
    html = re.sub(r'^#{6}\s+(.+?)$', r'<h6>\1</h6>', html, flags=re.MULTILINE)
    html = re.sub(r'^#{5}\s+(.+?)$', r'<h5>\1</h5>', html, flags=re.MULTILINE)
    html = re.sub(r'^#{4}\s+(.+?)$', r'<h4>\1</h4>', html, flags=re.MULTILINE)
    html = re.sub(r'^#{3}\s+(.+?)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
    html = re.sub(r'^#{2}\s+(.+?)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
    html = re.sub(r'^#\s+(.+?)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)

    # Convert horizontal rules
    html = re.sub(r'^---+$', '<hr>', html, flags=re.MULTILINE)

    # Convert blockquotes
    html = re.sub(r'^>\s+(.+?)$', r'<blockquote><p>\1</p></blockquote>', html, flags=re.MULTILINE)

    # Convert tables
    html = convert_tables(html)

    # Convert code blocks
    html = convert_code_blocks(html)

    # Convert lists
    html = convert_lists(html)

    # Convert inline formatting
    html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
    html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
    html = re.sub(r'`(.+?)`', r'<code>\1</code>', html)

    # Convert links
    html = re.sub(r'\[(.+?)\]\((.+?)\)', r'<a href="\2">\1</a>', html)

    # Convert paragraphs
    html = convert_paragraphs(html)

    # Add status classes for +/- percentages
    html = re.sub(r'>([+-]\d+\.?\d*%)<', lambda m: f' class="status-{"positive" if m.group(1).startswith("+") else "negative"}">\1<', html)

    return html


def convert_tables(html: str) -> str:
    """Convert markdown tables to HTML."""
    lines = html.split('\n')
    result = []
    in_table = False
    table_lines = []

    for line in lines:
        if '|' in line and line.strip().startswith('|'):
            if not in_table:
                in_table = True
                table_lines = []
            table_lines.append(line)
        else:
            if in_table and table_lines:
                # Process table
                result.append(process_table(table_lines))
                table_lines = []
                in_table = False
            result.append(line)

    if in_table and table_lines:
        result.append(process_table(table_lines))

    return '\n'.join(result)


def process_table(lines: list[str]) -> str:
    """Process a markdown table to HTML."""
    if len(lines) < 2:
        return '\n'.join(lines)

    # Parse header
    header = [cell.strip() for cell in lines[0].split('|')[1:-1]]

    # Skip separator line
    data_lines = lines[2:]

    html = '<table>\n<thead>\n<tr>\n'
    for cell in header:
        html += f'<th>{cell}</th>\n'
    html += '</tr>\n</thead>\n<tbody>\n'

    for line in data_lines:
        cells = [cell.strip() for cell in line.split('|')[1:-1]]
        html += '<tr>\n'
        for cell in cells:
            html += f'<td>{cell}</td>\n'
        html += '</tr>\n'

    html += '</tbody>\n</table>\n'
    return html


def convert_code_blocks(html: str) -> str:
    """Convert code blocks to HTML."""
    html = re.sub(r'```(\w+)?\n(.+?)```', r'<pre><code>\2</code></pre>', html, flags=re.DOTALL)
    return html


def convert_lists(html: str) -> str:
    """Convert markdown lists to HTML."""
    lines = html.split('\n')
    result = []
    in_ul = False
    in_ol = False

    for line in lines:
        ul_match = re.match(r'^(\s*)[-*]\s+(.+)$', line)
        ol_match = re.match(r'^(\s*)\d+\.\s+(.+)$', line)

        if ul_match:
            if not in_ul:
                result.append('<ul>')
                in_ul = True
            indent = len(ul_match.group(1))
            content = ul_match.group(2)
            result.append(f'<li>{content}</li>')
        elif ol_match:
            if not in_ol:
                result.append('<ol>')
                in_ol = True
            content = ol_match.group(2)
            result.append(f'<li>{content}</li>')
        else:
            if in_ul:
                result.append('</ul>')
                in_ul = False
            if in_ol:
                result.append('</ol>')
                in_ol = False
            result.append(line)

    if in_ul:
        result.append('</ul>')
    if in_ol:
        result.append('</ol>')

    return '\n'.join(result)


def convert_paragraphs(html: str) -> str:
    """Wrap text in paragraph tags."""
    lines = html.split('\n')
    result = []
    in_block = False

    for line in lines:
        stripped = line.strip()

        # Skip if already in HTML tag
        if stripped.startswith('<'):
            if in_block:
                result.append('</p>')
                in_block = False
            result.append(line)
        elif stripped:
            if not in_block:
                result.append('<p>')
                in_block = True
            result.append(line)
        else:
            if in_block:
                result.append('</p>')
                in_block = False
            result.append(line)

    if in_block:
        result.append('</p>')

    return '\n'.join(result)


def create_html_page(title: str, date: str, content_html: str, page_type: str) -> str:
    """Create complete HTML page."""
    page_names = {
        'market': 'Market Analysis',
        'holdings': 'Holdings Analysis'
    }

    current_page = page_names.get(page_type, 'Analysis')

    html = f'''<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} | Market Intelligence System</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <!-- Navigation -->
        <nav>
            <span class="nav-home">📊 Market Intelligence System</span>
            <div>
                <a href="index.html">Home</a>
                <a href="market.html"{' style="background: var(--primary-color);"' if page_type == 'market' else ''}>Market Analysis</a>
                <a href="holdings.html"{' style="background: var(--primary-color);"' if page_type == 'holdings' else ''}>Holdings Analysis</a>
            </div>
        </nav>

        <!-- Header -->
        <header>
            <h1>{title}</h1>
            <p class="subtitle">{date}</p>
            <p class="update-time">報告生成時間: {date}</p>
        </header>

        <!-- TOC Toggle Button (Mobile) -->
        <button class="toc-mobile-toggle" id="tocMobileToggle">📑 目錄</button>

        <!-- Table of Contents -->
        <div class="toc-wrapper">
            <aside class="toc-sidebar" id="tocSidebar">
                <div class="toc-header">
                    <span class="toc-title">📑 目錄</span>
                    <button class="toc-toggle" id="tocToggle">×</button>
                </div>
                <nav class="toc-list" id="tocList">
                    <!-- TOC will be generated by JavaScript -->
                </nav>
            </aside>
        </div>

        <!-- Main Content -->
        <div class="content content-with-toc" id="mainContent">
{content_html}
        </div>

        <!-- Back to Top Button -->
        <button class="back-to-top" id="backToTop">↑</button>

        <!-- Footer -->
        <footer>
            <p>Powered by Market Intelligence System | Claude Sonnet 4.5 | Yahoo Finance</p>
        </footer>
    </div>

    <script>
        // Generate Table of Contents
        function generateTOC() {{
            const content = document.getElementById('mainContent');
            const tocList = document.getElementById('tocList');
            const headings = content.querySelectorAll('h2, h3');

            let tocHTML = '';
            headings.forEach((heading, index) => {{
                const level = heading.tagName.toLowerCase();
                const text = heading.textContent;
                const id = `section-${{index}}`;
                heading.id = id;

                tocHTML += `<li class="toc-item">
                    <a href="#${{id}}" class="toc-link level-${{level.charAt(1)}}">${{text}}</a>
                </li>`;
            }});

            tocList.innerHTML = tocHTML;
        }}

        // Highlight active section in TOC
        function highlightActiveTOC() {{
            const headings = document.querySelectorAll('#mainContent h2, #mainContent h3');
            const tocLinks = document.querySelectorAll('.toc-link');

            let currentId = null;
            const offset = 150;

            headings.forEach(heading => {{
                const rect = heading.getBoundingClientRect();
                if (rect.top <= offset && rect.bottom >= 0) {{
                    currentId = heading.id;
                }}
            }});

            tocLinks.forEach(link => {{
                if (link.getAttribute('href') === `#${{currentId}}`) {{
                    link.classList.add('active');
                }} else {{
                    link.classList.remove('active');
                }}
            }});
        }}

        // Toggle TOC sidebar
        function toggleTOC() {{
            const sidebar = document.getElementById('tocSidebar');
            const toggle = document.getElementById('tocMobileToggle');
            sidebar.classList.toggle('hidden');
            toggle.classList.toggle('active');
        }}

        // Back to top button
        function handleBackToTop() {{
            const btn = document.getElementById('backToTop');
            if (window.pageYOffset > 300) {{
                btn.classList.add('visible');
            }} else {{
                btn.classList.remove('visible');
            }}
        }}

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {{
            generateTOC();

            // Scroll event with debounce
            let scrollTimeout;
            window.addEventListener('scroll', function() {{
                clearTimeout(scrollTimeout);
                scrollTimeout = setTimeout(() => {{
                    highlightActiveTOC();
                    handleBackToTop();
                }}, 50);
            }});

            // TOC toggle
            document.getElementById('tocToggle').addEventListener('click', toggleTOC);
            document.getElementById('tocMobileToggle').addEventListener('click', toggleTOC);

            // Close TOC when clicking a link on mobile
            document.querySelectorAll('.toc-link').forEach(link => {{
                link.addEventListener('click', function() {{
                    if (window.innerWidth <= 768) {{
                        toggleTOC();
                    }}
                }});
            }});

            // Back to top
            document.getElementById('backToTop').addEventListener('click', function() {{
                window.scrollTo({{ top: 0, behavior: 'smooth' }});
            }});

            // Initial highlight
            highlightActiveTOC();
        }});

        // Handle resize
        window.addEventListener('resize', function() {{
            const sidebar = document.getElementById('tocSidebar');
            const toggle = document.getElementById('tocMobileToggle');
            if (window.innerWidth > 768) {{
                sidebar.classList.remove('hidden');
                toggle.classList.remove('active');
            }} else {{
                sidebar.classList.add('hidden');
            }}
        }});
    </script>
</body>
</html>'''

    return html


def main():
    """Main conversion function."""
    if len(sys.argv) < 3:
        print("Usage: python convert_md_to_html.py <input.md> <output.html> [market|holdings]")
        sys.exit(1)

    input_file = Path(sys.argv[1])
    output_file = Path(sys.argv[2])
    page_type = sys.argv[3] if len(sys.argv) > 3 else 'market'

    if not input_file.exists():
        print(f"Error: Input file '{input_file}' not found")
        sys.exit(1)

    print(f"Converting {input_file} to {output_file}...")

    # Read markdown
    md_content = read_file(input_file)

    # Extract metadata
    title, date = extract_title_and_date(md_content)

    # Convert to HTML
    content_html = markdown_to_html(md_content)

    # Create full page
    html_page = create_html_page(title, date, content_html, page_type)

    # Write output
    output_file.parent.mkdir(parents=True, exist_ok=True)
    output_file.write_text(html_page, encoding='utf-8')

    print(f"✅ Conversion complete: {output_file}")
    print(f"   Title: {title}")
    print(f"   Date: {date}")
    print(f"   Type: {page_type}")


if __name__ == '__main__':
    main()
