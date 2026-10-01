#!/usr/bin/env bash
# GFL Proxmox Scripts - Mosquitto (MQTT broker) installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Mosquitto"
$STD apt-get install -y mosquitto mosquitto-clients
msg_ok "Installed Mosquitto"

msg_info "Turning on logins"
PASS=$(gen_pw)
mosquitto_passwd -b -c /etc/mosquitto/passwd gfl "$PASS"
chown mosquitto:mosquitto /etc/mosquitto/passwd
chmod 700 /etc/mosquitto/passwd
cat >/etc/mosquitto/conf.d/gfl.conf <<'CONF'
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
CONF
systemctl restart mosquitto
save_creds "Mosquitto MQTT" "user: gfl" "password: ${PASS}" "host: $(hostname -I | awk '{print $1}'):1883"
msg_ok "Saved the login to /root/mosquitto.creds"

motd_ssh
customize
cleanup_lxc
