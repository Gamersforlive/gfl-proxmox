#!/usr/bin/env bash
# GFL Proxmox Scripts - Syncthing installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Adding the Syncthing repository"
add_repo syncthing https://syncthing.net/release-key.gpg https://apt.syncthing.net/ syncthing stable-v2
msg_ok "Added the Syncthing repository"

msg_info "Installing Syncthing"
$STD apt-get install -y syncthing
id -u syncthing >/dev/null 2>&1 || useradd -r -m -d /var/lib/syncthing -s /usr/sbin/nologin syncthing
mkdir -p /data/sync
chown syncthing:syncthing /data/sync
# The web UI only listens on localhost by default; open it to the network.
mkdir -p /etc/systemd/system/syncthing@syncthing.service.d
cat >/etc/systemd/system/syncthing@syncthing.service.d/gfl.conf <<'UNIT'
[Service]
Environment=STGUIADDRESS=0.0.0.0:8384
UNIT
systemctl daemon-reload
systemctl enable -q --now syncthing@syncthing
msg_ok "Installed Syncthing"

motd_ssh
customize
cleanup_lxc
