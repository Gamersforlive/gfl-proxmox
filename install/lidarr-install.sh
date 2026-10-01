#!/usr/bin/env bash
# GFL Proxmox Scripts - Lidarr installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_servarr lidarr Lidarr 8686 "https://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64"

motd_ssh
customize
cleanup_lxc
