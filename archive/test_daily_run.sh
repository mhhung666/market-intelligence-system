#!/bin/bash
# 完整測試 daily workflow - 模擬 cron 環境

echo "=========================================="
echo "Testing FULL Daily Workflow"
echo "=========================================="
echo ""

# 設定 cron 環境變數
export PATH=/usr/local/bin:/usr/bin:/bin:/Users/mhhung/.local/bin
export HOME=/Users/mhhung
export SHELL=/bin/bash

cd /Users/mhhung/Development/MH/market-intelligence-system || exit 1

echo "📍 Working directory: $(pwd)"
echo "🔧 PATH: $PATH"
echo "🏠 HOME: $HOME"
echo ""

echo "🧪 Testing Claude CLI with simple prompt..."
echo "Hello, can you respond with OK?" | ~/.local/bin/claude 2>&1 | head -3
echo ""

echo "=========================================="
echo "Starting Make Daily (press Ctrl+C to stop)"
echo "=========================================="
echo ""

# 執行 make daily,顯示所有輸出
/usr/bin/make daily 2>&1
