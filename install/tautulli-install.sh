#!/usr/bin/env bash
# GFL Proxmox Scripts - Tautulli installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Tautulli stack"
mkdir -p /opt/tautulli/config
cat >/opt/tautulli/compose.yaml <<'YAML'
services:
  tautulli:
    image: ghcr.io/tautulli/tautulli:latest
    container_name: tautulli
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    ports:
      - "8181:8181"
    volumes:
      - ./config:/config
YAML
chown -R 1000:1000 /opt/tautulli/config
msg_ok "Wrote /opt/tautulli/compose.yaml"
docker_app tautulli

motd_ssh
customize
cleanup_lxc
