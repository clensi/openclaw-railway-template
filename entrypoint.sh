#!/bin/bash
set -e

# Ensure /data permissions
chown -R openclaw:openclaw /data
chmod 700 /data

# No Homebrew manipulation — REMOVE ALL OF THIS
# rm -rf /home/linuxbrew/.linuxbrew
# ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js
