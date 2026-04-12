#!/bin/bash
# Post-Create Command for Dev Container
# Runs once after container is created

set -e

echo "🚀 Setting up Personal Assistant Dev Container..."

# Create necessary directories
mkdir -p /home/vscode/.hermes/{cron,sessions,logs,memories,skills,pairing,hooks,image_cache,audio_cache,whatsapp/session}
mkdir -p /home/vscode/.openclaw
mkdir -p /workspace

# Install uv (Python package manager)
if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="/home/vscode/.local/bin:$PATH"
fi

# Install global tools
echo "🔧 Installing global tools..."
npm install -g @railway/cli

# Set up git (if not already configured)
if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "Developer"
fi
if [ -z "$(git config --global user.email)" ]; then
    git config --global user.email "dev@example.com"
fi

# Copy example env files if .env doesn't exist
if [ ! -f /workspace/.env ]; then
    if [ -f /workspace/.env.hermes.example ]; then
        echo "📝 Creating .env from .env.hermes.example..."
        cp /workspace/.env.hermes.example /workspace/.env
        echo "⚠️  Please edit /workspace/.env and add your API keys"
    fi
fi

# Ensure correct permissions
sudo chown -R vscode:vscode /home/vscode/.hermes
sudo chown -R vscode:vscode /home/vscode/.openclaw
sudo chown -R vscode:vscode /workspace

echo "✅ Dev container setup complete!"
echo ""
echo "Quick Start:"
echo "  1. Edit /workspace/.env with your API keys"
echo "  2. Run 'docker compose --profile hermes up -d' to start Hermes"
echo "  3. Or run 'docker compose --profile openclaw up -d' for OpenClaw"
echo ""
echo "Documentation: /workspace/RAILWAY_HERMES.md"
