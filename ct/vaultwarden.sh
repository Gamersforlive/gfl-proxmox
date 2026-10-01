#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://github.com/dani-garcia/vaultwarden

APP="Vaultwarden"
var_tags="${var_tags:-security}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="8000"
var_note="The web vault needs HTTPS: put it behind Nginx Proxy Manager, Caddy or a Cloudflare tunnel"

variables
color
catch_errors
header_info

update_script() {
  update_compose vaultwarden
  exit
}

start
build_container
finish
