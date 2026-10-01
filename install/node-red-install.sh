#!/usr/bin/env bash
# GFL Proxmox Scripts - Node-RED installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Node.js 22"
add_repo nodesource https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key https://deb.nodesource.com/node_22.x nodistro main
$STD apt-get install -y nodejs
msg_ok "Installed Node.js $(node -v)"

msg_info "Installing Node-RED"
$STD npm install -g --unsafe-perm node-red
id -u nodered >/dev/null 2>&1 || useradd -r -m -d /var/lib/node-red -s /usr/sbin/nologin nodered
cat >/etc/systemd/system/node-red.service <<'UNIT'
[Unit]
Description=Node-RED
After=network.target

[Service]
Type=simple
User=nodered
WorkingDirectory=/var/lib/node-red
ExecStart=/usr/bin/env node-red --userDir /var/lib/node-red
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable -q --now node-red
msg_ok "Installed Node-RED $(npm ls -g node-red --depth=0 2>/dev/null | grep -o 'node-red@[0-9.]*')"

motd_ssh
customize
cleanup_lxc
