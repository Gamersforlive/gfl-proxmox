#!/usr/bin/env bash
# GFL Proxmox Scripts - Jellystat installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Jellystat stack"
mkdir -p /opt/jellystat
cat >/opt/jellystat/.env <<EOF
POSTGRES_PASSWORD=$(gen_pw)
JWT_SECRET=$(gen_pw)$(gen_pw)
EOF
chmod 600 /opt/jellystat/.env
cat >/opt/jellystat/compose.yaml <<'YAML'
services:
  jellystat-db:
    image: postgres:16-alpine
    container_name: jellystat-db
    restart: unless-stopped
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - ./postgres:/var/lib/postgresql/data
  jellystat:
    image: cyfershepard/jellystat:latest
    container_name: jellystat
    restart: unless-stopped
    depends_on:
      - jellystat-db
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_IP=jellystat-db
      - POSTGRES_PORT=5432
      - JWT_SECRET=${JWT_SECRET}
    ports:
      - "3000:3000"
    volumes:
      - ./backup:/app/backend/backup-data
YAML
msg_ok "Wrote /opt/jellystat/compose.yaml"
docker_app jellystat

motd_ssh
customize
cleanup_lxc
