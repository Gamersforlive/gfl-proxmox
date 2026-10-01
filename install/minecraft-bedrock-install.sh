#!/usr/bin/env bash
# GFL Proxmox Scripts - Minecraft Bedrock dedicated server installer. Runs inside the new container.
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

msg_info "Downloading the Bedrock dedicated server"
$STD apt-get install -y unzip screen libcurl4t64
id -u minecraft >/dev/null 2>&1 || useradd -r -m -d /opt/minecraft -s /bin/bash minecraft
cat >/opt/minecraft/bedrock-update.sh <<'SH'
#!/usr/bin/env bash
# Downloads the newest Bedrock server and keeps worlds and settings.
set -euo pipefail
url=$(curl -fsSL -A "Mozilla/5.0" https://net-secondary.web.minecraft-services.net/api/v1.0/download/links |
  jq -r '.result.links[] | select(.downloadType=="serverBedrockLinux") | .downloadUrl')
tmp=$(mktemp -d)
curl -fsSL -A "Mozilla/5.0" -o "$tmp/bedrock.zip" "$url"
cd /opt/minecraft
# Keep the player's files when updating.
if [ -f server.properties ]; then
  unzip -q -o "$tmp/bedrock.zip" -x 'server.properties' 'permissions.json' 'allowlist.json' -d /opt/minecraft
else
  unzip -q -o "$tmp/bedrock.zip" -d /opt/minecraft
fi
chmod +x bedrock_server
rm -rf "$tmp"
basename "$url" .zip | sed 's/bedrock-server-//' >.bedrock-version
echo "Bedrock server $(cat .bedrock-version)"
SH
chmod +x /opt/minecraft/bedrock-update.sh
chown -R minecraft:minecraft /opt/minecraft
VERSION=$(runuser -u minecraft -- /opt/minecraft/bedrock-update.sh)
# New Bedrock versions ship with an empty allow list switched on, so nobody could join.
# Start open; turn it back on with "allowlist on" once you've added your friends.
sed -i 's/^allow-list=.*/allow-list=false/' /opt/minecraft/server.properties
# Newer servers default to the "nethernet" transport (WebRTC through Xbox signaling). Classic RakNet
# is what direct IP connections, port forwarding and server-list tools expect.
sed -i 's/^transport=.*/transport=raknet/' /opt/minecraft/server.properties
msg_ok "Downloaded ${VERSION}"

msg_info "Creating the Minecraft service"
cat >/etc/systemd/system/minecraft.service <<'UNIT'
[Unit]
Description=Minecraft Bedrock dedicated server
After=network-online.target

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft
Environment=LD_LIBRARY_PATH=/opt/minecraft
ExecStart=/usr/bin/screen -DmS minecraft /opt/minecraft/bedrock_server
ExecStop=/usr/bin/screen -p 0 -S minecraft -X eval 'stuff "stop"\015'
ExecStop=/bin/bash -c 'while pgrep -u minecraft bedrock_server >/dev/null; do sleep 1; done'
TimeoutStopSec=60
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
msg_ok "Started Minecraft Bedrock on UDP port 19132"

motd_ssh
customize
cleanup_lxc
