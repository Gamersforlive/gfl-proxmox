#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://docs.docker.com/engine/

APP="Docker"
var_tags="${var_tags:-docker}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_note="Docker and the compose plugin are ready. Put your stacks in /opt/<name>/compose.yaml"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/bin/docker
  update_packages
  exit
}

start
build_container
finish
