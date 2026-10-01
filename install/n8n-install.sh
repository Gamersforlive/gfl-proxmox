#!/usr/bin/env bash
# GFL Proxmox Scripts - n8n installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the n8n stack"
mkdir -p /opt/n8n/data
# The image runs as the "node" user (uid 1000).
chown -R 1000:1000 /opt/n8n/data
TZNAME=$(cat /etc/timezone 2>/dev/null || echo Etc/UTC)
cat >/opt/n8n/compose.yaml <<YAML
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    environment:
      - GENERIC_TIMEZONE=${TZNAME}
      - TZ=${TZNAME}
      # Allows logging in over plain http on your LAN. Remove it once n8n is behind HTTPS.
      - N8N_SECURE_COOKIE=false
    ports:
      - "5678:5678"
    volumes:
      - ./data:/home/node/.n8n
YAML
msg_ok "Wrote /opt/n8n/compose.yaml"
compose_up n8n

motd_ssh
customize
cleanup_lxc
