#!/usr/bin/env bash
# GFL Proxmox Scripts - Seerr installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the Seerr stack"
mkdir -p /opt/seerr/config
# The image runs as the "node" user (uid 1000).
chown -R 1000:1000 /opt/seerr/config
cat >/opt/seerr/compose.yaml <<'YAML'
services:
  seerr:
    image: ghcr.io/seerr-team/seerr:latest
    container_name: seerr
    init: true
    restart: unless-stopped
    ports:
      - "5055:5055"
    volumes:
      - ./config:/app/config
YAML
msg_ok "Wrote /opt/seerr/compose.yaml"
compose_up seerr

motd_ssh
customize
cleanup_lxc
