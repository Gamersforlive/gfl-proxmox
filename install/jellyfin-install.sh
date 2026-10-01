#!/usr/bin/env bash
# GFL Proxmox Scripts - Jellyfin installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Adding the Jellyfin repository"
. /etc/os-release
add_repo jellyfin https://repo.jellyfin.org/jellyfin_team.gpg.key "https://repo.jellyfin.org/${ID}" "$VERSION_CODENAME" main
msg_ok "Added the Jellyfin repository"

msg_info "Installing Jellyfin"
$STD apt-get install -y jellyfin
systemctl enable -q --now jellyfin
msg_ok "Installed Jellyfin"

if [ "${GPU:-no}" = "yes" ]; then
  msg_info "Installing GPU drivers for hardware transcoding"
  $STD apt-get install -y va-driver-all vainfo
  for g in video render; do
    if getent group "$g" >/dev/null; then usermod -aG "$g" jellyfin; fi
  done
  systemctl restart jellyfin
  msg_ok "Installed GPU drivers (check them with: vainfo)"
fi

mkdir -p /data/media/movies /data/media/tv
chown -R jellyfin:jellyfin /data/media

motd_ssh
customize
cleanup_lxc
