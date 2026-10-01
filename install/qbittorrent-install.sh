#!/usr/bin/env bash
# GFL Proxmox Scripts - qBittorrent installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing qBittorrent (web UI only)"
$STD apt-get install -y qbittorrent-nox python3
getent group media >/dev/null || groupadd -g 1000 media
id -u qbittorrent >/dev/null 2>&1 || useradd -r -m -g media -d /var/lib/qbittorrent -s /usr/sbin/nologin qbittorrent
prep_media_dirs /data /data/downloads /data/downloads/complete /data/downloads/incomplete
msg_ok "Installed qBittorrent"

msg_info "Setting the web UI login"
# Bundles pass one shared login for every app; otherwise generate a password.
QB_USER="${GFL_APP_USER:-admin}"
PASS="${GFL_APP_PASS:-$(gen_pw)}"
HASH=$(python3 -c '
import base64, hashlib, os, sys
salt = os.urandom(16)
key = hashlib.pbkdf2_hmac("sha512", sys.argv[1].encode(), salt, 100000, 64)
print("@ByteArray(%s:%s)" % (base64.b64encode(salt).decode(), base64.b64encode(key).decode()))
' "$PASS")
CONF=/var/lib/qbittorrent/.config/qBittorrent
mkdir -p "$CONF"
cat >"$CONF/qBittorrent.conf" <<CONFIG
[LegalNotice]
Accepted=true

[BitTorrent]
Session\DefaultSavePath=/data/downloads/complete
Session\TempPath=/data/downloads/incomplete
Session\TempPathEnabled=true

[Preferences]
WebUI\Port=8090
WebUI\Username=${QB_USER}
WebUI\Password_PBKDF2="${HASH}"
CONFIG
chown -R qbittorrent:media /var/lib/qbittorrent
save_creds "qBittorrent web UI" "user: ${QB_USER}" "password: ${PASS}"
msg_ok "Saved the login to /root/qbittorrent.creds"

msg_info "Creating the qBittorrent service"
cat >/etc/systemd/system/qbittorrent.service <<'UNIT'
[Unit]
Description=qBittorrent (web UI)
After=network-online.target

[Service]
User=qbittorrent
Group=media
UMask=0002
ExecStart=/usr/bin/qbittorrent-nox --webui-port=8090
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl enable -q --now qbittorrent
msg_ok "Started qBittorrent on port 8090"

motd_ssh
customize
cleanup_lxc
