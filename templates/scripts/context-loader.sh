#!/bin/bash
# context-loader.sh - Unified Context Loading System
# Version: 1.0
# Usage: context-loader.sh [smart|minimal|compact|standard|full] [task]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$(dirname "$SCRIPT_DIR")/memory"
CONFIG_FILE="$MEMORY_DIR/config/memory-config.json"
CACHE_DIR="$MEMORY_DIR/cache"
CHROMA_DB="$CACHE_DIR/chroma"

# Token configuration
TOKEN_WINDOW=200000
SAFE_THRESHOLD=0.3

# Session detection (customize for your setup)
MAIN_USER_ID=""
SESSION_INFO_FILE="/tmp/agent-session-info.json"

# Output control
OUTPUT_FORMAT="${OUTPUT_FORMAT:-text}"

# Helper functions
log() {
    [[ "$OUTPUT_FORMAT" != "quiet" ]] && echo "$@"
}

load_config() {
    [[ -f "$CONFIG_FILE" ]] && cat "$CONFIG_FILE" || echo "{}"
}

get_token_usage() {
    local context_file="${1:-/tmp/agent-context.txt}"
    if [[ -f "$context_file" ]]; then
        local chars=$(wc -c < "$context_file" 2>/dev/null || echo "0")
        echo $((chars / 4))
    else
        echo "0"
    fi
}

detect_session_type() {
    if [[ -n "$AGENT_USER_ID" && "$AGENT_USER_ID" == "$MAIN_USER_ID" ]]; then
        echo "main"
    else
        echo "main"
    fi
}

detect_task_type() {
    local task="$1"
    task=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    
    if echo "$task" | grep -qE '\b(debug|fix|error|bug|broken|crash|exception|fail)\b'; then
        echo "debug"
    elif echo "$task" | grep -qE '\b(create|build|implement|add|make|new|setup|install|write)\b'; then
        echo "create"
    elif echo "$task" | grep -qE '\b(learn|explain|how|what|why|teach|understand|tell me)\b'; then
        echo "learn"
    elif echo "$task" | grep -qE '\b(review|analyze|check|audit|inspect|examine)\b'; then
        echo "review"
    else
        echo "general"
    fi
}

determine_level() {
    local session_type="$1"
    local current_usage="$2"
    
    local available=$((TOKEN_WINDOW - current_usage))
    local safe_available=$((available * 70 / 100))
    
    if [[ $safe_available -lt 5000 ]]; then
        echo "minimal"
    elif [[ $safe_available -lt 15000 ]]; then
        echo "compact"
    elif [[ $safe_available -lt 30000 ]]; then
        echo "standard"
    else
        echo "full"
    fi
}

# Context level loaders
load_minimal() {
    log "📦 Loading MINIMAL context (~2KB)"
    cat "$MEMORY_DIR/core/CORE.md" 2>/dev/null
    cat "$MEMORY_DIR/core/RULES.md" 2>/dev/null
    log "📦 Context size: ~2KB (minimal)"
}

load_compact() {
    log "📦 Loading COMPACT context (~5KB)"
    local compact_file="$CACHE_DIR/CONTEXT_COMPACT.md"
    if [[ -f "$compact_file" ]]; then
        cat "$compact_file"
    else
        cat "$MEMORY_DIR/core/CORE.md" 2>/dev/null
        cat "$MEMORY_DIR/profiles/USER.md" 2>/dev/null
        head -30 "$MEMORY_DIR/profiles/AGENT.md" 2>/dev/null
    fi
    log "📦 Context size: ~5KB (compact)"
}

load_standard() {
    local task="$1"
    local task_type=$(detect_task_type "$task")
    
    log "📦 Loading STANDARD context (~10KB) - Task type: $task_type"
    
    cat "$MEMORY_DIR/core/CORE.md" 2>/dev/null
    cat "$MEMORY_DIR/core/RULES.md" 2>/dev/null
    cat "$MEMORY_DIR/profiles/USER.md" 2>/dev/null
    
    case "$task_type" in
        debug|create)
            cat "$MEMORY_DIR/profiles/AGENT.md" 2>/dev/null
            cat "$MEMORY_DIR/profiles/MODELS.md" 2>/dev/null
            ;;
        learn|review)
            cat "$MEMORY_DIR/knowledge/LEARNINGS.md" 2>/dev/null
            cat "$MEMORY_DIR/knowledge/INDEX.md" 2>/dev/null
            ;;
        general)
            cat "$MEMORY_DIR/profiles/AGENT.md" 2>/dev/null
            head -50 "$MEMORY_DIR/knowledge/PROJECTS.md" 2>/dev/null
            ;;
    esac
    log "📦 Context size: ~10KB (standard)"
}

load_full() {
    local task="$1"
    log "📦 Loading FULL context"
    
    cat "$MEMORY_DIR/core/CORE.md" 2>/dev/null
    cat "$MEMORY_DIR/core/RULES.md" 2>/dev/null
    cat "$MEMORY_DIR/profiles/USER.md" 2>/dev/null
    cat "$MEMORY_DIR/profiles/AGENT.md" 2>/dev/null
    cat "$MEMORY_DIR/profiles/MODELS.md" 2>/dev/null
    cat "$MEMORY_DIR/knowledge/LEARNINGS.md" 2>/dev/null
    cat "$MEMORY_DIR/knowledge/PROJECTS.md" 2>/dev/null
    cat "$MEMORY_DIR/knowledge/INDEX.md" 2>/dev/null
    
    local today_log="$MEMORY_DIR/sessions/daily/$(date +%Y-%m-%d).md"
    if [[ -f "$today_log" ]]; then
        echo ""
        echo "## 📝 Today's Session"
        cat "$today_log"
    fi
    log "📦 Context size: ~20KB (full)"
}

# Smart loader
load_smart() {
    local task="$1"
    local explicit_level="$2"
    
    local session_type=$(detect_session_type)
    local token_usage=$(get_token_usage)
    local level="${explicit_level:-$(determine_level "$session_type" "$token_usage")}"
    
    log ""
    log "════════════════════════════════════════════════════════"
    log "🧠 SOTA MEMORY SYSTEM"
    log "════════════════════════════════════════════════════════"
    log "Session: $session_type | Level: $level"
    log ""
    
    case "$level" in
        minimal) load_minimal ;;
        compact) load_compact ;;
        standard) load_standard "$task" ;;
        full) load_full "$task" ;;
        *) load_standard "$task" ;;
    esac
    
    log ""
    log "════════════════════════════════════════════════════════"
    log "✅ Memory load complete"
    log "════════════════════════════════════════════════════════"
    log ""
}

# CLI
case "${1:-help}" in
    smart) shift; load_smart "$@" ;;
    minimal) load_minimal ;;
    compact) load_compact ;;
    standard) shift; load_standard "${1:-general}" ;;
    full) shift; load_full "${1:-}" ;;
    detect-task) shift; detect_task_type "$@" ;;
    detect-session) detect_session_type ;;
    level)
        local session_type=$(detect_session_type)
        local usage=$(get_token_usage)
        determine_level "$session_type" "$usage"
        ;;
    status)
        echo "=== MEMORY SYSTEM STATUS ==="
        echo ""
        echo "Memory Dir: $MEMORY_DIR"
        echo "ChromaDB: $([ -d "$CHROMA_DB" ] && echo "✅ Initialized" || echo "❌ Not initialized")"
        echo ""
        echo "Session Type: $(detect_session_type)"
        echo "Recommended Level: $(determine_level $(detect_session_type) $(get_token_usage))"
        echo ""
        echo "Files Available:"
        find "$MEMORY_DIR" -name "*.md" -type f 2>/dev/null | wc -l | xargs echo "  Memory files:"
        du -sh "$MEMORY_DIR" 2>/dev/null | awk '{print "  Total size: "$1}'
        ;;
    help)
        echo "context-loader.sh - Unified Memory Loading System"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  smart [task] [level]  - Auto-select best context level"
        echo "  minimal               - Load minimal context (~2KB)"
        echo "  compact               - Load compact context (~5KB)"
        echo "  standard [task]       - Load task-aware context (~10KB)"
        echo "  full [task]           - Load full context (~20KB)"
        echo ""
        echo "  detect-task <task>    - Detect task type from input"
        echo "  level                 - Get recommended context level"
        echo "  status                - Show memory system status"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use 'help' to see available commands"
        exit 1
        ;;
esac
