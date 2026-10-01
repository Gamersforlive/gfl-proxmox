#!/usr/bin/env bash
# GFL Proxmox Scripts - Pterodactyl Wings installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Installing Wings"
mkdir -p /etc/pterodactyl /var/lib/pterodactyl
fetch https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 -o /usr/local/bin/wings
chmod 755 /usr/local/bin/wings
cat >/etc/systemd/system/wings.service <<'UNIT'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service
# Wings starts once you paste the node config from your panel into this file.
ConditionPathExists=/etc/pterodactyl/config.yml

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable -q wings
msg_ok "Installed Wings"

motd_ssh
customize
cleanup_lxc
