#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://jellyfin.org

APP="Jellyfin"
var_tags="${var_tags:-media}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_gpu="${var_gpu:-yes}"
var_port="8096"
var_note="Finish the setup wizard in your browser. Media folders: /data/media/movies and /data/media/tv"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/apt/sources.list.d/jellyfin.sources
  update_packages
  exit
}

start
build_container
finish
