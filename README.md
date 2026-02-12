# SOTA Agent Memory System

[![GitHub stars](https://img.shields.io/github/stars/Xzeroone/agent-memory-system?style=social)](https://github.com/Xzeroone/agent-memory-system/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> A production-grade memory system for AI agents with semantic search (ChromaDB), task-aware context loading, and 80% token compression.

## Why This Matters

AI agents forget everything between sessions. Every conversation starts from zero. This system fixes that:

- **No more re-explaining context** - Your agent remembers previous work
- **80% token savings** - Compressed context means lower API costs
- **Semantic recall** - Find memories by meaning, not keywords
- **Works with any agent** - Bash, Python, LangChain, AutoGPT, CrewAI...

**One-line install. No database setup. Zero config to start.**

## What It Does

- **Semantic Search**: Find relevant memories by meaning, not just keywords (powered by ChromaDB + sentence-transformers)
- **Task-aware Loading**: Context level (minimal/compact/standard/full) auto-selected based on task type and token budget
- **Memory Compression**: Auto-generated compact context saves ~80% tokens
- **Cross-session Persistence**: Memories persist across sessions in structured markdown files
- **Single Source Files**: No duplication - profiles stored once, referenced everywhere

## Comparison

| Feature | This System | LangChain Memory | Mem0 | Plain RAG |
|---------|-------------|------------------|------|-----------|
| Token compression | ✅ 80% | ❌ | ❌ | ❌ |
| Task-aware loading | ✅ Auto | ❌ | ❌ | ❌ |
| No external DB required | ✅ | ❌ | ❌ | Varies |
| Works offline | ✅ | Varies | ❌ | Varies |
| Human-readable format | ✅ Markdown | ❌ JSON | ❌ | Varies |
| Setup complexity | 1 command | Medium | Medium | High |

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
