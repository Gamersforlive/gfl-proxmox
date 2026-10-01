#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://projectzomboid.com

APP="Project Zomboid"
var_tags="${var_tags:-gaming}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-8192}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="Join on <ip>:16261. Admin login in /root/project-zomboid.creds; console: game-console"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/steam/update-game.sh
  update_packages
  msg_info "Updating the game server"
  systemctl stop zomboid
  $STD runuser -u steam -- /opt/steam/update-game.sh
  systemctl start zomboid
  msg_ok "Updated the game server"
  exit
}

start
build_container
finish
