#!/bin/bash
# memory-maintenance.sh - Daily memory maintenance
# Version: 1.0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$(dirname "$SCRIPT_DIR")/memory"
LOG_FILE="/tmp/memory-maintenance.log"

log() {
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $1" | tee -a "$LOG_FILE"
}

log "=== MEMORY MAINTENANCE START ==="

# Update embeddings
log "Updating embeddings..."
[[ -x "$SCRIPT_DIR/semantic-search.sh" ]] && "$SCRIPT_DIR/semantic-search.sh" embed >> "$LOG_FILE" 2>&1

# Generate compact context
log "Generating compact context..."
[[ -x "$SCRIPT_DIR/generate-compact-context.sh" ]] && "$SCRIPT_DIR/generate-compact-context.sh" generate >> "$LOG_FILE" 2>&1

# Summarize yesterday
log "Summarizing yesterday's session..."
[[ -x "$SCRIPT_DIR/summarize-session.sh" ]] && "$SCRIPT_DIR/summarize-session.sh" yesterday >> "$LOG_FILE" 2>&1

# Archive old logs
log "Archiving old logs..."
[[ -x "$SCRIPT_DIR/summarize-session.sh" ]] && "$SCRIPT_DIR/summarize-session.sh" archive 7 >> "$LOG_FILE" 2>&1

# Status
log "Memory system status:"
du -sh "$MEMORY_DIR" | tee -a "$LOG_FILE"
find "$MEMORY_DIR" -name "*.md" | wc -l | xargs -I{} echo "  Memory files: {}" | tee -a "$LOG_FILE"

log "=== MEMORY MAINTENANCE COMPLETE ==="
