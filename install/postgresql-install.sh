#!/usr/bin/env bash
# GFL Proxmox Scripts - PostgreSQL installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing PostgreSQL"
$STD apt-get install -y postgresql
PGCONF=$(find /etc/postgresql -mindepth 2 -maxdepth 2 -type d -name main | head -n1)
mkdir -p "${PGCONF}/conf.d"
echo "listen_addresses = '*'" >"${PGCONF}/conf.d/gfl.conf"
echo "host all all 0.0.0.0/0 scram-sha-256" >>"${PGCONF}/pg_hba.conf"
systemctl restart postgresql
msg_ok "Installed PostgreSQL $(basename "$(dirname "$PGCONF")")"

msg_info "Setting the postgres password"
PASS=$(gen_pw)
$STD runuser -u postgres -- psql -c "ALTER USER postgres WITH PASSWORD '${PASS}';"
save_creds "PostgreSQL" "user: postgres" "password: ${PASS}" "host: $(hostname -I | awk '{print $1}'):5432"
msg_ok "Saved the login to /root/postgresql.creds"

motd_ssh
customize
cleanup_lxc
