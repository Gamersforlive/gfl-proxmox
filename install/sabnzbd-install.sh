#!/usr/bin/env bash
# GFL Proxmox Scripts - SABnzbd installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

prep_media_dirs /data /data/downloads /data/downloads/usenet /data/downloads/usenet/complete /data/downloads/usenet/incomplete
msg_info "Writing the SABnzbd stack"
mkdir -p /opt/sabnzbd/config
cat >/opt/sabnzbd/compose.yaml <<'YAML'
services:
  sabnzbd:
    image: lscr.io/linuxserver/sabnzbd:latest
    container_name: sabnzbd
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    ports:
      - "8080:8080"
    volumes:
      - ./config:/config
      - /data:/data
YAML
msg_ok "Wrote /opt/sabnzbd/compose.yaml"
docker_app sabnzbd

motd_ssh
customize
cleanup_lxc
