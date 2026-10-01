#!/usr/bin/env bash
# GFL Proxmox Scripts - SearXNG installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the SearXNG stack"
mkdir -p /opt/searxng/config /opt/searxng/cache
IP=$(hostname -I | awk '{print $1}')
cat >/opt/searxng/config/settings.yml <<EOF
# Only what differs from SearXNG's defaults.
use_default_settings: true
server:
  secret_key: "$(gen_pw)$(gen_pw)"
  limiter: false
  image_proxy: true
search:
  formats:
    - html
    - json
EOF
cat >/opt/searxng/compose.yaml <<YAML
services:
  searxng:
    image: searxng/searxng:latest
    container_name: searxng
    restart: unless-stopped
    environment:
      - SEARXNG_BASE_URL=http://${IP}:8080/
    ports:
      - "8080:8080"
    volumes:
      - ./config:/etc/searxng
      - ./cache:/var/cache/searxng
YAML
msg_ok "Wrote /opt/searxng/compose.yaml"
docker_app searxng

motd_ssh
customize
cleanup_lxc
