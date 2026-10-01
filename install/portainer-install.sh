#!/usr/bin/env bash
# GFL Proxmox Scripts - Portainer installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the Portainer stack"
mkdir -p /opt/portainer
cat >/opt/portainer/compose.yaml <<'YAML'
services:
  portainer:
    image: portainer/portainer-ce:lts
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9443:9443"
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data:/data
YAML
msg_ok "Wrote /opt/portainer/compose.yaml"
compose_up portainer

motd_ssh
customize
cleanup_lxc
