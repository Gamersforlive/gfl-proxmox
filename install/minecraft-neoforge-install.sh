#!/usr/bin/env bash
# GFL Proxmox Scripts - Minecraft (NeoForge) installer. Runs inside the new container.
# Defaults to Minecraft 1.21.1, the version most NeoForge modpacks use. Set MC_VERSION to change it.
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

MC="${MC_VERSION:-1.21.1}"
# NeoForge versions drop the leading "1.": Minecraft 1.21.1 -> NeoForge 21.1.x; 26.1 -> 26.1.x.
NEO_PREFIX="${MC#1.}."
if [[ "$MC" == 1.* ]]; then install_java 21; else install_java 25; fi

msg_info "Installing NeoForge for Minecraft ${MC}"
id -u minecraft >/dev/null 2>&1 || useradd -r -m -d /opt/minecraft -s /bin/bash minecraft
NEO=$(fetch "https://maven.neoforged.net/api/maven/latest/version/releases/net/neoforged/neoforge?filter=${NEO_PREFIX}" | jq -r '.version // empty')
if [ -z "$NEO" ]; then
  msg_error "NeoForge has no release for Minecraft ${MC}."
  exit 1
fi
fetch "https://maven.neoforged.net/releases/net/neoforged/neoforge/${NEO}/neoforge-${NEO}-installer.jar" -o /tmp/neoforge-installer.jar
chown -R minecraft:minecraft /opt/minecraft
cd /opt/minecraft || exit 1
$STD runuser -u minecraft -- java -jar /tmp/neoforge-installer.jar --installServer /opt/minecraft
rm -f /tmp/neoforge-installer.jar /opt/minecraft/installer.log
echo "$NEO" >/opt/minecraft/.neoforge-version
echo "$MC" >/opt/minecraft/.mc-version
mkdir -p /opt/minecraft/mods /opt/minecraft/config
echo "eula=true" >/opt/minecraft/eula.txt
MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
HEAP=$((MEM - 1024))
if [ "$HEAP" -lt 2048 ]; then HEAP=2048; fi
# NeoForge's run.sh reads JVM options from this file.
printf -- '-Xms%sM\n-Xmx%sM\n-XX:+UseG1GC\n' "$HEAP" "$HEAP" >/opt/minecraft/user_jvm_args.txt
chown -R minecraft:minecraft /opt/minecraft
msg_ok "Installed NeoForge ${NEO} for Minecraft ${MC}"

msg_info "Creating the Minecraft service"
cat >/etc/systemd/system/minecraft.service <<'UNIT'
[Unit]
Description=Minecraft server (NeoForge)
After=network-online.target

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/screen -DmS minecraft /opt/minecraft/run.sh nogui
ExecStop=/usr/bin/screen -p 0 -S minecraft -X eval 'stuff "stop"\015'
ExecStop=/bin/bash -c 'while pgrep -u minecraft java >/dev/null; do sleep 1; done'
TimeoutStopSec=120
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
msg_ok "Started Minecraft (NeoForge) with ${HEAP} MB of memory"

motd_ssh
customize
cleanup_lxc
