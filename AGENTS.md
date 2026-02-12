# SOTA Agent Memory System - Agent Instructions

> This file tells AI agents how to install and use this memory system.

## What This Is

A production-grade memory system for AI agents featuring:
- **Semantic search** via ChromaDB vector embeddings
- **Task-aware context loading** (minimal/compact/standard/full levels)
- **Memory compression** (~80% token savings)
- **Cross-session persistence** in structured markdown

## Installation (One Command)

```bash
curl -sSL https://raw.githubusercontent.com/Xzeroone/agent-memory-system/main/install.sh | bash
```

This will:
1. Clone to `~/agent-memory/`
2. Create Python venv with ChromaDB + sentence-transformers
3. Copy template files (won't overwrite existing)
4. Initialize embeddings
5. Print next steps

## Post-Install Steps

After installation, customize for your user:

1. **Edit user profile**: `~/agent-memory/memory/profiles/USER.md`
   - Add user's name, preferences, working style

2. **Edit agent profile**: `~/agent-memory/memory/profiles/AGENT.md`
   - Rename file to match your agent name
   - Define agent's persona, communication style, specialties

3. **Edit model strategy**: `~/agent-memory/memory/profiles/MODELS.md`
   - Update for your model provider(s)

4. **Initialize embeddings**:
   ```bash
   ~/agent-memory/scripts/semantic-search.sh init
   ```

5. **Test**:
   ```bash
   ~/agent-memory/scripts/semantic-search.sh search "test query"
   ```

## Integration Patterns

### Bash-based agents (OpenCode, etc.)

Add to your bridge/run script before executing tasks:

```bash
MEMORY_SCRIPT="$HOME/agent-memory/scripts/context-loader.sh"
if [[ -x "$MEMORY_SCRIPT" ]]; then
    OUTPUT_FORMAT="quiet" "$MEMORY_SCRIPT" smart "$TASK"
fi
```

### Python agents

```python
import subprocess
import os

def load_memory_context(task: str) -> str:
    script = os.path.expanduser("~/agent-memory/scripts/context-loader.sh")
    result = subprocess.run(
        [script, "smart", task],
        capture_output=True, text=True
    )
    return result.stdout

# Use before LLM call
context = load_memory_context("debug the authentication flow")
```

### REST API wrapper

```python
from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route('/memory/search')
def search():
    query = request.args.get('q', '')
    result = subprocess.run(
        ["~/agent-memory/scripts/semantic-search.sh", "search", query],
        capture_output=True, text=True, shell=True
    )
    return result.stdout

@app.route('/memory/load')
def load():
    task = request.args.get('task', '')
    level = request.args.get('level', 'standard')
    result = subprocess.run(
        ["~/agent-memory/scripts/context-loader.sh", level, task],
        capture_output=True, text=True, shell=True
    )
    return result.stdout
```

## Memory Levels

| Level | Size | When to Use |
|-------|------|-------------|
| minimal | ~2KB | Emergency, high token usage |
| compact | ~5KB | Subagents, quick tasks, group chats |
| standard | ~10KB | Main sessions, routine tasks |
| full | ~20KB | Complex planning, explicit request |

## Key Scripts

| Script | Purpose |
|--------|---------|
| `context-loader.sh` | Main entry point for loading memory |
| `semantic-search.sh` | ChromaDB-powered semantic search |
| `generate-compact-context.sh` | Compress memory to ~3KB |
| `summarize-session.sh` | Compress old session logs |
| `memory-maintenance.sh` | Daily maintenance (embeddings, cleanup) |

## Directory Structure

```
~/agent-memory/
├── memory/
│   ├── profiles/        # USER.md, AGENT.md, MODELS.md
│   ├── core/            # CORE.md, RULES.md
│   ├── knowledge/       # LEARNINGS.md, PROJECTS.md, INDEX.md
│   ├── sessions/
│   │   ├── daily/       # YYYY-MM-DD.md session logs
│   │   └── archive/     # Old sessions
│   ├── cache/
│   │   ├── chroma/      # Vector embeddings database
│   │   └── CONTEXT_COMPACT.md  # Compressed context
│   └── config/          # memory-config.json
├── scripts/             # All executable scripts
├── venv/                # Python virtual environment
└── install.sh           # Installer
```

## Customization

### Adding New Memories

1. **Daily logs**: Create `memory/sessions/daily/YYYY-MM-DD.md`
2. **Learnings**: Add to `memory/knowledge/LEARNINGS.md`
3. **Projects**: Update `memory/knowledge/PROJECTS.md`
4. **Then update embeddings**: `semantic-search.sh embed`

### Changing Context Levels

Edit `memory/config/memory-config.json` to customize:
- Token thresholds for each level
- Which files to load per task type
- Embedding model settings

## Troubleshooting

### Embeddings not working
```bash
# Reinitialize
~/agent-memory/scripts/semantic-search.sh clear
~/agent-memory/scripts/semantic-search.sh init
```

### Context too large
```bash
# Regenerate compact context
~/agent-memory/scripts/generate-compact-context.sh generate

# Use minimal level
~/agent-memory/scripts/context-loader.sh minimal
```

### Python dependencies missing
```bash
source ~/agent-memory/venv/bin/activate
pip install chromadb sentence-transformers
```

## See Also

- [QUICK_START.md](docs/QUICK_START.md) - Detailed setup guide
- [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) - Full customization options
- [API.md](docs/API.md) - Complete script documentation
- [INTEGRATION.md](docs/INTEGRATION.md) - More integration patterns
