#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://mosquitto.org

APP="Mosquitto"
var_tags="${var_tags:-smarthome;mqtt}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="MQTT on port 1883. Login is in /root/mosquitto.creds inside the container"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/mosquitto/conf.d/gfl.conf
  update_packages
  exit
}

start
build_container
finish
