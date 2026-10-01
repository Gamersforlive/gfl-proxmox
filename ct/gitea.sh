#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://about.gitea.com

APP="Gitea"
var_tags="${var_tags:-dev;git}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_port="3000"
var_note="Finish the installer in your browser: pick SQLite and create the admin account at the bottom"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/local/bin/gitea
  update_packages
  local ver current
  ver=$(gh_latest go-gitea/gitea)
  current="v$(/usr/local/bin/gitea --version | awk '{print $3}')"
  if [ "$current" = "$ver" ]; then
    msg_ok "Gitea is already on ${ver}"
    exit
  fi
  msg_info "Updating Gitea to ${ver}"
  fetch "https://dl.gitea.com/gitea/${ver#v}/gitea-${ver#v}-linux-amd64" -o /usr/local/bin/gitea.new
  chmod 755 /usr/local/bin/gitea.new
  systemctl stop gitea
  mv /usr/local/bin/gitea.new /usr/local/bin/gitea
  systemctl start gitea
  msg_ok "Updated Gitea to ${ver}"
  exit
}

start
build_container
finish
