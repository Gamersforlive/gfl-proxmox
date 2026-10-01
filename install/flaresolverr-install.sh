#!/usr/bin/env bash
# GFL Proxmox Scripts - FlareSolverr installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the FlareSolverr stack"
mkdir -p /opt/flaresolverr
cat >/opt/flaresolverr/compose.yaml <<'YAML'
services:
  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    restart: unless-stopped
    environment:
      - LOG_LEVEL=info
    ports:
      - "8191:8191"
YAML
msg_ok "Wrote /opt/flaresolverr/compose.yaml"
compose_up flaresolverr

motd_ssh
customize
cleanup_lxc
