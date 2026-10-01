#!/usr/bin/env bash
# GFL Proxmox Scripts - Proxmox Backup Server installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Adding the Proxmox Backup Server repository"
. /etc/os-release
# PBS, like Proxmox VE, wants its hostname to resolve to its own address.
IP=$(hostname -I | awk '{print $1}')
if ! grep -q "$(hostname)" /etc/hosts; then echo "${IP} $(hostname)" >>/etc/hosts; fi
add_repo pbs "https://enterprise.proxmox.com/debian/proxmox-archive-keyring-${VERSION_CODENAME}.gpg" \
  http://download.proxmox.com/debian/pbs "$VERSION_CODENAME" pbs-no-subscription
msg_ok "Added the Proxmox Backup Server repository"

msg_info "Installing Proxmox Backup Server (a few minutes)"
$STD apt-get install -y proxmox-backup-server
# The package adds the enterprise repository, which needs a subscription; turn it off.
for f in /etc/apt/sources.list.d/pbs-enterprise.list /etc/apt/sources.list.d/pbs-enterprise.sources; do
  if [ -f "$f" ]; then
    if [[ "$f" == *.sources ]]; then echo "Enabled: false" >>"$f"; else sed -i 's/^deb/# deb/' "$f"; fi
  fi
done
msg_ok "Installed Proxmox Backup Server"

msg_info "Setting up the login and a datastore"
# The web login is root@pam, so root needs a password.
PASS=$(gen_pw)
echo "root:${PASS}" | chpasswd
mkdir -p /backup
chown backup:backup /backup
if ! proxmox-backup-manager datastore list 2>/dev/null | grep -q backups; then
  $STD proxmox-backup-manager datastore create backups /backup
fi
save_creds "Proxmox Backup Server" "user: root@pam" "password: ${PASS}" "address: https://${IP}:8007"
msg_ok "Saved the login to /root/proxmox-backup-server.creds"

motd_ssh
customize
cleanup_lxc
