#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://adguard.com/adguard-home/overview.html

APP="AdGuard Home"
var_slug="adguard"
var_tags="${var_tags:-network;dns}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="3000"
var_note="Run the setup wizard, then point your router's DNS at this container's IP"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/AdGuardHome/AdGuardHome
  update_packages
  msg_info "Updating AdGuard Home"
  if $STD /opt/AdGuardHome/AdGuardHome --update; then
    msg_ok "Updated AdGuard Home"
  else
    msg_warn "Update AdGuard Home from its web UI (Settings > General settings)"
  fi
  exit
}

start
build_container
finish
