#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://github.com/seerr-team/seerr

APP="Seerr"
var_tags="${var_tags:-media}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="5055"
var_note="Sign in with Jellyfin, Plex or Emby in the setup wizard, then connect Radarr and Sonarr"

variables
color
catch_errors
header_info

update_script() {
  update_compose seerr
  exit
}

start
build_container
finish
