# API Reference

Complete documentation for all scripts.

## context-loader.sh

Main entry point for loading memory context.

### Commands

```bash
context-loader.sh smart [task] [level]
context-loader.sh minimal
context-loader.sh compact
context-loader.sh standard [task]
context-loader.sh full [task]
context-loader.sh status
context-loader.sh level
context-loader.sh detect-task <task>
```

### Examples

```bash
# Auto-select level
context-loader.sh smart "debug authentication error"

# Force specific level
context-loader.sh smart "create new feature" compact

# Get recommended level
context-loader.sh level
# Output: standard

# Detect task type
context-loader.sh detect-task "fix the bug in login"
# Output: debug
```

### Output Formats

```bash
# Normal (default)
OUTPUT_FORMAT=text context-loader.sh smart "task"

# Quiet (no logging)
OUTPUT_FORMAT=quiet context-loader.sh smart "task"
```

---

## semantic-search.sh

ChromaDB-powered semantic search.

### Commands

```bash
semantic-search.sh init
semantic-search.sh embed
semantic-search.sh search <query>
semantic-search.sh update <file>
semantic-search.sh status
semantic-search.sh clear
```

### Examples

```bash
# Initialize
semantic-search.sh init

# Search
semantic-search.sh search "user preferences"
semantic-search.sh search "how to debug"

# Update single file
semantic-search.sh update memory/profiles/USER.md

# Check status
semantic-search.sh status
```

### Output Format

```
📄 /path/to/file.md
   Distance: 0.8312
   Tags: user, preferences
   Preview: First 100 characters...
```

---

## generate-compact-context.sh

Generate compressed context file.

### Commands

```bash
generate-compact-context.sh generate
generate-compact-context.sh status
```

### Examples

```bash
# Generate
generate-compact-context.sh generate
# Output: ✅ Compact context generated: ~/agent-memory/memory/cache/CONTEXT_COMPACT.md
#         Size: 3159 bytes (~3KB)
#         Savings: 81%

# Check status
generate-compact-context.sh status
```

---

## summarize-session.sh

Compress and archive session logs.

### Commands

```bash
summarize-session.sh file <path>
summarize-session.sh yesterday
summarize-session.sh all
summarize-session.sh archive [days]
summarize-session.sh status
```

### Examples

```bash
# Summarize yesterday
summarize-session.sh yesterday

# Summarize specific file
summarize-session.sh file memory/sessions/daily/2026-02-12.md

# Archive old logs (7+ days)
summarize-session.sh archive 7

# Archive logs older than 30 days
summarize-session.sh archive 30
```

---

## maintenance.sh

Daily maintenance tasks.

### Commands

```bash
maintenance.sh
```

### What It Does

1. Updates embeddings
2. Generates compact context
3. Summarizes yesterday's session
4. Archives old logs (7+ days)

### Logs

Output logged to: `/tmp/memory-maintenance.log`

---

## memory-embeddings.py

Python service for ChromaDB embeddings.

### Commands

```bash
python3 memory-embeddings.py embed
python3 memory-embeddings.py search <query>
python3 memory-embeddings.py update <file>
python3 memory-embeddings.py status
python3 memory-embeddings.py clear
```

### Programmatic Use

```python
import subprocess
import json

# Search
result = subprocess.run(
    ["python3", "memory-embeddings.py", "search", "query"],
    capture_output=True, text=True,
    cwd="/path/to/agent-memory"
)
print(result.stdout)

# Get status as JSON
result = subprocess.run(
    ["python3", "memory-embeddings.py", "status"],
    capture_output=True, text=True
)
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `INSTALL_DIR` | `~/agent-memory` | Installation directory |
| `OUTPUT_FORMAT` | `text` | Output format (text/quiet) |
| `AGENT_USER_ID` | - | User ID for session detection |

---

## Return Codes

All scripts return:
- `0` on success
- `1` on error or invalid command
