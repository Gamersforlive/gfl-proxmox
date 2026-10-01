#!/usr/bin/env bash
# GFL Proxmox Scripts - Forgejo installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Forgejo"
$STD apt-get install -y git git-lfs
VER=$(fetch https://codeberg.org/api/v1/repos/forgejo/forgejo/releases/latest | jq -r .tag_name)
fetch "https://codeberg.org/forgejo/forgejo/releases/download/${VER}/forgejo-${VER#v}-linux-amd64" -o /usr/local/bin/forgejo
chmod 755 /usr/local/bin/forgejo
id -u git >/dev/null 2>&1 || adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git >/dev/null
mkdir -p /var/lib/forgejo/{custom,data,log} /etc/forgejo
chown -R git:git /var/lib/forgejo
chmod -R 750 /var/lib/forgejo
chown root:git /etc/forgejo
chmod 770 /etc/forgejo
cat >/etc/systemd/system/forgejo.service <<'UNIT'
[Unit]
Description=Forgejo
After=network.target

[Service]
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/forgejo/
ExecStart=/usr/local/bin/forgejo web --config /etc/forgejo/app.ini
Restart=always
Environment=USER=git HOME=/home/git FORGEJO_WORK_DIR=/var/lib/forgejo

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable -q --now forgejo
msg_ok "Installed Forgejo ${VER}"

motd_ssh
customize
cleanup_lxc
