# Integration Guide

How to integrate the SOTA Memory System with different agents and platforms.

## Bash-based Agents

### OpenCode / OpenClaw

Add to your bridge script before task execution:

```bash
#!/bin/bash
# your-bridge.sh

MEMORY_SCRIPT="$HOME/agent-memory/scripts/context-loader.sh"

run_task() {
    local task="$1"
    
    # Load memory context
    if [[ -x "$MEMORY_SCRIPT" ]]; then
        OUTPUT_FORMAT="quiet" "$MEMORY_SCRIPT" smart "$task"
    fi
    
    # Execute task with your agent
    echo "$task" | your-agent-binary run
}

run_task "$@"
```

### Generic Bash Wrapper

```bash
#!/bin/bash
# memory-wrapper.sh

CONTEXT_LOADER="$HOME/agent-memory/scripts/context-loader.sh"
AGENT_CMD="your-agent-command"

main() {
    local task="$1"
    
    # Load context
    local context=""
    if [[ -x "$CONTEXT_LOADER" ]]; then
        context=$(OUTPUT_FORMAT=quiet "$CONTEXT_LOADER" smart "$task")
    fi
    
    # Run agent with context
    echo -e "$context\n\n$task" | $AGENT_CMD
}

main "$@"
```

## Python Agents

### Basic Integration

```python
import subprocess
import os

def load_memory_context(task: str, level: str = "smart") -> str:
    """Load memory context for a task."""
    script = os.path.expanduser("~/agent-memory/scripts/context-loader.sh")
    
    result = subprocess.run(
        [script, level, task],
        capture_output=True,
        text=True
    )
    
    return result.stdout

# Usage
context = load_memory_context("debug the authentication flow")
prompt = f"{context}\n\nUser request: {user_message}"
```

### Async Integration

```python
import asyncio
import os

async def load_memory_async(task: str) -> str:
    """Async memory loading."""
    script = os.path.expanduser("~/agent-memory/scripts/context-loader.sh")
    
    proc = await asyncio.create_subprocess_exec(
        script, "smart", task,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    
    stdout, _ = await proc.communicate()
    return stdout.decode()

# Usage
context = await load_memory_async("create a new feature")
```

### Semantic Search

```python
def search_memory(query: str, n: int = 5) -> list:
    """Search memories semantically."""
    script = os.path.expanduser("~/agent-memory/scripts/semantic-search.sh")
    
    result = subprocess.run(
        [script, "search", query],
        capture_output=True,
        text=True
    )
    
    # Parse output
    results = []
    current_file = None
    
    for line in result.stdout.split('\n'):
        if line.startswith('📄 '):
            current_file = {"file": line[2:], "chunks": []}
            results.append(current_file)
        elif current_file and line.strip():
            current_file["chunks"].append(line)
    
    return results[:n]
```

## REST API Wrapper

```python
from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)
SCRIPTS_DIR = os.path.expanduser("~/agent-memory/scripts")

@app.route('/memory/load', methods=['GET'])
def load_context():
    """Load memory context."""
    task = request.args.get('task', '')
    level = request.args.get('level', 'smart')
    
    result = subprocess.run(
        [f"{SCRIPTS_DIR}/context-loader.sh", level, task],
        capture_output=True, text=True
    )
    
    return jsonify({
        "context": result.stdout,
        "success": result.returncode == 0
    })

@app.route('/memory/search', methods=['GET'])
def search():
    """Semantic search."""
    query = request.args.get('q', '')
    
    result = subprocess.run(
        [f"{SCRIPTS_DIR}/semantic-search.sh", "search", query],
        capture_output=True, text=True
    )
    
    return jsonify({
        "results": result.stdout,
        "success": result.returncode == 0
    })

@app.route('/memory/status', methods=['GET'])
def status():
    """Get memory system status."""
    result = subprocess.run(
        [f"{SCRIPTS_DIR}/context-loader.sh", "status"],
        capture_output=True, text=True
    )
    
    return jsonify({
        "status": result.stdout,
        "success": result.returncode == 0
    })

if __name__ == '__main__':
    app.run(port=5000)
```

## Cron Integration

### Automatic Embedding Updates

```bash
# Edit crontab
crontab -e

# Add: Update embeddings every 6 hours
0 */6 * * * ~/agent-memory/scripts/semantic-search.sh embed >> /tmp/memory-cron.log 2>&1

# Add: Daily maintenance at midnight
0 0 * * * ~/agent-memory/scripts/maintenance.sh >> /tmp/memory-cron.log 2>&1
```

### Systemd Timer

```ini
# /etc/systemd/system/memory-update.timer
[Unit]
Description=Update memory embeddings

[Timer]
OnCalendar=*:0/6:00
Persistent=true

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/memory-update.service
[Unit]
Description=Update memory embeddings

[Service]
Type=oneshot
ExecStart=/home/user/agent-memory/scripts/semantic-search.sh embed
User=user
```

```bash
# Enable
systemctl enable memory-update.timer
systemctl start memory-update.timer
```

## Multi-Agent Setup

For systems with multiple agents, share memory:

```bash
# Shared memory location
SHARED_MEMORY="/opt/shared-agent-memory"

# Each agent sources from shared
ln -s $SHARED_MEMORY ~/agent1/memory
ln -s $SHARED_MEMORY ~/agent2/memory
```

Or use environment variable:

```bash
# In each agent's config
export MEMORY_DIR=/opt/shared-agent-memory
```

## IDE Integration

### VS Code

Create a task in `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Search Memory",
      "type": "shell",
      "command": "~/agent-memory/scripts/semantic-search.sh",
      "args": ["search", "${input:query}"],
      "problemMatcher": []
    }
  ],
  "inputs": [
    {
      "id": "query",
      "type": "promptString",
      "description": "Search query"
    }
  ]
}
```

### Neovim

```lua
-- Add to init.lua
vim.api.nvim_create_user_command('MemorySearch', function(opts)
  local query = opts.args
  local result = vim.fn.system(
    {'~/agent-memory/scripts/semantic-search.sh', 'search', query}
  )
  vim.notify(result, vim.log.levels.INFO)
end, { nargs = '*' })
```
