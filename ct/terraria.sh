#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://terraria.org

APP="Terraria"
var_tags="${var_tags:-gaming}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="Join on <ip>:7777. Settings: /opt/terraria/serverconfig.txt; console: game-console"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/steam/terraria-update.sh
  update_packages
  msg_info "Updating the Terraria server"
  systemctl stop terraria
  $STD /opt/steam/terraria-update.sh
  chown -R steam:steam /opt/terraria
  systemctl start terraria
  msg_ok "Updated to $(cat /opt/terraria/version)"
  exit
}

start
build_container
finish
