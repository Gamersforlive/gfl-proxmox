#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://docs.paperless-ngx.com

APP="Paperless-ngx"
var_tags="${var_tags:-files;documents}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="8000"
var_note="Login: user admin, password in /root/paperless-ngx.creds. Drop files in /opt/paperless-ngx/consume to import them"

variables
color
catch_errors
header_info

update_script() {
  update_compose paperless-ngx
  exit
}

start
build_container
finish
