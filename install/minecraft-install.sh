#!/usr/bin/env bash
# GFL Proxmox Scripts - Minecraft (Paper) installer. Runs inside the new container.
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

msg_info "Installing Java 25 (Eclipse Temurin)"
$STD apt-get install -y screen
mkdir -p /opt/java
fetch "https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jre/hotspot/normal/eclipse" | tar -xz -C /opt/java --strip-components=1
ln -sf /opt/java/bin/java /usr/local/bin/java
msg_ok "Installed $(java -version 2>&1 | head -n1)"

msg_info "Downloading the newest stable Paper server"
id -u minecraft >/dev/null 2>&1 || useradd -r -m -d /opt/minecraft -s /bin/bash minecraft
cat >/opt/minecraft/paper-update.sh <<'SH'
#!/usr/bin/env bash
# Downloads the newest stable Paper build for the current Minecraft version.
# Switch versions with: MC_VERSION=26.3 /opt/minecraft/paper-update.sh
set -euo pipefail
API=https://fill.papermc.io/v3/projects/paper
UA="gfl-proxmox (https://github.com/gamersforlive/gfl-proxmox)"
cd /opt/minecraft
want="${MC_VERSION:-$(cat .mc-version 2>/dev/null || true)}"
if [ -n "$want" ]; then
  versions="$want"
else
  versions=$(curl -fsSL -H "User-Agent: $UA" "$API/versions" |
    jq -r '.versions[] | select(.version.support.status=="SUPPORTED") | .version.id')
fi
url="" ver=""
for v in $versions; do
  url=$(curl -fsSL -H "User-Agent: $UA" "$API/versions/$v/builds" |
    jq -r 'map(select(.channel=="STABLE")) | .[0].downloads["server:default"].url // empty')
  if [ -n "$url" ]; then ver="$v"; break; fi
done
if [ -z "$url" ]; then
  # No stable build yet: take the newest build of the newest version.
  ver=$(echo "$versions" | head -n1)
  url=$(curl -fsSL -H "User-Agent: $UA" "$API/versions/$ver/builds/latest" | jq -r '.downloads["server:default"].url')
fi
curl -fsSL -H "User-Agent: $UA" -o paper.jar.new "$url"
mv paper.jar.new paper.jar
echo "$ver" >.mc-version
echo "Paper for Minecraft $ver ($(basename "$url"))"
SH
chmod +x /opt/minecraft/paper-update.sh
chown -R minecraft:minecraft /opt/minecraft
PAPER=$(runuser -u minecraft -- /opt/minecraft/paper-update.sh)
echo "eula=true" >/opt/minecraft/eula.txt
chown minecraft:minecraft /opt/minecraft/eula.txt
msg_ok "Downloaded ${PAPER}"

msg_info "Creating the Minecraft service"
MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
HEAP=$((MEM - 768))
if [ "$HEAP" -lt 1024 ]; then HEAP=1024; fi
cat >/etc/systemd/system/minecraft.service <<UNIT
[Unit]
Description=Minecraft server (Paper)
After=network-online.target

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/screen -DmS minecraft /usr/local/bin/java -Xms${HEAP}M -Xmx${HEAP}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -jar paper.jar --nogui
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
systemctl enable -q --now minecraft
msg_ok "Started Minecraft with ${HEAP} MB of memory"

motd_ssh
customize
cleanup_lxc
