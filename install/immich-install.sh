#!/usr/bin/env bash
# GFL Proxmox Scripts - Immich installer. Runs inside the new container.
# Uses Immich's own docker-compose.yml and example.env from the newest release.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Downloading the Immich stack"
mkdir -p /opt/immich /data/immich/library
cd /opt/immich || exit 1
fetch https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml -o compose.yaml
fetch https://github.com/immich-app/immich/releases/latest/download/example.env -o .env
DB_PASS=$(gen_pw)
sed -i \
  -e "s|^UPLOAD_LOCATION=.*|UPLOAD_LOCATION=/data/immich/library|" \
  -e "s|^DB_DATA_LOCATION=.*|DB_DATA_LOCATION=/opt/immich/postgres|" \
  -e "s|^DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|" \
  .env
if grep -q '^# TZ=' .env; then sed -i "s|^# TZ=.*|TZ=$(cat /etc/timezone 2>/dev/null || echo Etc/UTC)|" .env; fi
chmod 600 .env
msg_ok "Wrote /opt/immich/compose.yaml and .env"

msg_info "Starting Immich (downloads about 3 GB of images)"
$STD docker compose up -d
msg_ok "Started Immich"

motd_ssh
customize
cleanup_lxc
