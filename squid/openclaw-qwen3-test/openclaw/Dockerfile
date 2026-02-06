FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install git (needed because one dependency is fetched via git),
# plus certs + ssh client (common for git+ssh or https)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git openssh-client ca-certificates bash curl \
 && rm -rf /var/lib/apt/lists/*

# Pin OpenClaw version for reproducible builds
RUN npm install -g openclaw@2026.2.3-1

# Persist OpenClaw state/config
ENV OPENCLAW_HOME=/data
WORKDIR /data

EXPOSE 18789

COPY start.sh /usr/local/bin/start-openclaw
RUN chmod +x /usr/local/bin/start-openclaw

CMD ["/usr/local/bin/start-openclaw"]
