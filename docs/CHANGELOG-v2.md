# Changelog - 雙報告系統 v2.0

## [v2.0.0] - 2025-12-02

### 🎉 重大更新：雙報告系統

系統現在生成**兩份獨立的專業分析報告**，關注點分離更清晰！

### ✨ 新增功能

#### 1. 雙報告架構

**之前 (v1.0)**:
- 單一報告 `market-analysis-{date}.md`
- 市場分析和持倉分析混在一起
- 報告過長，重點不清晰

**現在 (v2.0)**:
- 報告 1: `market-analysis-{date}.md` - 專注全球市場趨勢
- 報告 2: `holdings-analysis-{date}.md` - 專注投資組合表現
- 關注點分離，分析更精準

#### 2. 市場分析報告 (新)

專注於全球市場和新聞：

- 📊 執行摘要（市場概況、關鍵數據、情緒評估）
- 🌍 全球市場深度分析（美國、亞洲、歐洲）
- 📰 重要新聞解讀（按產業分類）
- 🏭 產業輪動分析（資金流向）
- ⚠️ 風險與機會（VIX 分析）
- 🔮 後市展望（情境分析、關鍵事件）
- 💡 投資策略建議（短期/中期觀點）

#### 3. 持倉分析報告 (新)

專注於投資組合管理：

- 💰 資產配置分析（現金 32.1% 是否合理？）
- 🎯 選擇權部位分析（12/05、12/19 到期風險管理）
- 📈 持倉表現分析（基於成本價 $50.39、倉位 16.8%、損益 -15.6%）
- ⚖️ 倉位結構分析（是否過度集中？U+INTC 29.4%）
- 🎯 倉位調整建議（具體價位、股數、資金需求）
  - 例：GOOGL 建議加碼至 15%，價位 $270 以下，100-150 股
- ⚠️ 風險提示（選擇權執行風險、倉位過重）
- ✅ 行動清單（立即執行、本週執行、持續監控）
- 📊 績效追蹤（月度報酬率 vs S&P 500）

#### 4. holdings.yaml 增強

新增投資組合概況區塊：

```yaml
portfolio_summary:
  total_assets: $257,723.52      # 總資產淨值
  stock_value: $175,200.30       # 股票市值
  cash_balance: $82,785.38       # 現金餘額
  cash_percentage: 32.1%         # 現金佔比
  unrealized_pnl: -$10,903       # 未實現損益
  total_return: -5.8%            # 總報酬率
  buying_power: $778,939.48      # 購買力
  last_updated: "2025-11-29"
```

完整的持股資訊（包含成本、股數、選擇權部位）。

### 🔧 改進

1. **更精準的分析**
   - 市場分析不再被持倉細節干擾
   - 持倉分析可以更深入地評估每檔股票

2. **更好的可操作性**
   - 持倉報告提供具體的買賣建議（價位、股數）
   - 選擇權到期提醒和處理建議
   - 明確的行動清單

3. **更完整的數據支持**
   - 讀取 holdings.yaml（持倉配置）
   - 讀取 holdings.md（完整投資組合資訊）
   - 考慮成本價、現金比例、選擇權約束

### 📝 使用方式

```bash
# 執行分析（生成兩份報告）
make analyze-daily

# 或完整流程
make daily

# 查看報告
cat analysis/market-analysis-$(date +%Y-%m-%d).md
cat analysis/holdings-analysis-$(date +%Y-%m-%d).md
```

### 🗑️ 移除

- 舊版單一報告腳本（已備份並移除）
- `run_daily_analysis_claude_cli_old.sh` (已刪除)
- `run_daily_analysis_claude_cli.sh.backup` (已刪除)

### 📚 文檔更新

- ✅ README.md - 反映雙報告系統
- ✅ utils/README.md - 詳細說明兩份報告的內容
- ✅ holdings.yaml - 加入 portfolio_summary 區塊

### 💡 設計理念

1. **關注點分離**
   - 市場分析專注於「市場發生了什麼」
   - 持倉分析專注於「我應該怎麼做」

2. **基於數據的建議**
   - 持倉分析考慮成本價（不盲目追高）
   - 考慮選擇權約束（避免違約）
   - 考慮現金比例（判斷加碼空間）

3. **可執行性**
   - 不僅分析問題，還提供解決方案
   - 具體的買賣建議（價位、股數、資金）
   - 清晰的行動清單和時間框架

### 🎯 下一步計劃

- [ ] 支援歷史報告比較（本週 vs 上週）
- [ ] 支援更多資產類別（債券、加密貨幣）
- [ ] 自動生成圖表（倉位分佈、績效走勢）
- [ ] Telegram/Discord 通知整合

---

## 升級指南

### 從 v1.0 升級到 v2.0

1. **更新 holdings.yaml**
   ```bash
   # 在 holdings.yaml 開頭加入 portfolio_summary 區塊
   # 參考: config/holdings.yaml
   ```

2. **重新執行分析**
   ```bash
   make analyze-daily
   ```

3. **檢查輸出**
   ```bash
   ls -lh analysis/
   # 應該看到兩個檔案:
   # - market-analysis-YYYY-MM-DD.md
   # - holdings-analysis-YYYY-MM-DD.md
   ```

### 相容性

- ✅ 向後相容：舊的資料檔案格式仍然支援
- ✅ 配置檔案：holdings.yaml 新增欄位不影響舊功能
- ✅ Make 命令：`make analyze-daily` 使用方式不變

---

**版本**: v2.0.0
**發布日期**: 2025-12-02
**作者**: Market Intelligence System Team
