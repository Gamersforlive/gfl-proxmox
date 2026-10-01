#!/usr/bin/env bash
# GFL Proxmox Scripts - Valheim dedicated server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_steamcmd
steam_game 896660 /opt/valheim

msg_info "Configuring the server"
mkdir -p /opt/steam/valheim-data
# Valheim needs a password of at least 5 characters that isn't part of the server name.
cat >/opt/valheim/server.env <<EOF
SERVER_NAME="GFL Valheim"
WORLD="Dedicated"
PASSWORD="$(gen_pw | cut -c1-10)"
PUBLIC=0
EOF
cat >/opt/valheim/start-gfl.sh <<'SH'
#!/usr/bin/env bash
# Started by valheim.service. Change the settings in /opt/valheim/server.env.
cd /opt/valheim
. ./server.env
export LD_LIBRARY_PATH="./linux64:${LD_LIBRARY_PATH:-}"
export SteamAppId=892970
exec ./valheim_server.x86_64 -nographics -batchmode -name "$SERVER_NAME" -port 2456 \
  -world "$WORLD" -password "$PASSWORD" -public "$PUBLIC" -savedir /opt/steam/valheim-data
SH
chmod 755 /opt/valheim/start-gfl.sh
chown -R steam:steam /opt/valheim /opt/steam/valheim-data
save_creds "Valheim server" "$(grep PASSWORD /opt/valheim/server.env)"
msg_ok "Configured the server (password in /root/valheim.creds)"

game_service valheim "Valheim dedicated server" /opt/valheim /opt/valheim/start-gfl.sh
msg_ok "Started Valheim on UDP ports 2456-2457"

motd_ssh
customize
cleanup_lxc
