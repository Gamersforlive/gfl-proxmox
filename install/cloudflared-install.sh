#!/usr/bin/env bash
# GFL Proxmox Scripts - Cloudflared installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing cloudflared"
add_repo cloudflared https://pkg.cloudflare.com/cloudflare-main.gpg https://pkg.cloudflare.com/cloudflared any main
$STD apt-get install -y cloudflared
msg_ok "Installed $(cloudflared --version | head -n1)"

motd_ssh
customize
cleanup_lxc
