#!/usr/bin/env bash
# GFL Proxmox Scripts - Tdarr installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

prep_media_dirs /data /data/media
msg_info "Writing the Tdarr stack"
mkdir -p /opt/tdarr/{server,configs,logs,cache}
DEVICES=""
if [ -e /dev/dri ]; then DEVICES=$'    devices:\n      - /dev/dri:/dev/dri'; fi
cat >/opt/tdarr/compose.yaml <<YAML
services:
  tdarr:
    image: ghcr.io/haveagitgat/tdarr:latest
    container_name: tdarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - serverIP=0.0.0.0
      - serverPort=8266
      - webUIPort=8265
      - internalNode=true
      - inContainer=true
      - nodeName=gfl-node
    ports:
      - "8265:8265"
      - "8266:8266"
    volumes:
      - ./server:/app/server
      - ./configs:/app/configs
      - ./logs:/app/logs
      - ./cache:/temp
      - /data/media:/media
${DEVICES}
YAML
msg_ok "Wrote /opt/tdarr/compose.yaml"
docker_app tdarr

motd_ssh
customize
cleanup_lxc
