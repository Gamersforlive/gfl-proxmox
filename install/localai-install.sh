#!/usr/bin/env bash
# GFL Proxmox Scripts - LocalAI installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the LocalAI stack"
mkdir -p /opt/localai/models
cat >/opt/localai/compose.yaml <<'YAML'
services:
  localai:
    image: localai/localai:latest
    container_name: localai
    restart: unless-stopped
    environment:
      - MODELS_PATH=/models
    ports:
      - "8080:8080"
    volumes:
      - ./models:/models
YAML
msg_ok "Wrote /opt/localai/compose.yaml"
docker_app localai

motd_ssh
customize
cleanup_lxc
