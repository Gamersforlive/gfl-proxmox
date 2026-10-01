#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://pi-hole.net

APP="Pi-hole"
var_slug="pihole"
var_tags="${var_tags:-network;dns}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="80"
var_path="/admin"
var_note="Password in /root/pihole.creds. Then point your router's DNS at this container"

variables
color
catch_errors
header_info

update_script() {
  update_compose pihole
  exit
}

start
build_container
finish
