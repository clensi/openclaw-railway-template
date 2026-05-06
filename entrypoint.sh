#!/bin/bash
set -e

# Start Tailscale (optional)
 /tailscale.d/start-tailscale.sh &

# Start OpenClaw on port 8081
gosu openclaw node src/server.js --port 8081 &

# Start Caddy (TLS termination on 8080)
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
