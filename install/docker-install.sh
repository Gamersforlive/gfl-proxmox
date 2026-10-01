#!/usr/bin/env bash
# GFL Proxmox Scripts - Docker installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

motd_ssh
customize
cleanup_lxc
