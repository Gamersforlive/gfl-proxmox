#!/usr/bin/env bash
# GFL Proxmox Scripts - Project Zomboid dedicated server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_steamcmd
steam_game 380870 /opt/zomboid

msg_info "Configuring the server"
ADMIN=$(gen_pw | cut -c1-12)
# The admin password is only used on the very first start, when the server creates its database.
MEM=$(awk '/MemTotal/ {print int($2/1024/1024)}' /proc/meminfo)
HEAP=$((MEM > 3 ? MEM - 2 : 2))
if [ -f /opt/zomboid/ProjectZomboid64.json ]; then
  sed -i "s/-Xmx[0-9]*[mMgG]/-Xmx${HEAP}g/" /opt/zomboid/ProjectZomboid64.json
fi
chown -R steam:steam /opt/zomboid
save_creds "Project Zomboid server" "admin user: admin" "admin password: ${ADMIN}"
msg_ok "Configured the server (${HEAP} GB of memory, admin login in /root/project-zomboid.creds)"

game_service zomboid "Project Zomboid dedicated server" /opt/zomboid \
  /opt/zomboid/start-server.sh -servername gfl -adminpassword "${ADMIN}"
msg_ok "Started Project Zomboid on UDP ports 16261-16262"

motd_ssh
customize
cleanup_lxc
