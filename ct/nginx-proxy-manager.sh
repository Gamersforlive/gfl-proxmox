#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://nginxproxymanager.com

APP="Nginx Proxy Manager"
var_tags="${var_tags:-network;proxy}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="81"
var_note="Create the admin account on first visit. Forward ports 80 and 443 on your router to this container"

variables
color
catch_errors
header_info

update_script() {
  update_compose nginx-proxy-manager
  exit
}

start
build_container
finish
