# OpenClaw + Ollama (Qwen3 8B) — Test Bundle

This bundle starts:
- **Ollama** in Docker (GPU enabled)
- **OpenClaw Gateway** in Docker, configured to use **`ollama/qwen3:8b`**

## Prereqs
- Docker Desktop / Docker Engine with `docker compose`
- NVIDIA GPU + Container Toolkit if you want GPU acceleration (`gpus: all`)

## Quick start (fully automated)

1) Copy `.env.example` to `.env` and (optionally) set `OPENCLAW_GATEWAY_TOKEN`.

2) Run:

```bash
./up.sh
```

What it does:
- builds & starts containers
- pulls `qwen3:8b` into the Ollama container
- prints a quick status and model list

## Useful commands

- Pull model only:
  ```bash
  ./pull-model.sh
  ```

- Show logs:
  ```bash
  ./logs.sh
  ```

- Stop & remove containers:
  ```bash
  ./down.sh
  ```

## Notes
- Containers talk over the compose network, so OpenClaw reaches Ollama at `http://ollama:11434`.
- OpenClaw config is persisted in the `openclaw-home` volume mounted at `/data`.
