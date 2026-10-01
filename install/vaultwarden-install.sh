#!/usr/bin/env bash
# GFL Proxmox Scripts - Vaultwarden installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the Vaultwarden stack"
mkdir -p /opt/vaultwarden
cat >/opt/vaultwarden/compose.yaml <<'YAML'
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    environment:
      - SIGNUPS_ALLOWED=true
    ports:
      - "8000:80"
    volumes:
      - ./data:/data
YAML
msg_ok "Wrote /opt/vaultwarden/compose.yaml"
compose_up vaultwarden

motd_ssh
customize
cleanup_lxc
