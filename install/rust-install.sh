#!/usr/bin/env bash
# GFL Proxmox Scripts - Rust dedicated server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_steamcmd
steam_game 258550 /opt/rust

msg_info "Configuring the server"
cat >/opt/rust/server.env <<EOF
HOSTNAME="GFL Rust"
MAXPLAYERS=50
WORLDSIZE=3500
SEED=$((RANDOM * RANDOM % 2147483647))
RCON_PASSWORD="$(gen_pw | cut -c1-14)"
EOF
cat >/opt/rust/start-gfl.sh <<'SH'
#!/usr/bin/env bash
# Started by rust.service. Change the settings in /opt/rust/server.env.
cd /opt/rust
. ./server.env
export LD_LIBRARY_PATH="/opt/rust/RustDedicated_Data/Plugins/x86_64:${LD_LIBRARY_PATH:-}"
exec ./RustDedicated -batchmode -nographics \
  +server.port 28015 +server.queryport 28017 +rcon.port 28016 +rcon.web 1 +rcon.password "$RCON_PASSWORD" \
  +server.level "Procedural Map" +server.seed "$SEED" +server.worldsize "$WORLDSIZE" \
  +server.maxplayers "$MAXPLAYERS" +server.hostname "$HOSTNAME" +server.identity gfl
SH
chmod 755 /opt/rust/start-gfl.sh
chown -R steam:steam /opt/rust
save_creds "Rust server" "$(grep RCON_PASSWORD /opt/rust/server.env)"
msg_ok "Configured the server (RCON password in /root/rust.creds)"

game_service rust "Rust dedicated server" /opt/rust /opt/rust/start-gfl.sh
msg_ok "Started Rust on UDP port 28015"

motd_ssh
customize
cleanup_lxc
