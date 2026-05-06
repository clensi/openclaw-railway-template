FROM node:22-bookworm

# Install system dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gosu \
    procps \
    python3 \
    python3-venv \
    python3-requests \
    build-essential \
    zip \
    iptables \
    iproute2 \
  && rm -rf /var/lib/apt/lists/*

# -------------------------
# Install Caddy (TLS termination)
# -------------------------
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | tee /etc/apt/trusted.gpg.d/caddy.asc \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy.list \
  && apt-get update \
  && apt-get install -y caddy

# -------------------------
# Install Tailscale
# -------------------------
WORKDIR /tailscale.d
COPY start-tailscale.sh /tailscale.d/start-tailscale.sh

ENV TAILSCALE_VERSION="latest"
ENV TAILSCALE_HOSTNAME="railway-openclaw"
ENV TAILSCALE_ADDITIONAL_ARGS=""

RUN curl -fsSL https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_amd64.tgz \
      -o tailscale.tgz \
  && tar xzf tailscale.tgz --strip-components=1 \
  && rm tailscale.tgz \
  && mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale \
  && chmod +x /tailscale.d/start-tailscale.sh \
  && ln -s /tailscale.d/tailscale /usr/local/bin/tailscale \
  && ln -s /tailscale.d/tailscaled /usr/local/bin/tailscaled

# -------------------------
# Install OpenClaw + Clawhub
# -------------------------
RUN npm install -g openclaw@2026.4.23 clawhub@latest

WORKDIR /app

# Install Node dependencies
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile --prod

# Copy application code
COPY src ./src
COPY --chmod=755 entrypoint.sh ./entrypoint.sh
COPY Caddyfile /etc/caddy/Caddyfile

# Create non-root user
RUN useradd -m -s /bin/bash openclaw \
  && chown -R openclaw:openclaw /app \
  && mkdir -p /data && chown openclaw:openclaw /data

USER openclaw

ENV PORT=8080
ENV OPENCLAW_ENTRY=/usr/local/lib/node_modules/openclaw/dist/entry.js

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -f http://localhost:8080/setup/healthz || exit 1

USER root
ENTRYPOINT ["./entrypoint.sh"]
