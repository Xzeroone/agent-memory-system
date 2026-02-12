#!/bin/bash
# summarize-session.sh - Compress session logs
# Version: 1.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$(dirname "$SCRIPT_DIR")/memory"
DAILY_DIR="$MEMORY_DIR/sessions/daily"
ARCHIVE_DIR="$MEMORY_DIR/sessions/archive"

summarize_file() {
    local input="$1"
    local output="${input%.md}-summary.md"
    
    [[ ! -f "$input" ]] && { echo "File not found: $input"; return 1; }
    
    local original_size=$(wc -c < "$input")
    
    {
        echo "# Session Summary: $(basename $input)"
        echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo ""
        echo "## Sections"
        grep -E "^##|^###" "$input" 2>/dev/null | head -15 || echo "(None found)"
        echo ""
        echo "## Accomplishments"
        grep -E "✅|Complete|Done" "$input" 2>/dev/null | head -10 || echo "(None marked)"
        echo ""
        echo "## Decisions"
        grep -E "Decision:|Decided:|⚠️" "$input" 2>/dev/null | head -10 || echo "(None marked)"
        echo ""
        echo "## Learnings"
        grep -E "Learning:|Learned:|Note:" "$input" 2>/dev/null | head -10 || echo "(None marked)"
        echo ""
        echo "---"
        echo "Full log: $input"
    } > "$output"
    
    local summary_size=$(wc -c < "$output")
    local savings=$((100 - (summary_size * 100 / original_size)))
    echo "✅ Created: $output (${savings}% smaller)"
}

summarize_yesterday() {
    local yesterday=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
    local log_file="$DAILY_DIR/${yesterday}.md"
    [[ -f "$log_file" ]] && summarize_file "$log_file" || echo "No log for yesterday"
}

archive_old() {
    local days="${1:-7}"
    echo "📦 Archiving logs older than $days days..."
    local count=0
    find "$DAILY_DIR" -name "*.md" -not -name "*-summary.md" -mtime +$days 2>/dev/null | while read -r file; do
        mv "$file" "$ARCHIVE_DIR/"
        echo "   Archived: $(basename $file)"
    done
}

case "${1:-help}" in
    file) summarize_file "$2" ;;
    yesterday) summarize_yesterday ;;
    all)
        echo "📄 Summarizing all daily logs..."
        for file in "$DAILY_DIR"/*.md; do
            [[ -f "$file" ]] && [[ ! "$file" == *"-summary.md" ]] && summarize_file "$file"
        done
        ;;
    archive) archive_old "${2:-7}" ;;
    status)
        echo "=== SESSION COMPRESSION STATUS ==="
        echo "Daily logs: $(ls "$DAILY_DIR"/*.md 2>/dev/null | wc -l)"
        echo "Summaries: $(ls "$DAILY_DIR"/*-summary.md 2>/dev/null | wc -l)"
        echo "Archive: $(ls "$ARCHIVE_DIR"/*.md 2>/dev/null | wc -l)"
        ;;
    *)
        echo "summarize-session.sh - Session Log Compression"
        echo ""
        echo "Commands:"
        echo "  file <path>      - Summarize specific file"
        echo "  yesterday        - Summarize yesterday's log"
        echo "  all              - Summarize all daily logs"
        echo "  archive [days]   - Archive logs older than N days"
        echo "  status           - Show compression status"
        ;;
esac
