#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.qbittorrent.org

APP="qBittorrent"
var_tags="${var_tags:-media;torrent}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="8090"
var_note="Login: user admin, password in /root/qbittorrent.creds inside the container"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/systemd/system/qbittorrent.service
  update_packages
  systemctl restart qbittorrent
  exit
}

start
build_container
finish
