#!/usr/bin/env bash
# GFL Proxmox Scripts - Frigate NVR installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Frigate stack"
mkdir -p /opt/frigate/config /data/frigate
# A starter config with a disabled example camera, so Frigate starts and you can add cameras in its UI.
cat >/opt/frigate/config/config.yml <<'YAML'
mqtt:
  enabled: false
cameras:
  example:
    enabled: false
    ffmpeg:
      inputs:
        - path: rtsp://user:password@192.168.1.100:554/stream1
          roles:
            - detect
            - record
YAML
DEVICES=""
if [ -e /dev/dri ]; then DEVICES=$'    devices:\n      - /dev/dri:/dev/dri'; fi
cat >/opt/frigate/compose.yaml <<YAML
services:
  frigate:
    image: ghcr.io/blakeblackshear/frigate:stable
    container_name: frigate
    restart: unless-stopped
    shm_size: "512mb"
    stop_grace_period: 30s
    environment:
      - TZ=Etc/UTC
    ports:
      - "8971:8971"
      - "8554:8554"
      - "8555:8555/tcp"
      - "8555:8555/udp"
    volumes:
      - ./config:/config
      - /data/frigate:/media/frigate
      - type: tmpfs
        target: /tmp/cache
        tmpfs:
          size: 1000000000
${DEVICES}
YAML
msg_ok "Wrote /opt/frigate/compose.yaml"
docker_app frigate

msg_info "Waiting for Frigate's first-start admin password"
for i in $(seq 1 60); do
  PASS=$(docker logs frigate 2>&1 | sed -n 's/.*Password: \([^ ]*\).*/\1/p' | tail -n1)
  if [ -n "$PASS" ]; then break; fi
  sleep 3
done
if [ -n "${PASS:-}" ]; then
  save_creds "Frigate" "user: admin" "password: ${PASS}"
  msg_ok "Saved the login to /root/frigate.creds"
else
  msg_warn "Frigate is still starting; find the admin password later with: docker logs frigate | grep -i password"
fi

motd_ssh
customize
cleanup_lxc
