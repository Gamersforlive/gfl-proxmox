#!/usr/bin/env bash
# GFL Proxmox Scripts - Counter-Strike 2 dedicated server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_steamcmd
steam_game 730 /opt/cs2

msg_info "Configuring the server"
RCON=$(gen_pw | cut -c1-14)
mkdir -p /opt/cs2/game/csgo/cfg
cat >/opt/cs2/game/csgo/cfg/server.cfg <<EOF
hostname "GFL Counter-Strike 2"
rcon_password "${RCON}"
sv_password ""
sv_lan 0
EOF
cat >/opt/cs2/server.env <<'EOF'
# Game Server Login Token from https://steamcommunity.com/dev/managegameservers (app 730).
# Without one the server works on your LAN but isn't listed publicly.
GSLT=""
MAP="de_dust2"
GAME_TYPE=0
GAME_MODE=1
MAXPLAYERS=10
EOF
cat >/opt/cs2/start-gfl.sh <<'SH'
#!/usr/bin/env bash
# Started by cs2.service. Change the settings in /opt/cs2/server.env and game/csgo/cfg/server.cfg.
cd /opt/cs2
. ./server.env
args=(-dedicated -usercon -port 27015 -maxplayers "$MAXPLAYERS" +game_type "$GAME_TYPE" +game_mode "$GAME_MODE" +map "$MAP")
if [ -n "$GSLT" ]; then args+=(+sv_setsteamaccount "$GSLT"); fi
exec ./game/bin/linuxsteamrt64/cs2 "${args[@]}"
SH
chmod 755 /opt/cs2/start-gfl.sh
chown -R steam:steam /opt/cs2
save_creds "Counter-Strike 2 server" "rcon password: ${RCON}"
msg_ok "Configured the server (RCON password in /root/counter-strike-2.creds)"

game_service cs2 "Counter-Strike 2 dedicated server" /opt/cs2 /opt/cs2/start-gfl.sh
msg_ok "Started Counter-Strike 2 on port 27015"

motd_ssh
customize
cleanup_lxc
