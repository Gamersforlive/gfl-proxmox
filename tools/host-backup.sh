#!/usr/bin/env bash
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Backs up the host's own configuration (/etc including /etc/pve, /root, the cluster database).
# Guests are backed up by Proxmox itself (Datacenter > Backup); this covers the host.

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Host config backup"

DEST="${DEST:-}"
KEEP="${KEEP:-10}"
if [ -z "$DEST" ]; then
  DEST=$(whiptail --backtitle "$BACKTITLE" --title "Backup folder" --inputbox \
    "Folder to save the backup in. A NAS or USB mount (for example /mnt/pve/nas) is safer than this host's own disk." 10 70 "/root/host-backups" 3>&1 1>&2 2>&3) || cancelled
fi
mkdir -p "$DEST"
FILE="${DEST}/$(hostname)-config-$(date +%Y-%m-%d_%H%M).tar.gz"

msg_info "Backing up the host configuration"
tar -czf "$FILE" --warning=no-file-changed --ignore-failed-read \
  /etc /root /var/lib/pve-cluster/config.db /var/spool/cron 2>>"$GFL_LOG" || [ $? -eq 1 ]
msg_ok "Saved $(du -h "$FILE" | cut -f1) to ${FILE}"

mapfile -t OLD < <(ls -1t "${DEST}/$(hostname)"-config-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)))
if [ "${#OLD[@]}" -gt 0 ]; then
  rm -f "${OLD[@]}"
  msg_ok "Removed ${#OLD[@]} old backup(s); keeping the newest ${KEEP}"
fi
echo -e "\n${INFO} Run this daily: ${BL}echo '0 3 * * * root DEST=${DEST} GFL_MODE=default bash -c \"\$(curl -fsSL ${GFL_RAW}/tools/host-backup.sh)\"' > /etc/cron.d/gfl-host-backup${CL}\n"
