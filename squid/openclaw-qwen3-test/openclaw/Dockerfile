
FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git openssh-client ca-certificates bash curl \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw@2026.2.3-1 pm2

ENV OPENCLAW_STATE_DIR=/data
ENV OPENCLAW_CONFIG_PATH=/data/openclaw.json
ENV HOME=/data

WORKDIR /data
EXPOSE 18789

COPY ecosystem.config.cjs /data/ecosystem.config.cjs

CMD ["pm2-runtime", "/data/ecosystem.config.cjs"]

