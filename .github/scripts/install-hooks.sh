#!/bin/bash
#
# install-hooks.sh
# Install git hooks for VisionClaw development
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/hooks"
GIT_HOOKS_DIR="$(git rev-parse --git-path hooks 2>/dev/null)"

if [ -z "$GIT_HOOKS_DIR" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🪝 Installing Git Hooks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Git hooks directory: $GIT_HOOKS_DIR"
echo ""

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "⚠️  SwiftLint not installed"
    echo ""
    echo "Pre-commit hook will be installed but will skip linting until SwiftLint is installed."
    echo ""
    echo "To install SwiftLint:"
    echo "  brew install swiftlint"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Installation cancelled"
        exit 0
    fi
    echo ""
fi

# Install pre-commit hook
if [ -f "$HOOKS_DIR/pre-commit" ]; then
    if [ -f "$GIT_HOOKS_DIR/pre-commit" ]; then
        # Backup existing hook
        BACKUP="$GIT_HOOKS_DIR/pre-commit.backup.$(date +%s)"
        echo "📦 Backing up existing pre-commit hook to:"
        echo "   $(basename $BACKUP)"
        mv "$GIT_HOOKS_DIR/pre-commit" "$BACKUP"
        echo ""
    fi
    
    cp "$HOOKS_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
    chmod +x "$GIT_HOOKS_DIR/pre-commit"
    echo "✅ Installed pre-commit hook"
else
    echo "❌ Error: pre-commit hook not found at $HOOKS_DIR/pre-commit"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Git hooks installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The pre-commit hook will now:"
echo "  • Run SwiftLint on staged Swift files"
echo "  • Block commits if linting fails"
echo "  • Keep your code clean and consistent"
echo ""
echo "To bypass the hook (not recommended):"
echo "  git commit --no-verify"
echo ""
echo "To uninstall:"
echo "  rm $GIT_HOOKS_DIR/pre-commit"
echo ""
