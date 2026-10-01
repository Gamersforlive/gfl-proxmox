#!/usr/bin/env bash
# GFL Proxmox Scripts - Caddy installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Caddy"
add_repo caddy https://dl.cloudsmith.io/public/caddy/stable/gpg.key https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main
$STD apt-get install -y caddy
msg_ok "Installed Caddy $(caddy version | awk '{print $1}')"

motd_ssh
customize
cleanup_lxc
