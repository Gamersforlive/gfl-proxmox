#!/usr/bin/env bash
# GFL Proxmox Scripts - Grafana installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Grafana"
add_repo grafana https://apt.grafana.com/gpg.key https://apt.grafana.com stable main
$STD apt-get install -y grafana
systemctl daemon-reload
systemctl enable -q --now grafana-server
msg_ok "Installed Grafana"

motd_ssh
customize
cleanup_lxc
