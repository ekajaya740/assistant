# Personal Assistant

OpenClaw gateway. HTTP/WebSocket API server for AI agents with OpenAI-compatible endpoints.

## Prerequisites

- Docker

## Setup

```bash
cp .env.hermes.example .env
nano .env
docker compose up -d
```

Gateway runs on `http://localhost:18789`, WebSocket bridge on port `18790`.

## Configuration

`.env` provides all configuration via environment variables. Key variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENAI_API_KEY` | — | API key for your LLM provider |
| `OPENAI_BASE_URL` | `https://api.openai.com/v1` | OpenAI-compatible API URL |
| `OPENAI_MODEL` | `gpt-4o` | Model name |
| `OPENCLAW_GATEWAY_TOKEN` | — | Gateway authentication token |
| `OPENCLAW_ALLOW_INSECURE_PRIVATE_WS` | `false` | Allow insecure private WebSocket |
| `OLLAMA_API_KEY` | — | Ollama API key for web search |
| `OLLAMA_HOST` | `http://host.docker.internal:11434` | Ollama server URL (for local models) |

Restart after changing `.env`:

```bash
docker compose restart
```

## Web Search

The `@ollama/openclaw-web-search` plugin is installed automatically on container startup.

1. Get an Ollama API key at [ollama.com/settings/keys](https://ollama.com/settings/keys)
2. Add to `.env`:
   ```
   OLLAMA_API_KEY=your-key-here
   ```
3. Restart: `docker compose restart`

For local Ollama models, also set:
```
OLLAMA_HOST=http://host.docker.internal:11434
```

Alternatively, authenticate via the OpenClaw chat:
```
/websearch auth YOUR_OLLAMA_API_KEY
/websearch status
```

## Commands

```bash
docker compose up -d        # Start
docker compose down          # Stop
docker compose logs -f       # Follow logs
docker compose restart       # Restart
docker compose down -v       # Stop and remove volumes
```

## Project Structure

```
.
├── compose.yml              # Docker Compose
├── Dockerfile               # OpenClaw + varlock image
├── Dockerfile.railway       # Railway variant
├── railway.toml             # Railway config
├── .env                     # Secrets (git-ignored)
├── .env.schema              # Varlock schema
├── .env.hermes.example      # Environment template
└── config/                  # OpenClaw config (mounted to container)
    └── .openclaw/           # Runtime config directory
        └── workspace/       # Agent workspace
```

## Resources

- [OpenClaw GitHub](https://github.com/openclaw)
- [Varlock](https://varlock.dev)
