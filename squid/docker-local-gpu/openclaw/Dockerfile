FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git openssh-client ca-certificates bash curl \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw@2026.2.9 \
    openclaw onboard --install-daemon

EXPOSE 18789

COPY ./openclaw.json /root/.openclaw/openclaw.json


