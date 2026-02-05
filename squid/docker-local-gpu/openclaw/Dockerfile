FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install git (needed because one dependency is fetched via git),
# plus certs + ssh client (common for git+ssh or https)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git openssh-client ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g openclaw@latest

# Persist OpenClaw state/config
ENV OPENCLAW_HOME=/data
WORKDIR /data

EXPOSE 18789

CMD ["bash", "-lc", "\
  mkdir -p /data && \
  if [ ! -f /data/openclaw.json ]; then \
    cat > /data/openclaw.json <<'JSON'\n\
{\n\
  \"gateway\": {\n\
    \"mode\": \"local\",\n\
    \"port\": 18789\n\
  }\n\
}\n\
JSON\n\
  fi && \
  openclaw gateway --port 18789 --verbose \
"]
