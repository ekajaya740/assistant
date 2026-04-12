#!/bin/bash
# Post-Start Command for Dev Container
# Runs every time the container starts

set -e

echo "🔍 Checking services..."

# Check if Hermes config exists, if not create it
if [ ! -f /home/vscode/.hermes/config.yaml ]; then
    if [ -f /workspace/hermes-config.yaml ]; then
        echo "📋 Copying Hermes config..."
        cp /workspace/hermes-config.yaml /home/vscode/.hermes/config.yaml
    fi
fi

# Ensure directories exist
mkdir -p /home/vscode/.hermes/{cron,sessions,logs,memories,skills,pairing,hooks,image_cache,audio_cache,whatsapp/session}
mkdir -p /home/vscode/.openclaw

# Fix permissions
sudo chown -R vscode:vscode /home/vscode/.hermes
sudo chown -R vscode:vscode /home/vscode/.openclaw

echo "✅ Dev container ready!"
