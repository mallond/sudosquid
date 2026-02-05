#!/usr/bin/env bash
set -euo pipefail

HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
MODEL="qwen3:8b"
STREAM="false"
RAW="false"

usage() {
  cat <<'USAGE'
qwen.sh - tiny Ollama chat CLI

Usage:
  ./qwen.sh "prompt"
  ./qwen.sh -s "prompt"          # streaming
  echo "prompt" | ./qwen.sh      # prompt from stdin

Options:
  -s, --stream                   Stream output
  -m, --model <name>             Model (default: qwen3:8b)
  -H, --host  <url>              Host (default: $OLLAMA_HOST or http://127.0.0.1:11434)
  -r, --raw                      Print raw JSON (debug)
  -h, --help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--stream) STREAM="true"; shift ;;
    -r|--raw) RAW="true"; shift ;;
    -m|--model) MODEL="${2:-}"; shift 2 ;;
    -H|--host) HOST="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) break ;;
  esac
done

PROMPT=""
if [[ $# -gt 0 ]]; then
  PROMPT="$*"
else
  if [ ! -t 0 ]; then
    PROMPT="$(cat)"
  fi
fi

if [[ -z "${PROMPT}" ]]; then
  echo "qwen.sh: empty prompt" >&2
  exit 1
fi

SYSTEM_PROMPT="Answer directly. No greeting. No emojis. No extra commentary. If asked for N items, output exactly N items."

PAYLOAD="$(jq -cn \
  --arg m "$MODEL" \
  --arg sys "$SYSTEM_PROMPT" \
  --arg p "$PROMPT" \
  --argjson s "$STREAM" \
  '{
    model:$m,
    messages:[
      {role:"system", content:$sys},
      {role:"user", content:$p}
    ],
    stream:$s
  }')"

if [[ "$STREAM" == "true" ]]; then
  if [[ "$RAW" == "true" ]]; then
    curl -sN "$HOST/api/chat" -H "Content-Type: application/json" -d "$PAYLOAD"
    exit 0
  fi

  # Stream: parse JSON lines safely, print content chunks without per-chunk newlines
  curl -sN "$HOST/api/chat" -H "Content-Type: application/json" -d "$PAYLOAD" \
    | jq -Rr --unbuffered '
        (fromjson? // empty)
        | if .error? then
            "ERROR: " + .error + "\n"
          else
            (.message.content? // .response? // "")
          end
      ' \
    | tr -d '\n'
  echo
else
  OUT="$(curl -sS --max-time 120 "$HOST/api/chat" -H "Content-Type: application/json" -d "$PAYLOAD" || true)"

  if [[ "$RAW" == "true" ]]; then
    if [[ -z "$OUT" ]]; then
      echo "ERROR: empty response from $HOST/api/chat" >&2
      exit 2
    fi
    echo "$OUT"
    exit 0
  fi

  if [[ -z "$OUT" ]]; then
    echo "ERROR: empty response from $HOST/api/chat" >&2
    exit 2
  fi

  echo "$OUT" | jq -r 'if .error? then "ERROR: "+.error else (.message.content? // .response? // empty) end'
fi
