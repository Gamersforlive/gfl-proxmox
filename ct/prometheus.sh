#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://prometheus.io

APP="Prometheus"
var_tags="${var_tags:-monitoring}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="9090"
var_note="Add scrape targets in /etc/prometheus/prometheus.yml, then: systemctl reload prometheus"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/prometheus/prometheus.yml
  update_packages
  exit
}

start
build_container
finish
