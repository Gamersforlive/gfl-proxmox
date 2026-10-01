#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://syncthing.net

APP="Syncthing"
var_tags="${var_tags:-files}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="8384"
var_note="Set a GUI user and password first (Actions > Settings > GUI). Synced folders go in /data/sync"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/apt/sources.list.d/syncthing.sources
  update_packages
  systemctl restart syncthing@syncthing
  exit
}

start
build_container
finish
