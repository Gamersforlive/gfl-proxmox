#!/usr/bin/env bash
# GFL Proxmox Scripts - Homepage installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the Homepage stack"
mkdir -p /opt/homepage/config
cat >/opt/homepage/compose.yaml <<'YAML'
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    restart: unless-stopped
    environment:
      # Accept any address in the browser bar (IP, hostname or a domain via a proxy).
      - HOMEPAGE_ALLOWED_HOSTS=*
    ports:
      - "3000:3000"
    volumes:
      - ./config:/app/config
YAML
msg_ok "Wrote /opt/homepage/compose.yaml"
compose_up homepage

motd_ssh
customize
cleanup_lxc
