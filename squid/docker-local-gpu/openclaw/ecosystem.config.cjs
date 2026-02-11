module.exports = {
  apps: [
{
  name: "keepalive",
  script: "/data/dummy.js",   // create this tiny file next to ecosystem.config.js
  exec_mode: "fork",
  autorestart: true
}
    
  ]
};

