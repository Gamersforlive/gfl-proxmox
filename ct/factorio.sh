#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://factorio.com

APP="Factorio"
var_tags="${var_tags:-gaming}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="Join on <ip>:34197 (UDP). Server name, password and visibility: /opt/factorio/data/server-settings.json"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/factorio/bin/x64/factorio
  update_packages
  msg_info "Updating Factorio"
  fetch https://factorio.com/get-download/stable/headless/linux64 -o /tmp/factorio.tar.xz
  systemctl stop factorio
  # Extracting over the old install keeps saves/, mods/ and server-settings.json.
  tar -xJf /tmp/factorio.tar.xz -C /opt
  rm -f /tmp/factorio.tar.xz
  chown -R factorio:factorio /opt/factorio
  systemctl start factorio
  msg_ok "Updated to $(/opt/factorio/bin/x64/factorio --version | head -n1)"
  exit
}

start
build_container
finish
