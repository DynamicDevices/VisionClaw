#!/bin/bash
#
# setup-secrets.sh
# Helper script to create Secrets.swift from template
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SECRETS_DIR="$PROJECT_ROOT/samples/CameraAccess/CameraAccess"
TEMPLATE="$SECRETS_DIR/Secrets.swift.template"
SECRETS="$SECRETS_DIR/Secrets.swift"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 VisionClaw Secrets Configuration Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Secrets.swift already exists
if [ -f "$SECRETS" ]; then
    echo "⚠️  Secrets.swift already exists at:"
    echo "   $SECRETS"
    echo ""
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled. Existing Secrets.swift preserved."
        exit 0
    fi
fi

# Copy template to Secrets.swift
if [ ! -f "$TEMPLATE" ]; then
    echo "❌ Error: Template not found at:"
    echo "   $TEMPLATE"
    exit 1
fi

cp "$TEMPLATE" "$SECRETS"
echo "✅ Created Secrets.swift from template"
echo ""

# Prompt for Gemini API key
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Gemini API Key (required)"
echo "   Get yours at: https://aistudio.google.com/apikey"
echo ""
read -p "Enter your Gemini API key (or press Enter to skip): " GEMINI_KEY

if [ -n "$GEMINI_KEY" ]; then
    # Escape special characters for sed
    GEMINI_KEY_ESCAPED=$(printf '%s\n' "$GEMINI_KEY" | sed 's/[[\.*^$/]/\\&/g')
    sed -i "s/YOUR_GEMINI_API_KEY/$GEMINI_KEY_ESCAPED/g" "$SECRETS"
    echo "✅ Gemini API key configured"
else
    echo "⏭️  Skipped Gemini API key (you can edit Secrets.swift manually later)"
fi

echo ""
echo "2. OpenClaw Configuration (optional)"
echo "   Only needed if you want agentic actions (send messages, search web, etc.)"
echo ""
read -p "Configure OpenClaw now? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "OpenClaw host (e.g., http://192.168.1.100): " OPENCLAW_HOST
    read -p "OpenClaw port (default 18789): " OPENCLAW_PORT
    read -p "OpenClaw gateway token: " OPENCLAW_TOKEN
    
    if [ -n "$OPENCLAW_HOST" ]; then
        sed -i "s|http://YOUR_MAC_HOSTNAME.local|$OPENCLAW_HOST|g" "$SECRETS"
        echo "✅ OpenClaw host configured"
    fi
    
    if [ -n "$OPENCLAW_PORT" ]; then
        sed -i "s/18789/$OPENCLAW_PORT/g" "$SECRETS"
        echo "✅ OpenClaw port configured"
    fi
    
    if [ -n "$OPENCLAW_TOKEN" ]; then
        OPENCLAW_TOKEN_ESCAPED=$(printf '%s\n' "$OPENCLAW_TOKEN" | sed 's/[[\.*^$/]/\\&/g')
        sed -i "s/YOUR_OPENCLAW_GATEWAY_TOKEN/$OPENCLAW_TOKEN_ESCAPED/g" "$SECRETS"
        echo "✅ OpenClaw gateway token configured"
    fi
else
    echo "⏭️  Skipped OpenClaw configuration"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Secrets.swift created at:"
echo "  $SECRETS"
echo ""
echo "Next steps:"
echo "  1. Open project: open samples/CameraAccess/CameraAccess.xcodeproj"
echo "  2. Select your Apple ID for signing (free provisioning)"
echo "  3. Build and run on your iPhone (Cmd+R)"
echo ""
echo "For detailed instructions, see: docs/DEVELOPMENT.md"
echo ""
