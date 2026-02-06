#!/usr/bin/env bash
set -euo pipefail

echo "Pulling qwen3:8b into Ollama container..."
docker exec -it ollama ollama pull qwen3:8b

echo
echo "=== Ollama models ==="
docker exec -it ollama ollama list
