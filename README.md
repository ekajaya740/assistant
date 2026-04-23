# Personal Assistant

Hermes Agent gateway. AI agent with cross-session memory, 70+ built-in skills, and messaging platform integrations.

## Prerequisites

- Docker

## Setup

```bash
cp .env.hermes.example .env
nano .env
docker compose up -d
```

Gateway runs on `http://localhost:8642`, Dashboard on `http://localhost:9119`.

## Configuration

`.env` provides all configuration via environment variables. Key variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_API_KEY` | — | Ollama Cloud API key |
| `OLLAMA_BASE_URL` | `https://ollama.com/v1` | Ollama API base URL |
| `HERMES_INFERENCE_PROVIDER` | `ollama-cloud` | Inference provider |
| `HERMES_MODEL` | `kimi-k2.5:cloud` | Default AI model |
| `TELEGRAM_BOT_TOKEN` | — | Telegram bot token (optional) |
| `DISCORD_BOT_TOKEN` | — | Discord bot token (optional) |
| `SLACK_BOT_TOKEN` | — | Slack bot token (optional) |
| `OPENROUTER_API_KEY` | — | OpenRouter API key (optional backup) |

Restart after changing `.env`:

```bash
docker compose restart
```

## Messaging Platforms

Connect Telegram, Discord, or Slack to chat with your agent from anywhere.

1. Get your bot token from the platform
2. Add to `.env`:
   ```
   TELEGRAM_BOT_TOKEN=your-telegram-token
   TELEGRAM_ALLOWED_USERS=your-user-id
   ```
3. Restart: `docker compose restart`

## Commands

```bash
docker compose up -d         # Start
docker compose down          # Stop
docker compose logs -f       # Follow logs
docker compose restart       # Restart
docker compose down -v       # Stop and remove volumes
```

## Project Structure

```
.
├── compose.yml              # Docker Compose (hermes-gateway + hermes-dashboard)
├── Dockerfile               # Hermes base image
├── Dockerfile.railway       # Railway variant
├── railway.toml             # Railway config
├── .env                     # Secrets (git-ignored)
├── .env.hermes.example      # Environment template
└── hermes-data/             # Hermes persistent data (mount point)
    ├── config.yaml          # Agent configuration
    ├── sessions/            # Conversation history
    ├── memories/            # Persistent memory
    ├── skills/              # Installed skills
    ├── cron/                # Scheduled jobs
    └── logs/                # Runtime logs
```

## Resources

- [Hermes Agent Docs](https://hermes-agent.nousresearch.com)
- [Ollama Models](https://ollama.com/search)
