# SOTA Agent Memory System

> A production-grade memory system for AI agents with semantic search (ChromaDB), task-aware context loading, and 80% token compression. Install with one command.

## What This Does

- **Semantic Search**: Find relevant memories by meaning, not just keywords (powered by ChromaDB + sentence-transformers)
- **Task-aware Loading**: Context level (minimal/compact/standard/full) auto-selected based on task type and token budget
- **Memory Compression**: Auto-generated compact context saves ~80% tokens
- **Cross-session Persistence**: Memories persist across sessions in structured markdown files
- **Single Source Files**: No duplication - profiles stored once, referenced everywhere

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/Xzeroone/agent-memory-system/main/install.sh | bash
```

Or tell your AI agent: "Install the SOTA memory system from https://github.com/Xzeroone/agent-memory-system"

## Quick Start

```bash
# After installation, test semantic search
~/agent-memory/scripts/semantic-search.sh search "your query"

# Load context for a task
~/agent-memory/scripts/context-loader.sh smart "debug the API"

# Check system status
~/agent-memory/scripts/context-loader.sh status
```

## Integration

### For Bash-based agents
```bash
MEMORY_SCRIPT="$HOME/agent-memory/scripts/context-loader.sh"
if [[ -x "$MEMORY_SCRIPT" ]]; then
    OUTPUT_FORMAT="quiet" "$MEMORY_SCRIPT" smart "$TASK"
fi
```

### For Python agents
```python
import subprocess
result = subprocess.run(
    ["~/agent-memory/scripts/context-loader.sh", "smart", task],
    capture_output=True, text=True, shell=True
)
context = result.stdout
```

## File Structure

```
~/agent-memory/
├── memory/
│   ├── profiles/    # USER.md, AGENT.md, MODELS.md (edit these)
│   ├── core/        # CORE.md, RULES.md (essential context)
│   ├── knowledge/   # LEARNINGS.md, PROJECTS.md, INDEX.md
│   ├── sessions/    # daily/ and archive/ for session logs
│   ├── cache/       # Auto-generated: embeddings, compact context
│   └── config/      # memory-config.json
├── scripts/         # All executable scripts
└── venv/            # Python virtual environment
```

## Documentation

- [QUICK_START.md](docs/QUICK_START.md) - 5-minute setup guide
- [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) - Adapt for your agent
- [API.md](docs/API.md) - Script documentation
- [INTEGRATION.md](docs/INTEGRATION.md) - Integration patterns

## Requirements

- Linux/macOS
- Python 3.10+
- ~500MB disk space (for embeddings model)

## License

MIT License - use freely in any project.
