FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates bash \
 && rm -rf /var/lib/apt/lists/*

CMD ["bash", "-lc", "nvidia-smi && echo 'GPU visible inside container ✅'"]

