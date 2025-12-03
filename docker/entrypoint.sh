#!/bin/bash
set -e

echo "🚀 Market Intelligence System - Docker Container"
echo "================================================"

# Setup Claude CLI token if provided
if [ -z "$CLAUDE_TOKEN" ]; then
    echo "⚠️  CLAUDE_TOKEN not set"
    echo "   Please set CLAUDE_TOKEN environment variable"
    echo "   Example: docker run -e CLAUDE_TOKEN=your_token ..."
    exit 1
fi

echo "🔐 Setting up Claude CLI authentication..."
mkdir -p ~/.config/claude

# Check if CLAUDE_TOKEN looks like JSON (OAuth format)
if [[ "$CLAUDE_TOKEN" == "{"* ]]; then
    echo "   Using OAuth format"
    echo "$CLAUDE_TOKEN" > ~/.config/claude/credentials.json
else
    echo "   Using session key format"
    # Create Claude CLI config with session key
    cat > ~/.config/claude/credentials.json <<EOF
{
  "claudeAiOauth": {
    "accessToken": "$CLAUDE_TOKEN",
    "refreshToken": "",
    "scopes": ["user:inference", "user:profile", "user:sessions:claude_code"],
    "subscriptionType": "pro",
    "rateLimitTier": "default_claude_ai"
  }
}
EOF
fi

echo "✅ Claude CLI configured"

# Verify Claude CLI is working
if claude --version > /dev/null 2>&1; then
    echo "✅ Claude CLI ready ($(claude --version))"
else
    echo "❌ Claude CLI not working properly"
    echo "   Please check your CLAUDE_TOKEN"
    exit 1
fi

# Setup cron if crontab exists
if [ -f /etc/cron.d/mis-cron ]; then
    echo "⏰ Setting up cron jobs..."
    chmod 0644 /etc/cron.d/mis-cron
    crontab /etc/cron.d/mis-cron

    # Create log file
    touch /app/logs/cron.log
    chmod 0666 /app/logs/cron.log

    # Start cron in background
    cron
    echo "✅ Cron service started"

    # Show scheduled jobs
    echo "📅 Scheduled jobs:"
    crontab -l | grep -v "^#" | grep -v "^$" || echo "   No jobs configured"
fi

echo "================================================"
echo "🎯 Ready! Executing command: $@"
echo ""

# Execute the command
exec "$@"
