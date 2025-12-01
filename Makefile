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
	@echo "  make analyze-daily  - Run daily market analysis (Claude AI)"
	@echo "  make daily          - Complete daily workflow (fetch + analyze)"

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

# Analysis targets
analyze-daily: install
	@echo "Starting daily market analysis..."
	$(PYTHON_BIN) analyzers/run_daily_analysis.py

daily: fetch-all analyze-daily
	@echo "✅ Daily workflow completed (fetch + analyze)!"

.PHONY: help venv install test clean clean-venv fetch-global fetch-holdings fetch-news fetch-all analyze-daily daily
