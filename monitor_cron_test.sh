#!/bin/bash
# 監控測試 cron job 的執行

echo "=========================================="
echo "Cron Test Monitor"
echo "=========================================="
echo ""
echo "⏰ 當前時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📅 測試任務預定執行時間: 21:56"
echo "📄 測試日誌檔案: /tmp/mis_test.log"
echo ""
echo "等待 cron 執行中... (按 Ctrl+C 停止監控)"
echo ""

# 等待日誌檔案出現
while [ ! -f /tmp/mis_test.log ]; do
    echo -n "."
    sleep 5
done

echo ""
echo ""
echo "✅ Cron 任務開始執行!"
echo "=========================================="
echo ""

# 即時顯示日誌
tail -f /tmp/mis_test.log
