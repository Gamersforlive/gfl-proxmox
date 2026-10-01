#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://ollama.com

APP="Ollama"
var_tags="${var_tags:-ai}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-8192}"
var_disk="${var_disk:-40}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_gpu="${var_gpu:-yes}"
var_port="11434"
var_note="Pull a model inside the container: ollama pull llama3.2 . Pair it with Open WebUI for a chat page"

variables
color
catch_errors
header_info

update_script() {
  require_install /usr/local/bin/ollama
  update_packages
  msg_info "Updating Ollama"
  fetch https://ollama.com/install.sh -o /tmp/ollama-install.sh
  $STD sh /tmp/ollama-install.sh
  rm -f /tmp/ollama-install.sh
  msg_ok "Updated Ollama to $(ollama --version | awk '{print $NF}')"
  exit
}

start
# Models to download right after install, e.g. OLLAMA_MODELS="llama3.2 qwen2.5:7b"
GFL_EXTRA_ENV=(OLLAMA_MODELS="${OLLAMA_MODELS:-}")
build_container
finish
