#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.plex.tv

APP="Plex"
var_tags="${var_tags:-media}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_gpu="${var_gpu:-yes}"
var_port="32400"
var_path="/web"
var_note="Sign in with your Plex account to claim the server. Media folders: /data/media/movies and /data/media/tv"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/lib/plexmediaserver
  rm -f /etc/apt/sources.list.d/plexmediaserver.list
  update_packages
  local json url ver current
  json=$(fetch https://plex.tv/api/downloads/5.json)
  ver=$(echo "$json" | jq -r '.computer.Linux.version')
  current=$(dpkg-query -W -f='${Version}' plexmediaserver 2>/dev/null)
  if [ "$current" = "$ver" ]; then
    msg_ok "Plex is already on ${ver}"
    exit
  fi
  msg_info "Updating Plex to ${ver}"
  url=$(echo "$json" | jq -r '.computer.Linux.releases[] | select(.build=="linux-x86_64" and .distro=="debian") | .url' | head -n1)
  fetch "$url" -o /tmp/plex.deb
  $STD apt-get install -y /tmp/plex.deb
  rm -f /tmp/plex.deb /etc/apt/sources.list.d/plexmediaserver.list
  msg_ok "Updated Plex to ${ver}"
  exit
}

start
build_container
finish
