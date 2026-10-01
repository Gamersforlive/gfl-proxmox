#!/usr/bin/env bash
# GFL Proxmox Scripts - Bazarr installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

prep_media_dirs /data /data/media
msg_info "Writing the Bazarr stack"
mkdir -p /opt/bazarr/config
cat >/opt/bazarr/compose.yaml <<'YAML'
services:
  bazarr:
    image: lscr.io/linuxserver/bazarr:latest
    container_name: bazarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    ports:
      - "6767:6767"
    volumes:
      - ./config:/config
      - /data:/data
YAML
msg_ok "Wrote /opt/bazarr/compose.yaml"
docker_app bazarr

motd_ssh
customize
cleanup_lxc
