#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.valheimgame.com

APP="Valheim"
var_tags="${var_tags:-gaming}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="Join on <ip>:2456 (UDP 2456-2457). The password is in /root/valheim.creds; change name and password in /opt/valheim/server.env"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/steam/update-game.sh
  update_packages
  msg_info "Updating the game server"
  systemctl stop valheim
  $STD runuser -u steam -- /opt/steam/update-game.sh
  systemctl start valheim
  msg_ok "Updated the game server"
  exit
}

start
build_container
finish
