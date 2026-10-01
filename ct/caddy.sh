#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://caddyserver.com

APP="Caddy"
var_tags="${var_tags:-network;proxy}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="80"
var_note="Edit /etc/caddy/Caddyfile, then run: systemctl reload caddy"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/bin/caddy
  update_packages
  local ver current
  ver=$(gh_latest caddyserver/caddy)
  current="v$(caddy version | awk '{print $1}' | sed 's/^v//')"
  if [ "$current" = "$ver" ]; then
    msg_ok "Caddy is already on ${ver}"
    exit
  fi
  msg_info "Updating Caddy to ${ver}"
  fetch "https://github.com/caddyserver/caddy/releases/download/${ver}/caddy_${ver#v}_linux_amd64.deb" -o /tmp/caddy.deb
  $STD apt-get install -y /tmp/caddy.deb
  rm -f /tmp/caddy.deb
  systemctl restart caddy
  msg_ok "Updated Caddy to ${ver}"
  exit
}

start
build_container
finish
