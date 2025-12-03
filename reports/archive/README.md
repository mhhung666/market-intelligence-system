# Archive Directory

This directory stores historical market analysis reports.

## Purpose

- Keep historical reports for trend analysis and learning
- `reports/markdown/` contains only the latest reports for GitHub Pages
- Older reports are automatically moved here when running `make clean-old-reports`

## File Naming

- `market-analysis-YYYY-MM-DD.md` - Daily market analysis reports
- `holdings-analysis-YYYY-MM-DD.md` - Daily portfolio analysis reports

## Usage

To archive old reports and keep only the latest in `reports/markdown/`:
```bash
make clean-old-reports
```

This will:
1. Move all old reports to this `archive/` directory
2. Keep only the latest reports in `reports/markdown/`
3. Preserve all historical data for future reference
