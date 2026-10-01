#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.kavitareader.com

APP="Kavita"
var_tags="${var_tags:-media;books}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="5000"
var_note="Create the admin account on first visit. Library folders: /data/media/books and /data/media/comics"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/Kavita/Kavita
  update_packages
  local ver
  ver=$(gh_latest Kareadita/Kavita)
  if [ "$(cat /opt/Kavita/.gfl-version 2>/dev/null)" = "$ver" ]; then
    msg_ok "Kavita is already on ${ver}"
    exit
  fi
  msg_info "Updating Kavita to ${ver}"
  systemctl stop kavita
  fetch "https://github.com/Kareadita/Kavita/releases/download/${ver}/kavita-linux-x64.tar.gz" | tar -xz -C /opt
  echo "$ver" >/opt/Kavita/.gfl-version
  chown -R kavita:media /opt/Kavita
  systemctl start kavita
  msg_ok "Updated Kavita to ${ver}"
  exit
}

start
build_container
finish
