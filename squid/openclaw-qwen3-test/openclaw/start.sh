#!/usr/bin/env bash
set -euo pipefail

: "${OPENCLAW_HOME:=/data}"
: "${OPENCLAW_PORT:=18789}"
: "${OPENCLAW_BIND:=lan}"
: "${OPENCLAW_VERBOSE:=--verbose}"

# Make OpenClaw use the config we generate (instead of ~/.openclaw/openclaw.json)
: "${OPENCLAW_STATE_DIR:=${OPENCLAW_HOME}}"
: "${OPENCLAW_CONFIG_PATH:=${OPENCLAW_HOME}/openclaw.json}"

mkdir -p "${OPENCLAW_HOME}"

# Seed config if missing (volume-friendly)
if [ ! -f "${OPENCLAW_CONFIG_PATH}" ]; then
  cat > "${OPENCLAW_CONFIG_PATH}" <<'JSON'
{
  "gateway": { "mode": "local", "port": 18789 },
  "agents":  { "defaults": { "model": { "primary": "ollama/qwen3:8b" } } }
}
JSON
fi

# If called with args, pass-through to OpenClaw (e.g., onboard)
if [ "${1:-}" != "" ]; then
  exec openclaw "$@"
fi

# Default: run gateway
exec openclaw gateway --bind "${OPENCLAW_BIND}" --port "${OPENCLAW_PORT}" ${OPENCLAW_VERBOSE}
