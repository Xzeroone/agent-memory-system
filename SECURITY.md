# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please report it privately:

- Open a [Security Advisory](https://github.com/Xzeroone/agent-memory-system/security/advisories/new)
- Or email: security@example.com (replace with actual email)

Please do not open a public issue for security vulnerabilities.

## Supported Versions

| Version | Supported |
| ------- | --------- |
| main    | ✅        |

## Security Considerations

- **Local storage**: All memory data is stored locally on your machine
- **No network calls**: The system works entirely offline after initial setup
- **Embedding model**: Downloaded from Hugging Face during installation
- **No telemetry**: We don't collect or send any data

## Best Practices

1. Review `memory/profiles/` before adding sensitive information
2. Use environment variables for secrets, don't store in memory files
3. Run `memory-maintenance.sh` regularly to clean up old sessions
