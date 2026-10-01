#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://docs.searxng.org

APP="SearXNG"
var_tags="${var_tags:-ai;privacy}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="8080"
var_note="Set it as your browser's search engine: http://<ip>:8080/search?q=%s"

variables
color
catch_errors
header_info

update_script() {
  update_compose searxng
  exit
}

start
build_container
finish
