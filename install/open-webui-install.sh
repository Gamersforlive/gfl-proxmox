#!/usr/bin/env bash
# GFL Proxmox Scripts - Open WebUI installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the Open WebUI stack"
mkdir -p /opt/open-webui
cat >/opt/open-webui/compose.yaml <<'YAML'
services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./data:/app/backend/data
YAML
msg_ok "Wrote /opt/open-webui/compose.yaml"
compose_up open-webui

motd_ssh
customize
cleanup_lxc
