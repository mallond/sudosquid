#!/usr/bin/env bash
set -euo pipefail

# Start services
docker compose up -d --build

# Pull model into Ollama (idempotent)
./pull-model.sh

echo
echo "=== OpenClaw models ==="
docker exec -it openclaw openclaw models list || true

echo
echo "OpenClaw Gateway should be on: http://localhost:18789"
