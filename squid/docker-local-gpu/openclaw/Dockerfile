FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git openssh-client ca-certificates bash curl \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw@2026.2.9 pm2

EXPOSE 18789

COPY ./config/openclaw.json /root/.openclaw/openclaw.json
COPY ecosystem.config.cjs ecosystem.config.cjs
COPY dummy.js dummy.js

CMD ["pm2-runtime", "/data/ecosystem.config.cjs"]
