#!/usr/bin/env bash
# GFL Proxmox Scripts - Zigbee2MQTT installer. Runs inside the new container.
# Starts in onboarding mode: pick your adapter and MQTT broker in the web page.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Zigbee2MQTT stack"
mkdir -p /opt/zigbee2mqtt/data
DEVICES=""
for d in /dev/serial/by-id/* /dev/ttyUSB0 /dev/ttyACM0; do
  if [ -e "$d" ]; then DEVICES=$'    devices:\n'"      - ${d}:${d}"; break; fi
done
cat >/opt/zigbee2mqtt/compose.yaml <<YAML
services:
  zigbee2mqtt:
    image: koenkk/zigbee2mqtt:latest
    container_name: zigbee2mqtt
    restart: unless-stopped
    environment:
      - TZ=Etc/UTC
    ports:
      - "8080:8080"
    volumes:
      - ./data:/app/data
      - /run/udev:/run/udev:ro
${DEVICES}
YAML
msg_ok "Wrote /opt/zigbee2mqtt/compose.yaml"
docker_app zigbee2mqtt

motd_ssh
customize
cleanup_lxc
