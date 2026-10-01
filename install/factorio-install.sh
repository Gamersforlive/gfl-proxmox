#!/usr/bin/env bash
# GFL Proxmox Scripts - Factorio dedicated server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Downloading the Factorio headless server"
$STD apt-get install -y xz-utils
id -u factorio >/dev/null 2>&1 || useradd -r -m -d /opt/factorio -s /usr/sbin/nologin factorio
fetch https://factorio.com/get-download/stable/headless/linux64 -o /tmp/factorio.tar.xz
tar -xJf /tmp/factorio.tar.xz -C /opt
rm -f /tmp/factorio.tar.xz
msg_ok "Downloaded $(/opt/factorio/bin/x64/factorio --version | head -n1)"

msg_info "Creating a world"
mkdir -p /opt/factorio/saves
if [ ! -f /opt/factorio/data/server-settings.json ]; then
  cp /opt/factorio/data/server-settings.example.json /opt/factorio/data/server-settings.json
fi
chown -R factorio:factorio /opt/factorio
$STD runuser -u factorio -- /opt/factorio/bin/x64/factorio --create /opt/factorio/saves/world.zip
msg_ok "Created /opt/factorio/saves/world.zip"

cat >/etc/systemd/system/factorio.service <<'UNIT'
[Unit]
Description=Factorio dedicated server
After=network-online.target

[Service]
User=factorio
WorkingDirectory=/opt/factorio
ExecStart=/opt/factorio/bin/x64/factorio --start-server-load-latest --server-settings /opt/factorio/data/server-settings.json
Restart=on-failure
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable -q --now factorio
msg_ok "Started Factorio on UDP port 34197"

motd_ssh
customize
cleanup_lxc
