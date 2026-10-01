#!/usr/bin/env bash
# GFL Proxmox Scripts - Sonarr installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_servarr sonarr Sonarr 8989 "https://services.sonarr.tv/v1/download/main/latest?version=4&os=linux&arch=x64"

motd_ssh
customize
cleanup_lxc
