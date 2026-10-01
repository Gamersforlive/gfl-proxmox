#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://immich.app

APP="Immich"
var_tags="${var_tags:-media;photos}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-6144}"
var_disk="${var_disk:-32}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_gpu="${var_gpu:-yes}"
var_port="2283"
var_note="Create the admin account on first visit. Photos are stored in /data/immich/library: mount big storage there"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/immich/compose.yaml
  update_packages
  msg_info "Updating Immich to the newest release"
  cd /opt/immich || exit 1
  # Immich ships a new compose file with each release; keep our .env.
  fetch https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml -o compose.yaml
  $STD docker compose pull
  $STD docker compose up -d
  $STD docker image prune -f
  msg_ok "Updated Immich"
  exit
}

start
build_container
finish
