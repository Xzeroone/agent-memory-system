#!/bin/bash
# semantic-search.sh - Bash wrapper for memory embeddings
# Version: 1.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(dirname "$SCRIPT_DIR")"
VENV_PATH="$INSTALL_DIR/venv"
SCRIPT_PATH="$SCRIPT_DIR/memory-embeddings.py"
CHROMA_DB="$INSTALL_DIR/memory/cache/chroma"

run_python() {
    source "$VENV_PATH/bin/activate" 2>/dev/null || true
    python3 "$SCRIPT_PATH" "$@"
}

case "${1:-help}" in
    embed)
        echo "🔄 Embedding all memory files into ChromaDB..."
        echo ""
        run_python embed
        ;;
    search)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 search <query>"
            exit 1
        fi
        shift
        run_python search "$@"
        ;;
    update)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 update <file>"
            exit 1
        fi
        run_python update "$2"
        ;;
    status)
        run_python status
        echo ""
        if [[ -d "$CHROMA_DB" ]]; then
            echo "ChromaDB directory:"
            du -sh "$CHROMA_DB"
        fi
        ;;
    clear)
        run_python clear
        ;;
    init)
        echo "Initializing embedding system..."
        run_python embed
        echo ""
        echo "✅ Embedding system initialized"
        ;;
    *)
        echo "semantic-search.sh - Memory Semantic Search"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  init               Initialize and embed all memory files"
        echo "  embed              Re-embed all memory files"
        echo "  search <query>     Semantic search across memory"
        echo "  update <file>      Update embeddings for single file"
        echo "  status             Show embedding system status"
        echo "  clear              Clear all embeddings"
        echo ""
        echo "Examples:"
        echo "  $0 search 'debug error'"
        echo "  $0 search 'how to create'"
        echo "  $0 update memory/profiles/USER.md"
        ;;
esac
