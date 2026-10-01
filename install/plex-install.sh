#!/usr/bin/env bash
# GFL Proxmox Scripts - Plex Media Server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

# Plex's apt repository is signed with a SHA-1 key that Debian 13 no longer trusts, so
# the .deb comes from Plex's download API instead (the same file as on plex.tv).
msg_info "Installing Plex Media Server"
PLEX_JSON=$(fetch https://plex.tv/api/downloads/5.json)
URL=$(echo "$PLEX_JSON" | jq -r '.computer.Linux.releases[] | select(.build=="linux-x86_64" and .distro=="debian") | .url' | head -n1)
VER=$(echo "$PLEX_JSON" | jq -r '.computer.Linux.version')
fetch "$URL" -o /tmp/plex.deb
$STD apt-get install -y /tmp/plex.deb
rm -f /tmp/plex.deb
# The package may add Plex's repository; with that key apt would fail, so remove it.
rm -f /etc/apt/sources.list.d/plexmediaserver.list
systemctl enable -q --now plexmediaserver
msg_ok "Installed Plex Media Server ${VER}"

install_gpu_drivers plex
if [ "${GPU:-no}" = "yes" ]; then systemctl restart plexmediaserver; fi

join_media_group plex
prep_media_dirs /data /data/media /data/media/movies /data/media/tv /data/media/music
systemctl restart plexmediaserver

motd_ssh
customize
cleanup_lxc
