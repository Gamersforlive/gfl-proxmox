#!/usr/bin/env bash
# GFL Proxmox Scripts - AdGuard Home installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing AdGuard Home"
fetch https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh -o /tmp/adguard-install.sh
$STD sh /tmp/adguard-install.sh -v
rm -f /tmp/adguard-install.sh
msg_ok "Installed AdGuard Home"

motd_ssh
customize
cleanup_lxc
