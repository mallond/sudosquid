docker build -t docker-gpu .
docker run --rm --gpus all docker-gpu

ollama qwen3

docker compose up -d

curl http://localhost:8000/v1/models


docker compose up -d --build


