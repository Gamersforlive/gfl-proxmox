#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.navidrome.org

APP="Navidrome"
var_tags="${var_tags:-media;music}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="4533"
var_note="Create the admin account on first visit. Music folder: /data/media/music"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/navidrome/navidrome.toml
  update_packages
  local ver current
  ver=$(gh_latest navidrome/navidrome)
  current="v$(dpkg-query -W -f='${Version}' navidrome 2>/dev/null)"
  if [ "$current" = "$ver" ]; then
    msg_ok "Navidrome is already on ${ver}"
    exit
  fi
  msg_info "Updating Navidrome to ${ver}"
  fetch "https://github.com/navidrome/navidrome/releases/download/${ver}/navidrome_${ver#v}_linux_amd64.deb" -o /tmp/navidrome.deb
  $STD apt-get install -y /tmp/navidrome.deb
  rm -f /tmp/navidrome.deb
  systemctl restart navidrome
  msg_ok "Updated Navidrome to ${ver}"
  exit
}

start
build_container
finish
