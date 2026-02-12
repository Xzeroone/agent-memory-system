# Customization Guide

Adapt the SOTA Memory System for your specific needs.

## Profile Customization

### USER.md

Edit `memory/profiles/USER.md` with your information:

```markdown
## Basic Info
**Name:** Your Name
**Pronouns:** your/pronouns
**Timezone:** UTC-5

## Working Style
- Prefers brief responses
- Action-oriented
- Likes code examples

## Current Focus
- Building a new project
- Learning a new technology
```

### AGENT.md

Rename to match your agent (e.g., `CLAUDE.md`, `GPT.md`):

```markdown
## Basic Info
**Name:** Your Agent
**Specialty:** What it's best at

## Communication Style
- Code-heavy
- Concise
- Practical examples

## Philosophy
1. Principle one
2. Principle two
```

### MODELS.md

Configure for your model provider:

```markdown
## Available Models
| Model | Provider | Use Case |
|-------|----------|----------|
| claude-3-sonnet | anthropic | Primary |
| gpt-4 | openai | Complex tasks |

## Routing Strategy
**Primary:** claude-3-sonnet (90%)
**Flagship:** gpt-4 (9%)
```

## Memory Levels

Edit `memory/config/memory-config.json`:

```json
{
  "context_levels": {
    "minimal": {
      "size_kb": 2,
      "files": ["core/CORE.md", "core/RULES.md"]
    },
    "compact": {
      "size_kb": 5,
      "files": ["cache/CONTEXT_COMPACT.md"]
    },
    "standard": {
      "size_kb": 10,
      "files": ["core/CORE.md", "profiles/USER.md"]
    }
  }
}
```

## Adding New Memory Types

1. Create file in appropriate directory:
   - `memory/profiles/` for entity profiles
   - `memory/knowledge/` for reference info
   - `memory/sessions/daily/` for logs

2. Update embeddings:
   ```bash
   semantic-search.sh embed
   ```

3. Optionally update `knowledge/INDEX.md` with tags.

## Embedding Settings

Edit `memory/config/memory-config.json`:

```json
{
  "embeddings": {
    "model": "all-MiniLM-L6-v2",
    "chunk_size": 500,
    "update_interval_hours": 6
  }
}
```

### Alternative Models

To use a different embedding model, edit `scripts/memory-embeddings.py`:

```python
# Change this line:
_model = SentenceTransformer('all-MiniLM-L6-v2')

# To a different model:
_model = SentenceTransformer('all-mpnet-base-v2')  # Better quality, larger
```

## Compression Settings

```json
{
  "compression": {
    "enabled": true,
    "daily_summary": true,
    "archive_after_days": 7
  }
}
```

## Session Detection

For automatic session type detection, set environment variable:

```bash
export AGENT_USER_ID="your_user_id"
```

Or edit `scripts/context-loader.sh` to customize detection logic.

## Cron Jobs

Set up automatic maintenance:

```bash
# Edit crontab
crontab -e

# Add lines:
0 */6 * * * ~/agent-memory/scripts/semantic-search.sh embed
0 0 * * * ~/agent-memory/scripts/maintenance.sh
```
