#!/usr/bin/env bash
set -euo pipefail

: "${OPENCLAW_HOME:=/data}"
: "${OPENCLAW_PORT:=18789}"
: "${OPENCLAW_BIND:=lan}"
: "${OPENCLAW_VERBOSE:=--verbose}"

mkdir -p "${OPENCLAW_HOME}"

# Only create config if it doesn't already exist (volume-friendly)
if [ ! -f "${OPENCLAW_HOME}/openclaw.json" ]; then
  cat > "${OPENCLAW_HOME}/openclaw.json" <<'JSON'
{
  "gateway": { "mode": "local", "port": 18789 },
  "agents":  { "defaults": { "model": { "primary": "ollama/qwen3:8b" } } }
}
JSON
fi

# Run gateway
exec openclaw gateway --bind "${OPENCLAW_BIND}" --port "${OPENCLAW_PORT}" ${OPENCLAW_VERBOSE}
