#!/usr/bin/env bash
# GFL Proxmox Scripts - Nginx Proxy Manager installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the Nginx Proxy Manager stack"
mkdir -p /opt/nginx-proxy-manager
cat >/opt/nginx-proxy-manager/compose.yaml <<'YAML'
services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
YAML
msg_ok "Wrote /opt/nginx-proxy-manager/compose.yaml"
compose_up nginx-proxy-manager

motd_ssh
customize
cleanup_lxc
