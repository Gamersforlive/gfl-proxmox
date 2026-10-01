#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://github.com/louislam/uptime-kuma

APP="Uptime Kuma"
var_tags="${var_tags:-monitoring}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="3001"
var_note="Create your admin account on first visit"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/uptime-kuma
  update_packages
  cd /opt/uptime-kuma || exit 1
  local tag
  tag=$(gh_latest louislam/uptime-kuma)
  if [ "$(git describe --tags 2>/dev/null)" = "$tag" ]; then
    msg_ok "Uptime Kuma is already on ${tag}"
    exit
  fi
  msg_info "Updating Uptime Kuma to ${tag}"
  systemctl stop uptime-kuma
  $STD git fetch --all --tags
  $STD git checkout "$tag" --force
  $STD npm ci --omit dev --no-audit
  $STD npm run download-dist
  systemctl start uptime-kuma
  msg_ok "Updated Uptime Kuma to ${tag}"
  exit
}

start
build_container
finish
