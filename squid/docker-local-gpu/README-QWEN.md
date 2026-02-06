Yep — here’s the exact Ollama “fetch & go” setup we used for **Qwen3 8B**:

* **Model tag:** `qwen3:8b`
* **Where it ends up:** inside the container at `/root/.ollama` (persisted via your `ollama` named volume)
* **Host/API:** `http://127.0.0.1:11434` (your container is published as `127.0.0.1:11434->11434`)

### Fetch (pull) the model

```bash
docker exec -it ollama ollama pull qwen3:8b
```

### Run quick interactive test

```bash
docker exec -it ollama ollama run qwen3:8b
```

### Non-interactive test via API (native)

```bash
curl -s http://127.0.0.1:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3:8b","messages":[{"role":"user","content":"hello"}],"stream":false}'
```

### Confirm it’s installed

```bash
curl -s http://127.0.0.1:11434/api/tags | jq .
```

And in your CLI wrapper, the key default you set was:

```bash
HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
MODEL="qwen3:8b"
```
