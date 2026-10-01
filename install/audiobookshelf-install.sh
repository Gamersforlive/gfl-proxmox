#!/usr/bin/env bash
# GFL Proxmox Scripts - Audiobookshelf installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Adding the Audiobookshelf repository"
add_repo audiobookshelf https://advplyr.github.io/audiobookshelf-ppa/KEY.gpg https://advplyr.github.io/audiobookshelf-ppa ./
msg_ok "Added the Audiobookshelf repository"

msg_info "Installing Audiobookshelf"
$STD apt-get install -y audiobookshelf
prep_media_dirs /data /data/media /data/media/audiobooks /data/media/podcasts
join_media_group audiobookshelf 2>/dev/null || true
systemctl enable -q --now audiobookshelf
msg_ok "Installed Audiobookshelf"

motd_ssh
customize
cleanup_lxc
