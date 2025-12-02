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
	@echo "  make analyze-ollama - Run Ollama news preprocessing"
	@echo "  make analyze-all    - Complete analysis (Ollama + Claude)"
	@echo "  make daily          - Complete daily workflow (fetch + analyze)"
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
	$(PYTHON_BIN) scrapers/fetch_global_indices.py

fetch-holdings: install
	$(PYTHON_BIN) scrapers/fetch_holdings_prices.py

fetch-news: install
	$(PYTHON_BIN) scrapers/fetch_all_news.py

fetch-all: install
	@echo "Running all scrapers..."
	$(PYTHON_BIN) scrapers/fetch_global_indices.py
	$(PYTHON_BIN) scrapers/fetch_holdings_prices.py
	$(PYTHON_BIN) scrapers/fetch_all_news.py
	@echo "All scrapers completed!"

# Analysis targets (CLI-based, no Python SDK required)
analyze-daily:
	@echo "Starting daily market analysis (Claude CLI)..."
	./utils/run_daily_analysis_claude_cli.sh

analyze-ollama:
	@echo "Starting Ollama news analysis..."
	./utils/run_daily_analysis_ollama_cli.sh

analyze-all: analyze-ollama analyze-daily
	@echo "✅ Complete analysis workflow (Ollama + Claude)!"

daily: fetch-all analyze-daily
	@echo "✅ Daily workflow completed (fetch + analyze)!"

# GitHub Pages targets
update-pages:
	@echo "Updating GitHub Pages HTML from latest reports..."
	./utils/update_github_pages.sh

preview-pages:
	@echo "Starting preview server at http://localhost:8000"
	@echo "Press Ctrl+C to stop"
	@cd docs && python3 -m http.server 8000

# Git & Deploy targets
commit:
	@echo "📝 Committing changes..."
	@git add docs/ analysis/
	@git status
	@echo ""
	@echo "Enter commit message (or press Ctrl+C to cancel):"
	@read -p "> " msg; \
	git commit -m "$$msg"
	@echo "✅ Changes committed!"

commit-auto:
	@echo "📝 Committing with auto-generated message..."
	@git add docs/ analysis/
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
	$(PYTHON_BIN) analyzers/run_daily_analysis.py

.PHONY: help venv install test clean clean-venv fetch-global fetch-holdings fetch-news fetch-all analyze-daily analyze-ollama analyze-all analyze-daily-python daily update-pages preview-pages commit commit-auto push deploy
