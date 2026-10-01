#!/usr/bin/env bash
# GFL Proxmox Scripts - Prowlarr installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_servarr prowlarr Prowlarr 9696 "https://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64"

motd_ssh
customize
cleanup_lxc
