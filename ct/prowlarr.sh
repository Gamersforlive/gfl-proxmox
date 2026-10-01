#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://prowlarr.com

APP="Prowlarr"
var_tags="${var_tags:-media;arr}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="9696"
var_note="Add your indexers, then connect Radarr and Sonarr under Settings > Apps"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/Prowlarr
  update_packages
  msg_ok "Prowlarr itself updates from its own web UI"
  exit
}

start
build_container
finish
