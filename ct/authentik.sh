#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://goauthentik.io

APP="authentik"
var_tags="${var_tags:-security;sso}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="9000"
var_path="/if/flow/initial-setup/"
var_note="Open http://<ip>:9000/if/flow/initial-setup/ to set the akadmin password"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/authentik/compose.yaml
  update_packages
  msg_info "Updating authentik to the newest release"
  cd /opt/authentik || exit 1
  fetch https://goauthentik.io/docker-compose.yml -o compose.yaml
  $STD docker compose pull
  $STD docker compose up -d
  $STD docker image prune -f
  msg_ok "Updated authentik"
  exit
}

start
build_container
finish
