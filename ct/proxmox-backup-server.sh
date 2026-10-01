#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.proxmox.com/en/products/proxmox-backup-server/overview

APP="Proxmox Backup Server"
var_slug="proxmox-backup-server"
var_tags="${var_tags:-backup}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-32}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="8007"
var_proto="https"
var_note="Login root@pam, password in /root/proxmox-backup-server.creds. The datastore 'backups' is at /backup"

variables
color
catch_errors
header_info

update_script() {
  require_install /etc/proxmox-backup
  update_packages
  exit
}

start
build_container
finish
