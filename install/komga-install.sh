#!/usr/bin/env bash
# GFL Proxmox Scripts - Komga installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

prep_media_dirs /data /data/media /data/media/comics
msg_info "Writing the Komga stack"
mkdir -p /opt/komga/config
chown -R 1000:1000 /opt/komga/config
cat >/opt/komga/compose.yaml <<'YAML'
services:
  komga:
    image: gotson/komga:latest
    container_name: komga
    user: "1000:1000"
    restart: unless-stopped
    environment:
      - TZ=Etc/UTC
    ports:
      - "25600:25600"
    volumes:
      - ./config:/config
      - /data/media:/data/media
YAML
msg_ok "Wrote /opt/komga/compose.yaml"
docker_app komga

motd_ssh
customize
cleanup_lxc
