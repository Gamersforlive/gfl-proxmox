#!/usr/bin/env bash
# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/build.func")
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Upstream: https://neoforged.net

APP="Minecraft NeoForge"
var_slug="minecraft-neoforge"
var_tags="${var_tags:-gaming}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-8192}"
var_disk="${var_disk:-24}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"
var_note="Join on <ip>:25565. Put mods in /opt/minecraft/mods; console: mc-console"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/minecraft/run.sh
  update_packages
  exit
}

start
# Mojang requires every server owner to accept the EULA.
if [ "${MC_EULA:-}" != "yes" ]; then
  whiptail --backtitle "$BACKTITLE" --title "Minecraft EULA" --yesno \
    "Running a Minecraft server means you accept the Minecraft EULA:\nhttps://aka.ms/MinecraftEULA\n\nDo you accept it?" 12 64 || exit_script
fi
GFL_EXTRA_ENV=(MC_EULA=yes MC_VERSION="${MC_VERSION:-1.21.1}")
build_container
finish
