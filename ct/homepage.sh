#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://gethomepage.dev

APP="Homepage"
var_tags="${var_tags:-dashboard}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="3000"
var_note="Edit the YAML files in /opt/homepage/config to add your apps; the page reloads by itself"

variables
color
catch_errors
header_info

update_script() {
  update_compose homepage
  exit
}

start
build_container
finish
