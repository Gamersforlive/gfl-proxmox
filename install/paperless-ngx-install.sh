#!/usr/bin/env bash
# GFL Proxmox Scripts - Paperless-ngx installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the Paperless-ngx stack"
mkdir -p /opt/paperless-ngx/{data,media,export,consume}
PASS=$(gen_pw)
TZNAME=$(cat /etc/timezone 2>/dev/null || echo Etc/UTC)
cat >/opt/paperless-ngx/.env <<ENV
PAPERLESS_ADMIN_USER=admin
PAPERLESS_ADMIN_PASSWORD=${PASS}
PAPERLESS_SECRET_KEY=$(head -c 96 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | cut -c1-64)
PAPERLESS_TIME_ZONE=${TZNAME}
PAPERLESS_OCR_LANGUAGE=eng
ENV
chmod 600 /opt/paperless-ngx/.env
cat >/opt/paperless-ngx/compose.yaml <<'YAML'
services:
  broker:
    image: docker.io/library/redis:8
    container_name: paperless-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data
  webserver:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    container_name: paperless
    restart: unless-stopped
    depends_on:
      - broker
    ports:
      - "8000:8000"
    env_file: .env
    environment:
      - PAPERLESS_REDIS=redis://broker:6379
    volumes:
      - ./data:/usr/src/paperless/data
      - ./media:/usr/src/paperless/media
      - ./export:/usr/src/paperless/export
      - ./consume:/usr/src/paperless/consume
YAML
save_creds "Paperless-ngx" "user: admin" "password: ${PASS}"
msg_ok "Saved the login to /root/paperless-ngx.creds"
compose_up paperless-ngx

motd_ssh
customize
cleanup_lxc
