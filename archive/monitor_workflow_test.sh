#!/bin/bash
# 監控完整工作流程測試

echo "=========================================="
echo "Complete Workflow Test Monitor"
echo "=========================================="
echo ""
echo "⏰ 當前時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📅 測試任務: $(crontab -l | grep '測試任務' | awk '{print $2":"$1}')"
echo "📄 測試日誌: /tmp/mis_workflow_test.log"
echo ""
echo "📋 工作流程包含:"
echo "  1. make daily (資料抓取 + 分析)"
echo "  2. make update-pages (更新 GitHub Pages)"
echo "  3. make commit-auto (自動 commit)"
echo "  4. make push (推送到 GitHub)"
echo ""
echo "等待 cron 執行... (按 Ctrl+C 停止)"
echo ""

# 等待日誌檔案
while [ ! -f /tmp/mis_workflow_test.log ]; do
    echo -n "."
    sleep 3
done

echo ""
echo ""
echo "✅ Cron 任務開始執行!"
echo "=========================================="
echo ""

# 即時顯示日誌
tail -f /tmp/mis_workflow_test.log
