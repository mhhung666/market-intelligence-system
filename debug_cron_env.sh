#!/bin/bash
# Debug script to check cron environment

echo "=========================================="
echo "Cron Environment Debug"
echo "=========================================="
echo "Date: $(date)"
echo "User: $(whoami)"
echo "Shell: $SHELL"
echo "PATH: $PATH"
echo "HOME: $HOME"
echo ""
echo "Claude CLI check:"
echo "  which claude: $(which claude 2>&1)"
echo "  ~/.local/bin/claude: $(ls -la ~/.local/bin/claude 2>&1 | head -1)"
echo ""
echo "Testing Claude CLI:"
echo "test" | ~/.local/bin/claude 2>&1 | head -3
echo ""
echo "Exit code: $?"
