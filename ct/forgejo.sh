#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://forgejo.org

APP="Forgejo"
var_tags="${var_tags:-dev;git}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="3000"
var_note="Finish the installer in your browser: pick SQLite and create the admin account"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/local/bin/forgejo
  update_packages
  local ver current
  ver=$(fetch https://codeberg.org/api/v1/repos/forgejo/forgejo/releases/latest | sed -n 's/.*"tag_name":"\([^"]*\)".*/\1/p')
  current="v$(/usr/local/bin/forgejo --version | awk '{print $3}')"
  if [ "$current" = "$ver" ]; then
    msg_ok "Forgejo is already on ${ver}"
    exit
  fi
  msg_info "Updating Forgejo to ${ver}"
  fetch "https://codeberg.org/forgejo/forgejo/releases/download/${ver}/forgejo-${ver#v}-linux-amd64" -o /usr/local/bin/forgejo.new
  chmod 755 /usr/local/bin/forgejo.new
  systemctl stop forgejo
  mv /usr/local/bin/forgejo.new /usr/local/bin/forgejo
  systemctl start forgejo
  msg_ok "Updated Forgejo to ${ver}"
  exit
}

start
build_container
finish
