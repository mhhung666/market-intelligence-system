#!/bin/bash
# 測試腳本 - 驗證 cron 任務能否正常執行

echo "=========================================="
echo "Market Intelligence System - Cron Test"
echo "=========================================="
echo ""
echo "當前時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "工作目錄: $(pwd)"
echo ""

# 檢查 crontab 設定
echo "📋 Current crontab:"
echo "----------------------------------------"
crontab -l
echo ""

# 檢查 cron daemon
echo "🔍 Cron daemon status:"
echo "----------------------------------------"
ps aux | grep -i cron | grep -v grep
echo ""

# 檢查環境
echo "🔧 Environment check:"
echo "----------------------------------------"
echo "Make: $(which make)"
echo "Python3: $(which python3)"
echo "Claude: $(which claude)"
echo "Project dir: /Users/mhhung/Development/MH/market-intelligence-system"
echo "Project exists: $([ -d /Users/mhhung/Development/MH/market-intelligence-system ] && echo 'Yes' || echo 'No')"
echo ""

# 檢查 Claude CLI
echo "🤖 Claude CLI check:"
echo "----------------------------------------"
if [ -x ~/.local/bin/claude ]; then
    echo "✅ Claude CLI found: ~/.local/bin/claude"
    ~/.local/bin/claude --version
    echo ""
    echo "Testing Claude CLI:"
    echo "test" | ~/.local/bin/claude 2>&1 | head -3
    echo "(Exit code: $?)"
else
    echo "❌ Claude CLI not found or not executable"
fi
echo ""

# 檢查 log 檔案
echo "📄 Log file status:"
echo "----------------------------------------"
if [ -f /tmp/mis.log ]; then
    echo "Log file: /tmp/mis.log ($(wc -l < /tmp/mis.log) lines)"
    echo "Last modified: $(stat -f "%Sm" /tmp/mis.log)"
    echo ""
    echo "Last 20 lines:"
    tail -20 /tmp/mis.log
else
    echo "Log file not created yet (will be created on first cron run)"
fi
echo ""

# 模擬 cron 環境測試
echo "🧪 Testing in simulated cron environment:"
echo "----------------------------------------"
(
    export PATH=/usr/local/bin:/usr/bin:/bin:/Users/mhhung/.local/bin
    export HOME=/Users/mhhung
    cd /Users/mhhung/Development/MH/market-intelligence-system &&
    make help | head -5
) 2>&1 | head -10
echo ""

echo "✅ Test completed!"
echo ""
echo "📌 Next cron runs:"
echo "  - Morning:  每天 08:00"
echo "  - Evening:  每天 21:00"
echo ""
echo "📊 To monitor cron execution:"
echo "  tail -f /tmp/mis.log"
echo ""
echo "🔄 To test manually (simulating cron environment):"
echo "  cd /Users/mhhung/Development/MH/market-intelligence-system && /usr/bin/make daily"
