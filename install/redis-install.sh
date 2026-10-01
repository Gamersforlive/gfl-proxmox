#!/usr/bin/env bash
# GFL Proxmox Scripts - Redis installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Redis"
$STD apt-get install -y redis-server
msg_ok "Installed Redis"

msg_info "Opening Redis to the network with a password"
PASS=$(gen_pw)
# Later lines in redis.conf win, so appending overrides the localhost-only defaults.
cat >>/etc/redis/redis.conf <<CONF

# Added by GFL Proxmox Scripts
bind 0.0.0.0 -::*
requirepass ${PASS}
CONF
systemctl restart redis-server
save_creds "Redis" "password: ${PASS}" "host: $(hostname -I | awk '{print $1}'):6379"
msg_ok "Saved the password to /root/redis.creds"

motd_ssh
customize
cleanup_lxc
