#!/bin/bash
set -e

# Ensure /data permissions
chown -R openclaw:openclaw /data
chmod 700 /data

# Start Tailscale (non-blocking)
/tailscale.d/start-tailscale.sh &

# Start your Node server as openclaw
exec gosu openclaw node src/server.js
