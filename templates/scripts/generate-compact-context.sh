#!/bin/bash
# generate-compact-context.sh - Generate compressed context
# Version: 1.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$(dirname "$SCRIPT_DIR")/memory"
CACHE_DIR="$MEMORY_DIR/cache"
OUTPUT="$CACHE_DIR/CONTEXT_COMPACT.md"

generate() {
    mkdir -p "$CACHE_DIR"
    
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local profile_user="$MEMORY_DIR/profiles/USER.md"
    local profile_agent="$MEMORY_DIR/profiles/AGENT.md"
    local profile_models="$MEMORY_DIR/profiles/MODELS.md"
    local core_file="$MEMORY_DIR/core/CORE.md"
    local learnings="$MEMORY_DIR/knowledge/LEARNINGS.md"
    local projects="$MEMORY_DIR/knowledge/PROJECTS.md"
    local today_log="$MEMORY_DIR/sessions/daily/$(date +%Y-%m-%d).md"
    
    echo "🔄 Generating compact context..."
    
    {
        echo "# CONTEXT_COMPACT.md - Compressed Essential Context"
        echo "# Auto-generated: $timestamp"
        echo ""
        
        echo "## USER"
        [[ -f "$profile_user" ]] && grep -E "^\*\*|^-" "$profile_user" | head -10
        echo ""
        
        echo "## AGENT"
        [[ -f "$profile_agent" ]] && grep -E "^\*\*|^-" "$profile_agent" | head -10
        echo ""
        
        echo "## ACTIVE PROJECTS"
        [[ -f "$projects" ]] && grep -A 5 "## Active" "$projects" | head -10
        echo ""
        
        echo "## RECENT LEARNINGS"
        [[ -f "$learnings" ]] && grep -B 1 -A 2 "### Learning:" "$learnings" | head -15
        echo ""
        
        echo "## MODEL STRATEGY"
        [[ -f "$profile_models" ]] && grep -A 5 "## Routing" "$profile_models" | head -8
        echo ""
        
        if [[ -f "$today_log" ]]; then
            echo "## TODAY'S SESSION"
            grep -E "^##|^###|✅" "$today_log" | head -8
            echo ""
        fi
        
    } > "$OUTPUT"
    
    local compact_size=$(wc -c < "$OUTPUT")
    local full_size=0
    for file in "$profile_user" "$profile_agent" "$profile_models" "$core_file"; do
        [[ -f "$file" ]] && full_size=$((full_size + $(wc -c < "$file")))
    done
    
    local savings=0
    [[ $full_size -gt 0 ]] && savings=$((100 - (compact_size * 100 / full_size)))
    
    echo "✅ Compact context generated: $OUTPUT"
    echo "   Size: ${compact_size} bytes (~$((compact_size / 1024))KB)"
    echo "   Savings: ${savings}%"
}

case "${1:-generate}" in
    generate) generate ;;
    status)
        if [[ -f "$OUTPUT" ]]; then
            echo "=== COMPACT CONTEXT STATUS ==="
            echo "File: $OUTPUT"
            echo "Size: $(wc -c < "$OUTPUT") bytes"
            head -20 "$OUTPUT"
        else
            echo "Not generated. Run: $0 generate"
        fi
        ;;
    *) echo "Usage: $0 [generate|status]" ;;
esac
