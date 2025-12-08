.DEFAULT_GOAL := help

PYTHON ?= python3
VENV ?= .venv
BIN := $(VENV)/bin
PYTHON_BIN := $(BIN)/python
PIP := $(BIN)/pip
PYTEST := $(BIN)/pytest

help:
	@echo "Common targets:"
	@echo "  make venv           - Create virtual environment"
	@echo "  make install        - Install dependencies into .venv"
	@echo "  make test           - Run pytest"
	@echo "  make clean          - Remove __pycache__ and pytest cache"
	@echo "  make clean-venv     - Delete virtual environment"
	@echo ""
	@echo "Scraper targets:"
	@echo "  make fetch-global   - Fetch global market indices"
	@echo "  make fetch-holdings - Fetch holdings prices"
	@echo "  make fetch-news     - Fetch market news for configured symbols"
	@echo "  make fetch-all      - Run all scrapers"
	@echo ""
	@echo "Analysis targets:"
	@echo "  make analyze-daily  - Run daily market analysis (Claude CLI)"
	@echo "  make analyze-ollama - Run Ollama full analysis (same as Claude)"
	@echo "  make analyze-all    - Complete analysis (Ollama + Claude)"
	@echo "  make daily          - Complete daily workflow (fetch + analyze)"
	@echo "  make clean-old-reports - Archive old reports to reports/archive/, keep only latest"
	@echo ""
	@echo "GitHub Pages targets:"
	@echo "  make update-pages   - Update GitHub Pages HTML from latest reports"
	@echo "  make preview-pages  - Preview GitHub Pages locally (port 8000)"
	@echo ""
	@echo "Git & Deploy targets:"
	@echo "  make commit         - Commit reports and pages (interactive message)"
	@echo "  make commit-auto    - Commit with auto-generated message"
	@echo "  make push           - Push to GitHub (triggers Pages deployment)"
	@echo "  make deploy         - Full deploy (update-pages + commit-auto + push)"
	@echo ""
	@echo "Docker targets:"
	@echo "  make docker-build   - Build Docker image"
	@echo "  make docker-up      - Start Docker container"
	@echo "  make docker-down    - Stop Docker container"
	@echo "  make docker-run     - Run command in Docker (e.g., make docker-run CMD=daily)"
	@echo "  make docker-logs    - View Docker container logs"
	@echo "  make docker-shell   - Open bash shell in container"
	@echo ""
	@echo "Legacy Python SDK targets:"
	@echo "  make analyze-daily-python - Use Python SDK (requires CLAUDE_API_KEY)"

venv:
	$(PYTHON) -m venv $(VENV)

install: venv requirements.txt
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

test: install
	$(PYTEST)

clean:
	find . -name "__pycache__" -type d -prune -exec rm -rf {} +
	rm -rf .pytest_cache

clean-venv:
	rm -rf $(VENV)

# Scraper targets
fetch-global: install
	$(PYTHON_BIN) src/scrapers/fetch_global_indices.py

fetch-holdings: install
	$(PYTHON_BIN) src/scrapers/fetch_holdings_prices.py

fetch-news: install
	$(PYTHON_BIN) src/scrapers/fetch_all_news.py

fetch-all: install
	@echo "Running all scrapers..."
	$(PYTHON_BIN) src/scrapers/fetch_global_indices.py
	$(PYTHON_BIN) src/scrapers/fetch_holdings_prices.py
	$(PYTHON_BIN) src/scrapers/fetch_all_news.py
	@echo "All scrapers completed!"

# Analysis targets (CLI-based, no Python SDK required)
analyze-daily:
	@echo "Starting daily market analysis (Claude CLI)..."
	./src/scripts/analysis/run_daily_analysis_claude_cli.sh

analyze-ollama:
	@echo "Starting Ollama news analysis..."
	./src/scripts/analysis/run_daily_analysis_ollama_cli.sh

analyze-all: analyze-ollama analyze-daily
	@echo "✅ Complete analysis workflow (Ollama + Claude)!"

daily: fetch-all analyze-daily
	@echo "✅ Daily workflow completed (fetch + analyze)!"

# Archive old markdown reports, keep only the latest
clean-old-reports:
	@echo "📦 Archiving old markdown reports..."
	@mkdir -p reports/archive
	@latest_market=$$(ls reports/markdown/market-analysis-*.md 2>/dev/null | sort -r | head -1); \
	latest_holdings=$$(ls reports/markdown/holdings-analysis-*.md 2>/dev/null | sort -r | head -1); \
	if [ -n "$$latest_market" ]; then \
		ls reports/markdown/market-analysis-*.md 2>/dev/null | grep -v "$$latest_market" | xargs -I {} mv {} reports/archive/ 2>/dev/null || true; \
		echo "  ✅ Kept in markdown: $$latest_market"; \
	fi; \
	if [ -n "$$latest_holdings" ]; then \
		ls reports/markdown/holdings-analysis-*.md 2>/dev/null | grep -v "$$latest_holdings" | xargs -I {} mv {} reports/archive/ 2>/dev/null || true; \
		echo "  ✅ Kept in markdown: $$latest_holdings"; \
	fi; \
	stock_count=0; \
	for ticker in $$(ls reports/markdown/stock-*.md 2>/dev/null | sed 's/.*stock-\([^-]*\)-.*/\1/' | sort -u); do \
		latest_stock=$$(ls reports/markdown/stock-$$ticker-*.md 2>/dev/null | sort -r | head -1); \
		if [ -n "$$latest_stock" ]; then \
			archived=$$(ls reports/markdown/stock-$$ticker-*.md 2>/dev/null | grep -v "$$latest_stock" | wc -l); \
			ls reports/markdown/stock-$$ticker-*.md 2>/dev/null | grep -v "$$latest_stock" | xargs -I {} mv {} reports/archive/ 2>/dev/null || true; \
			stock_count=$$((stock_count + archived)); \
			echo "  ✅ Kept in markdown for $$ticker: $$latest_stock"; \
		fi; \
	done; \
	archived_count=$$(ls reports/archive/*.md 2>/dev/null | wc -l); \
	echo "  📦 Archived stock reports: $$stock_count"; \
	echo "  📦 Total archived reports: $$archived_count"

# GitHub Pages targets
update-pages: install
	@echo "🚀 Generating GitHub Pages from latest reports..."
	$(PYTHON_BIN) src/scripts/tools/generate_github_pages.py

preview-pages: install
	@echo "Starting preview server at http://localhost:8000"
	@echo "Press Ctrl+C to stop"
	@cd docs && $(PYTHON_BIN) -m http.server 8000

# Git & Deploy targets
commit:
	@echo "📝 Committing changes..."
	@git add docs/ reports/
	@git status
	@echo ""
	@echo "Enter commit message (or press Ctrl+C to cancel):"
	@read -p "> " msg; \
	git commit -m "$$msg"
	@echo "✅ Changes committed!"

commit-auto:
	@echo "📝 Committing with auto-generated message..."
	@git add docs/ reports/
	@git commit -m "feat(daily): Update analysis reports and GitHub Pages for $$(date +%Y-%m-%d)" || echo "Nothing to commit"
	@echo "✅ Changes committed!"

push:
	@echo "🚀 Pushing to GitHub..."
	@git push origin main
	@echo "✅ Pushed to GitHub! Pages will update in 1-2 minutes."

deploy: update-pages commit-auto push
	@echo "🎉 Full deployment complete!"
	@echo "   1. ✅ HTML pages updated"
	@echo "   2. ✅ Changes committed"
	@echo "   3. ✅ Pushed to GitHub"
	@echo ""
	@echo "Check your GitHub Pages site in 1-2 minutes!"

# Analysis targets (Legacy Python SDK version, requires CLAUDE_API_KEY)
analyze-daily-python: install
	@echo "Starting daily market analysis (Python SDK)..."
	$(PYTHON_BIN) src/legacy/run_daily_analysis.py

# Docker targets
docker-build:
	@echo "Building Docker image..."
	docker-compose build
	@echo "✅ Docker image built successfully!"

docker-up:
	@echo "Starting Docker containers..."
	docker-compose up -d
	@echo "✅ Docker containers started!"

docker-down:
	@echo "Stopping Docker containers..."
	docker-compose down
	@echo "✅ Docker containers stopped!"

docker-run:
	@if [ -z "$(CMD)" ]; then \
		echo "Usage: make docker-run CMD=<command>"; \
		echo "Example: make docker-run CMD=daily"; \
		exit 1; \
	fi
	docker-compose exec mis make $(CMD)

docker-logs:
	docker-compose logs -f

docker-shell:
	docker-compose exec mis bash

docker-daily:
	@echo "Running daily analysis in Docker..."
	docker-compose run --rm mis make daily

docker-cron-up:
	@echo "Starting Docker with cron service..."
	docker-compose --profile cron up -d
	@echo "✅ Cron service started!"

docker-cron-logs:
	@echo "Viewing cron logs..."
	docker-compose exec mis-cron tail -f /app/logs/cron.log

.PHONY: help venv install test clean clean-venv fetch-global fetch-holdings fetch-news fetch-all analyze-daily analyze-ollama analyze-all analyze-daily-python daily clean-old-reports update-pages preview-pages commit commit-auto push deploy docker-build docker-up docker-down docker-run docker-logs docker-shell docker-daily docker-cron-up docker-cron-logs
