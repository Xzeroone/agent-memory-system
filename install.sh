#!/bin/bash
# SOTA Agent Memory System - One-Command Installer
# Usage: curl -sSL https://raw.githubusercontent.com/Xzeroone/agent-memory-system/main/install.sh | bash
# License: MIT

set -e

INSTALL_DIR="${INSTALL_DIR:-$HOME/agent-memory}"
REPO_URL="https://github.com/Xzeroone/agent-memory-system"

echo ""
echo "🧠 SOTA Agent Memory System Installer"
echo "======================================"
echo ""
echo "Install directory: $INSTALL_DIR"
echo ""

# 1. Clone or download
if [[ -d "$INSTALL_DIR" ]]; then
    echo "✅ Directory exists, updating..."
    cd "$INSTALL_DIR"
    git pull 2>/dev/null || echo "   (Not a git repo, skipping pull)"
else
    echo "📦 Cloning repository..."
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# 2. Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "   Install with: apt install python3 python3-venv"
    exit 1
fi

# 3. Create Python venv
echo "🐍 Setting up Python environment..."
python3 -m venv venv

# 4. Install dependencies
echo "📥 Installing dependencies (ChromaDB, sentence-transformers)..."
source venv/bin/activate
pip install --quiet --upgrade pip
pip install --quiet chromadb sentence-transformers

# 5. Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x templates/scripts/*.sh 2>/dev/null || true

# 6. Create memory directories
echo "📁 Creating directory structure..."
mkdir -p memory/{profiles,core,knowledge,sessions/{daily,archive},cache,config}
mkdir -p scripts

# 7. Copy scripts to install location
cp templates/scripts/*.sh scripts/ 2>/dev/null || true
cp templates/scripts/*.py scripts/ 2>/dev/null || true
chmod +x scripts/*.sh scripts/*.py 2>/dev/null || true

# 8. Copy templates if files don't exist
echo "📄 Setting up template files..."
for template in templates/memory/**/*.template templates/memory/**/**/*.template; do
    if [[ -f "$template" ]]; then
        # Get target path
        target="${template#templates/}"
        target="${target%.template}"
        
        if [[ ! -f "$target" ]]; then
            mkdir -p "$(dirname "$target")"
            cp "$template" "$target"
            echo "   Created: $target"
        else
            echo "   Exists: $target (skipped)"
        fi
    fi
done

# 9. Generate initial compact context
echo ""
echo "📦 Generating compact context..."
./scripts/generate-compact-context.sh generate 2>/dev/null || echo "   (Will be generated on first use)"

# 10. Initialize embeddings
echo ""
echo "🔍 Initializing embeddings (may take 1-2 minutes on first run)..."
./scripts/semantic-search.sh init 2>/dev/null || echo "   (Run 'scripts/semantic-search.sh init' manually if needed)"

# 11. Print success
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ Installation Complete!"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "  1. Edit your user profile:"
echo "     nano $INSTALL_DIR/memory/profiles/USER.md"
echo ""
echo "  2. Edit your agent profile (rename if needed):"
echo "     nano $INSTALL_DIR/memory/profiles/AGENT.md"
echo ""
echo "  3. Test semantic search:"
echo "     $INSTALL_DIR/scripts/semantic-search.sh search 'test'"
echo ""
echo "  4. Integrate with your agent (see AGENTS.md)"
echo ""
echo "Documentation:"
echo "  - AGENTS.md - Agent installation instructions"
echo "  - docs/QUICK_START.md - 5-minute setup guide"
echo "  - docs/INTEGRATION.md - Integration patterns"
echo ""
