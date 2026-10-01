#!/usr/bin/env bash
# GFL Proxmox Scripts - Minecraft (Fabric) installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors

if [ "${MC_EULA:-no}" != "yes" ]; then
  msg_error "The Minecraft EULA was not accepted, so nothing was installed."
  exit 1
fi

setting_up_container
network_check
update_os
$STD apt-get install -y screen
install_java 25

msg_info "Downloading the Fabric server launcher"
id -u minecraft >/dev/null 2>&1 || useradd -r -m -d /opt/minecraft -s /bin/bash minecraft
cat >/opt/minecraft/fabric-update.sh <<'SH'
#!/usr/bin/env bash
# Downloads the Fabric server launcher for the newest stable Minecraft, loader and installer.
# Pin a Minecraft version with: MC_VERSION=1.21.1 /opt/minecraft/fabric-update.sh
set -euo pipefail
M=https://meta.fabricmc.net/v2/versions
cd /opt/minecraft
game="${MC_VERSION:-$(cat .mc-version 2>/dev/null || curl -fsSL "$M/game" | jq -r '[.[] | select(.stable)][0].version')}"
loader=$(curl -fsSL "$M/loader" | jq -r '[.[] | select(.stable)][0].version')
installer=$(curl -fsSL "$M/installer" | jq -r '[.[] | select(.stable)][0].version')
curl -fsSL -o fabric-server.jar.new "$M/loader/$game/$loader/$installer/server/jar"
mv fabric-server.jar.new fabric-server.jar
echo "$game" >.mc-version
echo "Fabric for Minecraft $game (loader $loader)"
SH
chmod +x /opt/minecraft/fabric-update.sh
mkdir -p /opt/minecraft/mods
chown -R minecraft:minecraft /opt/minecraft
FABRIC=$(runuser -u minecraft -- /opt/minecraft/fabric-update.sh)
echo "eula=true" >/opt/minecraft/eula.txt
chown minecraft:minecraft /opt/minecraft/eula.txt
msg_ok "Downloaded ${FABRIC}"

msg_info "Creating the Minecraft service"
MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
HEAP=$((MEM - 768))
if [ "$HEAP" -lt 1024 ]; then HEAP=1024; fi
cat >/etc/systemd/system/minecraft.service <<UNIT
[Unit]
Description=Minecraft server (Fabric)
After=network-online.target

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/screen -DmS minecraft /usr/local/bin/java -Xms${HEAP}M -Xmx${HEAP}M -XX:+UseG1GC -jar fabric-server.jar nogui
ExecStop=/usr/bin/screen -p 0 -S minecraft -X eval 'stuff "stop"\\015'
ExecStop=/bin/bash -c 'while pgrep -u minecraft java >/dev/null; do sleep 1; done'
TimeoutStopSec=90
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
cat >/usr/local/bin/mc-console <<'SH'
#!/usr/bin/env bash
# Opens the live server console. Leave with Ctrl+A then D; the server keeps running.
exec runuser -u minecraft -- screen -r minecraft
SH
chmod +x /usr/local/bin/mc-console
systemctl daemon-reload
systemctl enable -q --now minecraft
msg_ok "Started Minecraft (Fabric) with ${HEAP} MB of memory"

motd_ssh
customize
cleanup_lxc
