#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://grafana.com/oss/grafana/

APP="Grafana"
var_tags="${var_tags:-monitoring}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="3000"
var_note="First login: admin / admin. Grafana asks you to change it right away"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/share/grafana
  update_packages
  systemctl restart grafana-server
  exit
}

start
build_container
finish
