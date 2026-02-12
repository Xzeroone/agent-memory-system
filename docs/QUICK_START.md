# Quick Start Guide

Get up and running with the SOTA Agent Memory System in 5 minutes.

## Prerequisites

- Linux or macOS
- Python 3.10+
- ~500MB disk space

## Installation

### Option 1: One Command

```bash
curl -sSL https://raw.githubusercontent.com/Xzeroone/agent-memory-system/main/install.sh | bash
```

### Option 2: Manual

```bash
git clone https://github.com/Xzeroone/agent-memory-system.git ~/agent-memory
cd ~/agent-memory
python3 -m venv venv
source venv/bin/activate
pip install chromadb sentence-transformers
chmod +x scripts/*.sh
```

## Initial Setup

1. **Edit your profile**
   ```bash
   nano ~/agent-memory/memory/profiles/USER.md
   ```
   Add your name, preferences, working style.

2. **Edit agent profile**
   ```bash
   nano ~/agent-memory/memory/profiles/AGENT.md
   ```
   Rename if needed, define agent persona.

3. **Initialize embeddings**
   ```bash
   ~/agent-memory/scripts/semantic-search.sh init
   ```

## Test It

```bash
# Search memories
~/agent-memory/scripts/semantic-search.sh search "user preferences"

# Load context
~/agent-memory/scripts/context-loader.sh smart "debug an error"

# Check status
~/agent-memory/scripts/context-loader.sh status
```

## Integrate with Your Agent

### Bash

```bash
# Add to your agent's run script
CONTEXT=$($HOME/agent-memory/scripts/context-loader.sh smart "$TASK")
```

### Python

```python
import subprocess

def load_context(task):
    result = subprocess.run(
        ["~/agent-memory/scripts/context-loader.sh", "smart", task],
        capture_output=True, text=True, shell=True
    )
    return result.stdout
```

## Daily Usage

### Adding Memories

Create a daily log:
```bash
nano ~/agent-memory/memory/sessions/daily/$(date +%Y-%m-%d).md
```

### Updating Embeddings

After editing memory files:
```bash
~/agent-memory/scripts/semantic-search.sh embed
```

## Troubleshooting

**Embeddings not working?**
```bash
~/agent-memory/scripts/semantic-search.sh clear
~/agent-memory/scripts/semantic-search.sh init
```

**Context too large?**
```bash
~/agent-memory/scripts/context-loader.sh minimal
```

## Next Steps

- [CUSTOMIZATION.md](CUSTOMIZATION.md) - Full customization options
- [API.md](API.md) - Complete script documentation
- [INTEGRATION.md](INTEGRATION.md) - More integration patterns
