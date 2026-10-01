#!/usr/bin/env bash
# GFL Proxmox Scripts - Kavita installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Kavita"
ICU=$(apt-cache search --names-only '^libicu[0-9]+$' | awk '{print $1}' | sort -V | tail -n1)
$STD apt-get install -y "$ICU"
VER=$(gh_latest Kareadita/Kavita)
fetch "https://github.com/Kareadita/Kavita/releases/download/${VER}/kavita-linux-x64.tar.gz" | tar -xz -C /opt
getent group media >/dev/null || groupadd -g 1000 media
id -u kavita >/dev/null 2>&1 || useradd -r -g media -d /opt/Kavita -s /usr/sbin/nologin kavita
chmod +x /opt/Kavita/Kavita
chown -R kavita:media /opt/Kavita
echo "$VER" >/opt/Kavita/.gfl-version
prep_media_dirs /data /data/media /data/media/books /data/media/comics
cat >/etc/systemd/system/kavita.service <<'UNIT'
[Unit]
Description=Kavita
After=network.target

[Service]
User=kavita
Group=media
UMask=0002
WorkingDirectory=/opt/Kavita
ExecStart=/opt/Kavita/Kavita
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable -q --now kavita
msg_ok "Installed Kavita ${VER}"

motd_ssh
customize
cleanup_lxc
