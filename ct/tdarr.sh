#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://home.tdarr.io

APP="Tdarr"
var_tags="${var_tags:-media}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-32}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_gpu="${var_gpu:-yes}"
var_port="8265"
var_note="Add a library pointing at /media, pick transcode plugins, and the built-in node starts working"

variables
color
catch_errors
header_info

update_script() {
  update_compose tdarr
  exit
}

start
build_container
finish
