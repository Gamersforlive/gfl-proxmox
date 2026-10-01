#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://openwebui.com

APP="Open WebUI"
var_tags="${var_tags:-ai}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-16}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_docker="yes"
var_port="8080"
var_note="The first account you create is the admin. Add Ollama under Admin > Settings > Connections (http://<ollama-ip>:11434)"

variables
color
catch_errors
header_info

update_script() {
  update_compose open-webui
  exit
}

start
build_container
finish
