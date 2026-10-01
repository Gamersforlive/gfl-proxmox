#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://pterodactyl.io/wings/1.0/installing.html

APP="Pterodactyl Wings"
var_tags="${var_tags:-gaming}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-8192}"
var_disk="${var_disk:-64}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_note="Paste the node config from your panel into /etc/pterodactyl/config.yml, then run: systemctl start wings"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/local/bin/wings
  update_packages
  msg_info "Updating Wings"
  fetch https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 -o /usr/local/bin/wings.new
  chmod 755 /usr/local/bin/wings.new
  systemctl stop wings 2>/dev/null || true
  mv /usr/local/bin/wings.new /usr/local/bin/wings
  systemctl start wings 2>/dev/null || true
  msg_ok "Updated Wings"
  exit
}

start
build_container
finish
