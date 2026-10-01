#!/usr/bin/env bash
# GFL Proxmox Scripts - Ollama installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Ollama (large download)"
$STD apt-get install -y zstd pciutils
fetch https://ollama.com/install.sh -o /tmp/ollama-install.sh
$STD sh /tmp/ollama-install.sh
rm -f /tmp/ollama-install.sh
msg_ok "Installed Ollama"

msg_info "Making Ollama reachable from your network"
mkdir -p /etc/systemd/system/ollama.service.d
cat >/etc/systemd/system/ollama.service.d/gfl.conf <<'UNIT'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
UNIT
systemctl daemon-reload
systemctl restart ollama
msg_ok "Ollama listens on port 11434"

motd_ssh
customize
cleanup_lxc
