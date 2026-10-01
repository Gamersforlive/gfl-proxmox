#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

APP="Cloudflared"
var_tags="${var_tags:-network;tunnel}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="Create a tunnel in the Cloudflare dashboard, then run inside the container: cloudflared service install <token>"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/bin/cloudflared
  update_packages
  systemctl restart cloudflared 2>/dev/null || true
  exit
}

start
build_container
finish
