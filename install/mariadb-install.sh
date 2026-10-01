#!/usr/bin/env bash
# GFL Proxmox Scripts - MariaDB installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing MariaDB"
$STD apt-get install -y mariadb-server
cat >/etc/mysql/mariadb.conf.d/99-gfl.cnf <<'CNF'
[mysqld]
bind-address = 0.0.0.0
CNF
systemctl restart mariadb
msg_ok "Installed MariaDB"

msg_info "Creating an admin user"
PASS=$(gen_pw)
mariadb -e "CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY '${PASS}'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"
save_creds "MariaDB" "user: admin" "password: ${PASS}" "host: $(hostname -I | awk '{print $1}'):3306"
msg_ok "Saved the login to /root/mariadb.creds"

motd_ssh
customize
cleanup_lxc
