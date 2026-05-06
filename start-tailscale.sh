#!/bin/sh
set -e

# Ensure persistent Tailscale state directory exists
mkdir -p /data/tailscale
chown -R openclaw:openclaw /data/tailscale

# Start tailscaled in userspace mode with persistent state
/tailscale.d/tailscaled \
  --state=/data/tailscale/tailscaled.state \
  --socket=/var/run/tailscale/tailscaled.sock \
  --tun=userspace-networking \
  --socks5-server=localhost:1055 \
  --outbound-http-proxy-listen=localhost:1055 &

# Wait for tailscaled to be ready
until /tailscale.d/tailscale up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${TAILSCALE_HOSTNAME}" \
  ${TAILSCALE_ADDITIONAL_ARGS}
do
  sleep 0.2
done
