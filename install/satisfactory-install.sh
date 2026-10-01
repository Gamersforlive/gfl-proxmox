#!/usr/bin/env bash
# GFL Proxmox Scripts - Satisfactory dedicated server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_steamcmd
steam_game 1690800 /opt/satisfactory

game_service satisfactory "Satisfactory dedicated server" /opt/satisfactory \
  /opt/satisfactory/FactoryServer.sh -Port=7777 -ReliablePort=8888 -log -unattended
msg_ok "Started Satisfactory on port 7777 (TCP and UDP) and 8888 (TCP)"

motd_ssh
customize
cleanup_lxc
