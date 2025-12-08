# Notion 風格主題更新說明

## 更新日期
2025-12-08

## 更新概述
成功將 Market Intelligence System 的網頁主題改造為 Notion 風格,提供更簡潔、優雅的閱讀體驗。

## 主要變更

### 1. 配色方案 (Color Scheme)

#### 深色主題 (Dark Theme)
- **背景色**: `#191919` - 接近 Notion 的深色背景
- **面板色**: `#252525` - 內容區塊背景
- **文字色**: `#ffffff` - 主要文字
- **次要文字**: `#9b9b9b` - 輔助文字
- **強調色**: `#2eaadc` - Notion 藍色
- **邊框色**: `#37352f` - 深色邊框

#### 淺色主題 (Light Theme)
- **背景色**: `#ffffff` - 純白背景
- **面板色**: `#f7f6f3` - 米白色面板
- **文字色**: `#37352f` - 深灰文字
- **次要文字**: `#787774` - 灰色輔助文字
- **強調色**: `#0b6e99` - 深藍色
- **邊框色**: `#e9e9e7` - 淺灰邊框

### 2. 設計元素更新

#### 字體 (Typography)
- **無襯線字體**: `-apple-system, BlinkMacSystemFont, "Segoe UI"...`
- **等寬字體**: `"SFMono-Regular", Consolas, "Liberation Mono"...`
- 採用系統原生字體,確保跨平台一致性

#### 圓角 (Border Radius)
- **大**: `6px` (取代原本的 18px)
- **中**: `4px` (取代原本的 12px)
- **小**: `3px` (取代原本的 8px)
- Notion 風格使用較小的圓角,更加簡潔

#### 陰影 (Shadows)
- **小**: `0 1px 3px rgba(0, 0, 0, 0.12)`
- **中**: `0 4px 12px rgba(0, 0, 0, 0.15)`
- **大**: `0 8px 24px rgba(0, 0, 0, 0.2)`
- 使用更微妙的陰影效果

### 3. 組件更新

#### 導航列 (Navigation)
- 移除華麗的漸變背景
- 使用純色背景 + 毛玻璃效果
- 簡化按鈕樣式,hover 時顯示背景色
- 主題切換按鈕使用 emoji (☀️/🌙) 取代 Font Awesome 圖標

#### 頁面標題 (Header)
- 移除浮誇的漸變背景和裝飾
- 採用簡潔的文字排版
- Pills 使用細邊框和半透明背景

#### 內容區域 (Content)
- 移除邊框和陰影
- 使用純背景色,融入頁面
- 改善文字行高和間距
- 代碼塊使用更簡潔的樣式

#### 表格 (Tables)
- 簡化邊框樣式
- 表頭使用柔和的背景色
- hover 效果更加微妙

#### 按鈕和卡片 (Buttons & Cards)
- 移除漸變背景
- 使用純色 + 邊框
- hover 時僅改變邊框顏色

### 4. 更新的檔案

#### CSS 樣式
- ✅ [docs/styles.css](docs/styles.css) - 完整重寫

#### HTML 生成腳本
- ✅ [src/scripts/tools/convert_md_to_html.py](src/scripts/tools/convert_md_to_html.py)
  - 移除 Font Awesome 依賴
  - 更新 HTML 模板
  - 簡化主題切換 JavaScript
  - 使用 emoji 作為圖標

#### HTML 頁面
- ✅ [docs/index.html](docs/index.html) - 首頁
- ✅ [docs/market.html](docs/market.html) - 市場分析
- ✅ [docs/holdings.html](docs/holdings.html) - 持股分析
- ✅ [docs/stocks/index.html](docs/stocks/index.html) - 個股列表
- ✅ [docs/stocks/*.html](docs/stocks/) - 所有個股頁面 (11 個)

### 5. 主題功能

#### 主題切換
- 預設為**淺色模式** (符合 Notion 習慣)
- 使用 localStorage 記憶用戶偏好
- 支援系統深色模式偵測
- 平滑的主題切換動畫

#### 響應式設計
- 完整支援桌面、平板、手機
- 在小螢幕上自動調整排版
- 保持 Notion 風格的簡潔感

## 設計理念

### Notion 的核心設計原則
1. **簡潔至上**: 移除不必要的裝飾元素
2. **內容優先**: 讓文字和資訊成為焦點
3. **細膩質感**: 使用微妙的陰影和過渡效果
4. **舒適閱讀**: 優化文字大小、行高和間距
5. **專業優雅**: 中性配色,適合長時間閱讀

### 相較於原始主題
- **移除**: 漸變背景、浮誇陰影、過大圓角
- **簡化**: 按鈕樣式、卡片設計、表格外觀
- **優化**: 文字排版、間距、色彩對比度
- **保留**: 響應式佈局、主題切換、所有功能

## 使用說明

### 重新生成所有頁面
```bash
cd /home/kasm-user/Desktop/MH/market-intelligence-system
python3 src/scripts/tools/generate_github_pages.py
```

### 查看效果
1. 在瀏覽器中打開 `docs/index.html`
2. 點擊右上角的 ☀️/🌙 圖標切換主題
3. 瀏覽不同頁面感受整體風格

## 技術細節

### CSS 變數系統
使用 CSS 自定義屬性 (CSS Variables) 實現主題切換:
```css
:root { /* 深色主題 */ }
body.theme-light { /* 淺色主題 */ }
```

### 無外部依賴
- 移除 Font Awesome CDN
- 使用 emoji 和 Unicode 符號
- 減少載入時間和外部依賴

### 效能優化
- 更小的 CSS 檔案
- 移除不必要的 JavaScript
- 優化動畫效果

## 下一步建議

1. **測試**: 在不同瀏覽器和裝置上測試顯示效果
2. **微調**: 根據實際使用體驗調整配色和間距
3. **擴展**: 考慮添加更多 Notion 風格的組件
4. **文檔**: 為團隊成員準備主題使用指南

## 參考資源

- [Notion Design System](https://www.notion.so)
- Notion 官方配色方案分析
- 系統原生字體最佳實踐

---

**Created by**: MH Hung
**Date**: 2025-12-08
**Version**: 1.0.0
