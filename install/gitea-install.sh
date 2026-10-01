#!/usr/bin/env bash
# GFL Proxmox Scripts - Gitea installer. Runs inside the new container.
# Follows https://docs.gitea.com/installation/install-from-binary
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Gitea"
$STD apt-get install -y git git-lfs
VER=$(gh_latest go-gitea/gitea)
fetch "https://dl.gitea.com/gitea/${VER#v}/gitea-${VER#v}-linux-amd64" -o /usr/local/bin/gitea
chmod 755 /usr/local/bin/gitea
id -u git >/dev/null 2>&1 || adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git >/dev/null
mkdir -p /var/lib/gitea/{custom,data,log} /etc/gitea
chown -R git:git /var/lib/gitea
chmod -R 750 /var/lib/gitea
# The web installer writes /etc/gitea/app.ini on first visit.
chown root:git /etc/gitea
chmod 770 /etc/gitea
cat >/etc/systemd/system/gitea.service <<'UNIT'
[Unit]
Description=Gitea (Git with a cup of tea)
After=network.target

[Service]
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

[Install]
WantedBy=multi-user.target
UNIT
systemctl enable -q --now gitea
msg_ok "Installed Gitea ${VER}"

motd_ssh
customize
cleanup_lxc
