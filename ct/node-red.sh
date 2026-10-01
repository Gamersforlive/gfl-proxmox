#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://nodered.org

APP="Node-RED"
var_tags="${var_tags:-smarthome;automation}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="1880"
var_note="The editor has no login yet: set adminAuth in /var/lib/node-red/settings.js before exposing it"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/systemd/system/node-red.service
  update_packages
  msg_info "Updating Node-RED"
  $STD npm install -g --unsafe-perm node-red@latest
  systemctl restart node-red
  msg_ok "Updated Node-RED"
  exit
}

start
build_container
finish
