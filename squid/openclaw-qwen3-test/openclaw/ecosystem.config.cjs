module.exports = {
  apps: [
    {
      name: "openclaw-gateway",
      script: "/usr/local/bin/openclaw",
      args: "gateway --bind lan --port 18789 --verbose",
      exec_mode: "fork",
      autorestart: true,
      max_restarts: 10,
      restart_delay: 1000,
      env: {
        OPENCLAW_STATE_DIR: "/data",
        OPENCLAW_CONFIG_PATH: "/data/openclaw.json",
        HOME: "/data"
      }
    }
  ]
};

