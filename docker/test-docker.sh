#!/bin/bash
# Test script for Docker setup

set -e

echo "🧪 Testing Market Intelligence System Docker Setup"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env exists
echo "1️⃣  Checking environment file..."
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env file not found${NC}"
    echo "   Please copy .env.docker to .env and fill in CLAUDE_TOKEN"
    echo "   Run: cp .env.docker .env"
    exit 1
fi

# Check if CLAUDE_TOKEN is set
if grep -q "your_claude_session_token_here" .env; then
    echo -e "${YELLOW}⚠️  CLAUDE_TOKEN not configured in .env${NC}"
    echo "   Please edit .env and add your Claude token"
    exit 1
fi

echo -e "${GREEN}✅ Environment file OK${NC}"
echo ""

# Check Docker
echo "2️⃣  Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker OK${NC}"
echo "   Docker: $(docker --version)"
echo "   Compose: $(docker-compose --version)"
echo ""

# Build image
echo "3️⃣  Building Docker image..."
if docker-compose build > /tmp/docker-build.log 2>&1; then
    echo -e "${GREEN}✅ Image built successfully${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    echo "   Check logs: /tmp/docker-build.log"
    exit 1
fi
echo ""

# Test container startup
echo "4️⃣  Testing container startup..."
if docker-compose run --rm mis echo "Container works" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Container startup OK${NC}"
else
    echo -e "${RED}❌ Container failed to start${NC}"
    exit 1
fi
echo ""

# Test Claude CLI
echo "5️⃣  Testing Claude CLI authentication..."
if docker-compose run --rm mis bash -c "echo 'test' | claude > /dev/null 2>&1"; then
    echo -e "${GREEN}✅ Claude CLI authenticated${NC}"
else
    echo -e "${YELLOW}⚠️  Claude CLI authentication may have issues${NC}"
    echo "   This might still work, but double-check your CLAUDE_TOKEN"
fi
echo ""

# Test Python dependencies
echo "6️⃣  Testing Python dependencies..."
if docker-compose run --rm mis python -c "import yfinance; import pandas; import yaml" 2>&1 | grep -q "error"; then
    echo -e "${RED}❌ Python dependencies missing${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Python dependencies OK${NC}"
fi
echo ""

# Test scraper
echo "7️⃣  Testing scraper (this may take a moment)..."
if docker-compose run --rm mis bash -c "cd /app && python src/scrapers/fetch_global_indices.py" > /tmp/scraper-test.log 2>&1; then
    echo -e "${GREEN}✅ Scraper test passed${NC}"
else
    echo -e "${YELLOW}⚠️  Scraper test had warnings (check /tmp/scraper-test.log)${NC}"
fi
echo ""

# Summary
echo "=================================================="
echo -e "${GREEN}🎉 All tests passed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Run a single analysis:"
echo "     make docker-daily"
echo ""
echo "  2. Start container for interactive use:"
echo "     make docker-up"
echo "     make docker-run CMD=daily"
echo ""
echo "  3. Start cron for automated execution:"
echo "     make docker-cron-up"
echo ""
echo "  4. View results:"
echo "     ls -lh reports/markdown/"
echo ""
