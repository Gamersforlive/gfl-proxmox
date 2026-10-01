#!/usr/bin/env bash
# GFL Proxmox Scripts - Prometheus installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Prometheus and the node exporter"
$STD apt-get install -y prometheus prometheus-node-exporter
systemctl enable -q --now prometheus prometheus-node-exporter
msg_ok "Installed Prometheus"

motd_ssh
customize
cleanup_lxc
