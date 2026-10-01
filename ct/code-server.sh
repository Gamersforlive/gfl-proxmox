#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://coder.com/docs/code-server

APP="code-server"
var_tags="${var_tags:-dev}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="8080"
var_note="Password in /root/code-server.creds. Your projects folder is /home/coder/projects"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/local/bin/code-server
  update_packages
  msg_info "Updating code-server"
  fetch https://code-server.dev/install.sh -o /tmp/code-server-install.sh
  $STD sh /tmp/code-server-install.sh --method standalone --prefix /usr/local
  rm -f /tmp/code-server-install.sh
  systemctl restart code-server
  msg_ok "Updated to $(/usr/local/bin/code-server --version | head -n1)"
  exit
}

start
build_container
finish
