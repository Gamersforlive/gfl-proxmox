#!/usr/bin/env bash
# GFL Proxmox Scripts - Palworld dedicated server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_steamcmd
steam_game 2394010 /opt/palworld

msg_info "Configuring the server"
# The real settings file is created on the first start; seed it from the defaults so
# server name and admin password are set from the beginning.
CFG=/opt/palworld/Pal/Saved/Config/LinuxServer
mkdir -p "$CFG"
ADMIN=$(gen_pw | cut -c1-12)
if [ -f /opt/palworld/DefaultPalWorldSettings.ini ]; then
  sed -e "s/ServerName=\"[^\"]*\"/ServerName=\"GFL Palworld\"/" \
    -e "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"${ADMIN}\"/" \
    /opt/palworld/DefaultPalWorldSettings.ini >"$CFG/PalWorldSettings.ini"
fi
chown -R steam:steam /opt/palworld
save_creds "Palworld server" "admin password: ${ADMIN}"
msg_ok "Configured the server (admin password in /root/palworld.creds)"

game_service palworld "Palworld dedicated server" /opt/palworld \
  /opt/palworld/PalServer.sh -port=8211 -players=16 -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
msg_ok "Started Palworld on UDP port 8211"

motd_ssh
customize
cleanup_lxc
