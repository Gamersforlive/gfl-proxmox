#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://www.minecraft.net/download/server/bedrock

APP="Minecraft Bedrock"
var_slug="minecraft-bedrock"
var_tags="${var_tags:-gaming}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="Join on <ip>:19132 (UDP). Settings: /opt/minecraft/server.properties; console: mc-console"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/minecraft/bedrock-update.sh
  update_packages
  msg_info "Updating the Bedrock server"
  systemctl stop minecraft
  $STD runuser -u minecraft -- /opt/minecraft/bedrock-update.sh
  systemctl start minecraft
  msg_ok "Updated to Bedrock $(cat /opt/minecraft/.bedrock-version)"
  exit
}

start
# Mojang requires every server owner to accept the EULA.
if [ "${MC_EULA:-}" != "yes" ]; then
  whiptail --backtitle "$BACKTITLE" --title "Minecraft EULA" --yesno \
    "Running a Minecraft server means you accept the Minecraft EULA:\nhttps://aka.ms/MinecraftEULA\n\nDo you accept it?" 12 64 || exit_script
fi
GFL_EXTRA_ENV=(MC_EULA=yes)
build_container
finish
