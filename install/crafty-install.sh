#!/usr/bin/env bash
# GFL Proxmox Scripts - Crafty Controller installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Crafty Controller stack"
mkdir -p /opt/crafty/{backups,logs,servers,config,import}
cat >/opt/crafty/compose.yaml <<'YAML'
services:
  crafty:
    image: registry.gitlab.com/crafty-controller/crafty-4:latest
    container_name: crafty
    restart: unless-stopped
    environment:
      - TZ=Etc/UTC
    ports:
      - "8443:8443"
      - "8123:8123"
      - "19132:19132/udp"
      - "25500-25600:25500-25600"
    volumes:
      - ./backups:/crafty/backups
      - ./logs:/crafty/logs
      - ./servers:/crafty/servers
      - ./config:/crafty/app/config
      - ./import:/crafty/import
YAML
msg_ok "Wrote /opt/crafty/compose.yaml"
docker_app crafty

motd_ssh
customize
cleanup_lxc
