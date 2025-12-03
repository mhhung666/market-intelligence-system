#!/bin/bash
# Helper script to setup Claude token in .env file

echo "🔐 Claude Token Setup Helper"
echo "=============================="
echo ""

# Check if credentials.json exists locally
if [ -f ~/.config/claude/credentials.json ]; then
    echo "✅ Found local Claude credentials"
    echo ""
    echo "Your credentials file contains:"
    cat ~/.config/claude/credentials.json | jq . 2>/dev/null || cat ~/.config/claude/credentials.json
    echo ""
    echo "----------------------------------------"
    echo ""

    # Extract access token
    ACCESS_TOKEN=$(cat ~/.config/claude/credentials.json | jq -r '.claudeAiOauth.accessToken' 2>/dev/null)

    if [ "$ACCESS_TOKEN" != "null" ] && [ ! -z "$ACCESS_TOKEN" ]; then
        echo "Option 1: Use full OAuth credentials (Recommended)"
        echo "Copy this line to your .env file:"
        echo ""
        FULL_JSON=$(cat ~/.config/claude/credentials.json | tr -d '\n')
        echo "CLAUDE_TOKEN='$FULL_JSON'"
        echo ""
        echo "----------------------------------------"
        echo ""
        echo "Option 2: Use access token only (Simple)"
        echo "Copy this line to your .env file:"
        echo ""
        echo "CLAUDE_TOKEN=$ACCESS_TOKEN"
        echo ""
    else
        echo "⚠️  Could not parse access token from credentials.json"
        echo "Please manually copy the content to .env"
    fi
else
    echo "❌ Local Claude credentials not found"
    echo ""
    echo "Please run: claude login"
    echo ""
    echo "Or manually create credentials.json with your token:"
    echo "  mkdir -p ~/.config/claude"
    echo "  nano ~/.config/claude/credentials.json"
fi

echo "----------------------------------------"
echo ""
echo "Next steps:"
echo "1. Copy one of the CLAUDE_TOKEN lines above"
echo "2. Edit .env file: nano .env"
echo "3. Paste the CLAUDE_TOKEN line"
echo "4. Save and test: make docker-build && make docker-daily"
echo ""
