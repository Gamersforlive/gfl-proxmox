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
# The official .deb from GitHub (includes the systemd service). Caddy's apt repository
# is signed with a key Debian 13's stricter signature check rejects.
VER=$(gh_latest caddyserver/caddy)
fetch "https://github.com/caddyserver/caddy/releases/download/${VER}/caddy_${VER#v}_linux_amd64.deb" -o /tmp/caddy.deb
$STD apt-get install -y /tmp/caddy.deb
rm -f /tmp/caddy.deb
msg_ok "Installed Caddy ${VER}"

motd_ssh
customize
cleanup_lxc
