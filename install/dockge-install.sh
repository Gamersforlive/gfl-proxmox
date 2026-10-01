#!/usr/bin/env bash
# GFL Proxmox Scripts - Dockge installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the Dockge stack"
mkdir -p /opt/dockge /opt/stacks
cat >/opt/dockge/compose.yaml <<'YAML'
services:
  dockge:
    image: louislam/dockge:1
    container_name: dockge
    restart: unless-stopped
    ports:
      - "5001:5001"
    environment:
      - DOCKGE_STACKS_DIR=/opt/stacks
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data:/app/data
      - /opt/stacks:/opt/stacks
YAML
msg_ok "Wrote /opt/dockge/compose.yaml"
compose_up dockge

motd_ssh
customize
cleanup_lxc
