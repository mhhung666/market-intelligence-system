#!/bin/bash
# 監控 Claude CLI 測試執行

echo "=========================================="
echo "Claude CLI Cron Test Monitor"
echo "=========================================="
echo ""
echo "⏰ 當前時間: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📅 測試任務預定執行: $(crontab -l | grep '測試任務' | awk '{print $2":"$1}')"
echo "📄 測試日誌: /tmp/mis_claude_test.log"
echo ""
echo "✅ API Token 已設定在 crontab 環境變數中"
echo ""
echo "等待 cron 執行... (按 Ctrl+C 停止)"
echo ""

# 倒數計時
echo -n "距離執行還有約: "
current_min=$(date +%M)
current_sec=$(date +%S)
target_min=5
if [ $current_min -ge $target_min ]; then
    echo "已過執行時間,檢查是否有日誌"
else
    remain=$((($target_min - $current_min) * 60 - $current_sec))
    echo "${remain} 秒"
fi
echo ""

# 等待日誌檔案
while [ ! -f /tmp/mis_claude_test.log ]; do
    echo -n "."
    sleep 3
done

echo ""
echo ""
echo "✅ Cron 任務開始執行!"
echo "=========================================="
echo ""

# 即時顯示日誌
tail -f /tmp/mis_claude_test.log
