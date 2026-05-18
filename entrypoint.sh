#!/bin/bash
set -e
chown -R 1001:1001 /data/.openclaw/ 2>/dev/null || true
exec gosu openclaw node src/server.js
