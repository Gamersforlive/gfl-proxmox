#!/usr/bin/env bash
# GFL Proxmox Scripts - Navidrome installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Navidrome"
$STD apt-get install -y ffmpeg
VER=$(gh_latest navidrome/navidrome)
fetch "https://github.com/navidrome/navidrome/releases/download/${VER}/navidrome_${VER#v}_linux_amd64.deb" -o /tmp/navidrome.deb
$STD apt-get install -y /tmp/navidrome.deb
rm -f /tmp/navidrome.deb
msg_ok "Installed Navidrome ${VER}"

msg_info "Configuring Navidrome"
mkdir -p /etc/navidrome /var/lib/navidrome
prep_media_dirs /data /data/media /data/media/music
cat >/etc/navidrome/navidrome.toml <<'TOML'
MusicFolder = "/data/media/music"
DataFolder = "/var/lib/navidrome"
Address = "0.0.0.0"
Port = 4533
TOML
if id -u navidrome >/dev/null 2>&1; then
  chown -R navidrome:navidrome /var/lib/navidrome
  join_media_group navidrome
fi
systemctl enable -q navidrome
systemctl restart navidrome
msg_ok "Navidrome listens on port 4533"

motd_ssh
customize
cleanup_lxc
