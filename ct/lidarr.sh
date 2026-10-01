#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://lidarr.audio

APP="Lidarr"
var_tags="${var_tags:-media;arr}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="8686"
var_note="Lidarr updates itself (Settings > General > Updates). Mount your media at /data"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/Lidarr
  update_packages
  msg_ok "Lidarr itself updates from its own web UI"
  exit
}

start
build_container
finish
