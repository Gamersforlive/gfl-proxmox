#!/usr/bin/env bash
# GFL Proxmox Scripts - Uptime Kuma installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Node.js 22"
add_repo nodesource https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key https://deb.nodesource.com/node_22.x nodistro main
$STD apt-get install -y nodejs git
msg_ok "Installed Node.js $(node -v)"

msg_info "Installing Uptime Kuma (this takes a few minutes)"
TAG=$(gh_latest louislam/uptime-kuma)
$STD git clone https://github.com/louislam/uptime-kuma.git /opt/uptime-kuma
cd /opt/uptime-kuma || exit 1
$STD git checkout "$TAG"
$STD npm ci --omit dev --no-audit
$STD npm run download-dist
msg_ok "Installed Uptime Kuma ${TAG}"

msg_info "Creating the Uptime Kuma service"
cat >/etc/systemd/system/uptime-kuma.service <<'UNIT'
[Unit]
Description=Uptime Kuma
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/uptime-kuma
ExecStart=/usr/bin/node server/server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl enable -q --now uptime-kuma
msg_ok "Started Uptime Kuma on port 3001"

motd_ssh
customize
cleanup_lxc
