#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.jenkins.io

APP="Jenkins"
var_tags="${var_tags:-dev;ci}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="8080"
var_note="Unlock with the password in /root/jenkins.creds, install the suggested plugins and create your admin"

variables
color
catch_errors
header_info

update_script() {
  require_install /var/lib/jenkins
  update_packages
  systemctl restart jenkins
  exit
}

start
build_container
finish
