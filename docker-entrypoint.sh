#!/bin/bash
set -e

openclaw plugins install @ollama/openclaw-web-search --silent 2>/dev/null || true

exec varlock run -- openclaw "$@"
