#!/usr/bin/env bash
# GFL Proxmox Scripts - Home Assistant (container) installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Home Assistant stack"
mkdir -p /opt/home-assistant/config
cat >/opt/home-assistant/compose.yaml <<'YAML'
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: homeassistant
    restart: unless-stopped
    # Host networking lets Home Assistant discover devices on your network.
    network_mode: host
    privileged: true
    environment:
      - TZ=Etc/UTC
    volumes:
      - ./config:/config
      - /run/dbus:/run/dbus:ro
YAML
msg_ok "Wrote /opt/home-assistant/compose.yaml"
docker_app home-assistant

motd_ssh
customize
cleanup_lxc
