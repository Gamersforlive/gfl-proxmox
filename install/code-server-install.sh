#!/usr/bin/env bash
# GFL Proxmox Scripts - code-server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing code-server"
$STD apt-get install -y git build-essential
fetch https://code-server.dev/install.sh -o /tmp/code-server-install.sh
$STD sh /tmp/code-server-install.sh --method standalone --prefix /usr/local
rm -f /tmp/code-server-install.sh
msg_ok "Installed $(/usr/local/bin/code-server --version | head -n1)"

msg_info "Setting up the coder user"
id -u coder >/dev/null 2>&1 || useradd -m -s /bin/bash coder
PASS=$(gen_pw)
mkdir -p /home/coder/.config/code-server /home/coder/projects
cat >/home/coder/.config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:8080
auth: password
password: ${PASS}
cert: false
EOF
chown -R coder:coder /home/coder
cat >/etc/systemd/system/code-server.service <<'UNIT'
[Unit]
Description=code-server
After=network.target

[Service]
User=coder
WorkingDirectory=/home/coder
ExecStart=/usr/local/bin/code-server /home/coder/projects
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable -q --now code-server
save_creds "code-server" "password: ${PASS}"
msg_ok "Saved the password to /root/code-server.creds"

motd_ssh
customize
cleanup_lxc
