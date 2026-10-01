#!/usr/bin/env bash
# GFL Proxmox Scripts - Terraria dedicated server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Downloading the Terraria server"
$STD apt-get install -y unzip screen
id -u steam >/dev/null 2>&1 || useradd -r -m -d /opt/steam -s /bin/bash steam
cat >/opt/steam/terraria-update.sh <<'SH'
#!/usr/bin/env bash
# Downloads the newest official Terraria dedicated server into /opt/terraria/server.
set -euo pipefail
name=$(curl -fsSL https://terraria.org/api/get/dedicated-servers-names | sed -n 's/^\["\([^"]*\)".*/\1/p')
tmp=$(mktemp -d)
curl -fsSL "https://terraria.org/api/download/pc-dedicated-server/${name}" -o "$tmp/server.zip"
unzip -q "$tmp/server.zip" -d "$tmp"
rm -rf /opt/terraria/server
mkdir -p /opt/terraria/server
cp -r "$tmp"/*/Linux/. /opt/terraria/server/
chmod +x /opt/terraria/server/TerrariaServer.bin.x86_64
rm -rf "$tmp"
echo "${name%.zip}" >/opt/terraria/version
SH
chmod 755 /opt/steam/terraria-update.sh
mkdir -p /opt/terraria/worlds
/opt/steam/terraria-update.sh >>"$GFL_LOG" 2>&1
msg_ok "Downloaded $(cat /opt/terraria/version)"

msg_info "Configuring the server"
cat >/opt/terraria/serverconfig.txt <<'EOF'
world=/opt/terraria/worlds/World.wld
autocreate=2
worldname=World
difficulty=0
maxplayers=8
port=7777
password=
motd=Welcome to a GFL Terraria server!
worldpath=/opt/terraria/worlds
EOF
chown -R steam:steam /opt/terraria
msg_ok "Configured the server (world: World, medium size)"

game_service terraria "Terraria dedicated server" /opt/terraria/server \
  /opt/terraria/server/TerrariaServer.bin.x86_64 -config /opt/terraria/serverconfig.txt
msg_ok "Started Terraria on port 7777"

motd_ssh
customize
cleanup_lxc
