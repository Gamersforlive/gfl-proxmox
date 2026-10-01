#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://github.com/wg-easy/wg-easy

APP="wg-easy"
var_tags="${var_tags:-network;vpn}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="51821"
var_note="Run the setup wizard, then forward UDP port 51820 on your router to this container"

variables
color
catch_errors
header_info

update_script() {
  update_compose wg-easy
  exit
}

# The WireGuard kernel module lives on the host, not in the container.
if command -v pveversion >/dev/null 2>&1; then
  modprobe wireguard 2>/dev/null || true
  grep -qx wireguard /etc/modules 2>/dev/null || echo wireguard >>/etc/modules
fi

start
build_container
finish
