# Dev Container Dockerfile
# Based on Python 3.11 with Node.js 22

FROM mcr.microsoft.com/devcontainers/python:3.11

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    ripgrep \
    ffmpeg \
    jq \
    htop \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH for all users
RUN ln -sf /root/.local/bin/uv /usr/local/bin/uv

# Install global npm packages
RUN npm install -g \
    @railway/cli \
    @anthropic-ai/claude-code \
    typescript \
    ts-node

# Create vscode user directories
RUN mkdir -p /home/vscode/.hermes /home/vscode/.openclaw /workspace && \
    chown -R vscode:vscode /home/vscode

# Set environment variables
ENV HERMES_CONFIG_DIR=/home/vscode/.hermes
ENV OPENCLAW_CONFIG_DIR=/home/vscode/.openclaw
ENV PATH="/home/vscode/.local/bin:$PATH"

# Default working directory
WORKDIR /workspace

# Switch to vscode user
USER vscode
