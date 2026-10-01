#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.postgresql.org

APP="PostgreSQL"
var_tags="${var_tags:-database}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="Connect on port 5432. Login is in /root/postgresql.creds inside the container"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/postgresql
  update_packages
  exit
}

start
build_container
finish
