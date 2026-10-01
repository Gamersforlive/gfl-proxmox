#!/usr/bin/env bash
# GFL Proxmox Scripts - Calibre-Web installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

prep_media_dirs /data /data/media /data/media/books
msg_info "Writing the Calibre-Web stack"
mkdir -p /opt/calibre-web/config
cat >/opt/calibre-web/compose.yaml <<'YAML'
services:
  calibre-web:
    image: lscr.io/linuxserver/calibre-web:latest
    container_name: calibre-web
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      # Adds Calibre's ebook converter (needed to convert formats and send to Kindle).
      - DOCKER_MODS=linuxserver/mods:universal-calibre
    ports:
      - "8083:8083"
    volumes:
      - ./config:/config
      - /data/media/books:/books
YAML
msg_ok "Wrote /opt/calibre-web/compose.yaml"
docker_app calibre-web

motd_ssh
customize
cleanup_lxc
