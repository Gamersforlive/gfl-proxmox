#!/usr/bin/env bash
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Mounts an SMB/CIFS or NFS share (a NAS, TrueNAS, Windows share...) on the Proxmox host and
# passes it into the containers you pick, for example Radarr, Sonarr, qBittorrent and Jellyfin.
#
# Unprivileged containers can't mount network shares themselves (the kernel doesn't allow it),
# so the host mounts the share and each container gets it as a bind mount.

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Mount a NAS share into containers"

ask_box() { # ask_box VAR "Title" "Question" "default"
  local answer
  answer=$(whiptail --backtitle "$BACKTITLE" --title "$2" --inputbox "$3" 11 72 "$4" 3>&1 1>&2 2>&3) || cancelled
  printf -v "$1" '%s' "$answer"
}

TYPE=$(whiptail --backtitle "$BACKTITLE" --title "Share type" --menu "What kind of share is it?" 12 72 2 \
  "smb" "SMB / CIFS (Windows, Synology, TrueNAS, Unraid...)" \
  "nfs" "NFS (Linux, TrueNAS, Synology with NFS turned on)" 3>&1 1>&2 2>&3) || cancelled

ask_box SERVER "Server" "IP address or hostname of the NAS (example: 192.168.1.10)" ""
if [ "$TYPE" = "smb" ]; then
  ask_box SHARE "Share" "Share name, as you'd type after \\\\server\\ (example: media)" "media"
  SOURCE="//${SERVER}/${SHARE}"
else
  ask_box SHARE "Export" "Exported path on the NAS (example: /volume1/media or /mnt/tank/media)" "/"
  SOURCE="${SERVER}:${SHARE}"
fi
DEFAULT_NAME=$(echo "${SERVER}-${SHARE##*/}" | tr -c 'a-zA-Z0-9-\n' '-' | tr '[:upper:]' '[:lower:]')
ask_box NAME "Name" "A short name for this share. It's mounted on the host at /mnt/gfl/<name>." "$DEFAULT_NAME"
NAME=$(echo "$NAME" | tr -c 'a-zA-Z0-9-\n' '-')
MNT="/mnt/gfl/${NAME}"

if grep -q "# gfl-share ${NAME}$" /etc/fstab; then
  msg_error "A share named ${NAME} already exists in /etc/fstab. Pick another name, or remove that line first."
  exit 1
fi

# Unprivileged containers see host uid/gid 101000 as their own 1000, which is the "media"
# group the media apps run in. Files on an SMB share are presented as owned by that ID.
OWNER_ID=101000

if [ "$TYPE" = "smb" ]; then
  ask_box SMBUSER "Login" "SMB user name (leave empty for a guest share)" ""
  CRED="/etc/gfl/shares/${NAME}.cred"
  OPTS="uid=${OWNER_ID},gid=${OWNER_ID},file_mode=0775,dir_mode=0775,iocharset=utf8"
  if [ -n "$SMBUSER" ]; then
    SMBPASS=$(whiptail --backtitle "$BACKTITLE" --title "Login" --passwordbox "Password for ${SMBUSER}" 9 72 3>&1 1>&2 2>&3) || cancelled
    mkdir -p /etc/gfl/shares
    chmod 700 /etc/gfl/shares
    umask 077
    printf 'username=%s\npassword=%s\n' "$SMBUSER" "$SMBPASS" >"$CRED"
    umask 022
    unset SMBPASS
    OPTS+=",credentials=${CRED}"
  else
    OPTS+=",guest"
  fi
  FSTYPE=cifs
  PKG=cifs-utils
else
  OPTS="rw,hard"
  FSTYPE=nfs
  PKG=nfs-common
fi
# Mount on first use and never block the host's boot if the NAS is down.
OPTS+=",_netdev,nofail,x-systemd.automount,x-systemd.mount-timeout=30"

if ! dpkg -s "$PKG" >/dev/null 2>&1; then
  msg_info "Installing ${PKG}"
  $STD apt-get install -y "$PKG"
  msg_ok "Installed ${PKG}"
fi

msg_info "Mounting ${SOURCE} at ${MNT}"
mkdir -p "$MNT"
printf '%s %s %s %s 0 0 # gfl-share %s\n' "$SOURCE" "$MNT" "$FSTYPE" "$OPTS" "$NAME" >>/etc/fstab
systemctl daemon-reload
if ! mount "$MNT" 2>>"$GFL_LOG" || ! ls "$MNT" >/dev/null 2>&1; then
  sed -i "\|# gfl-share ${NAME}$|d" /etc/fstab
  systemctl daemon-reload
  if [ -f "/etc/gfl/shares/${NAME}.cred" ]; then rm -f "/etc/gfl/shares/${NAME}.cred"; fi
  msg_error "Could not mount ${SOURCE}. Check the address, share name and login. Details: ${GFL_LOG}"
  exit 1
fi
msg_ok "Mounted ${SOURCE} at ${MNT} (it comes back after a reboot)"
if [ "$TYPE" = "nfs" ]; then
  msg_warn "NFS keeps the NAS's own file owners. Let uid/gid ${OWNER_ID} write, or map all users to it on the NAS (all_squash, anonuid=${OWNER_ID}, anongid=${OWNER_ID})."
fi

# ---- pass it into containers ---------------------------------------------------------
declare -a menu=()
while read -r id _ _ name; do
  menu+=("$id" "$name" "OFF")
done < <(pct list | awk 'NR>1 {print $1, $2, $3, $NF}')
if [ "${#menu[@]}" -eq 0 ]; then
  msg_ok "No containers yet. New containers can use it: set 'Host folder to mount' to ${MNT} on the website."
  exit 0
fi
PICKED=$(whiptail --backtitle "$BACKTITLE" --title "Containers" --checklist \
  "Which containers should get this share? (space toggles)" 20 72 12 "${menu[@]}" 3>&1 1>&2 2>&3) || cancelled
PICKED=$(echo "$PICKED" | tr -d '"')
if [ -z "$PICKED" ]; then
  msg_ok "Share mounted on the host only. Run this tool again to add it to containers."
  exit 0
fi
ask_box INSIDE "Path inside" "Where should the share appear inside the containers?\nThe media apps from this site use /data." "/data"

declare -a restart=()
for id in $PICKED; do
  if pct config "$id" | grep -qE "^mp[0-9]+:.*mp=${INSIDE}(,|$)"; then
    msg_warn "Container ${id} already has something mounted at ${INSIDE}; skipped"
    continue
  fi
  i=0
  while pct config "$id" | grep -q "^mp${i}:"; do i=$((i + 1)); done
  pct set "$id" "-mp${i}" "${MNT},mp=${INSIDE}" >/dev/null
  msg_ok "Added ${MNT} to container ${id} at ${INSIDE}"
  if [ "$(pct config "$id" | awk '/^unprivileged:/ {print $2}')" != "1" ]; then
    msg_warn "Container ${id} is privileged: there, files on SMB shares belong to uid ${OWNER_ID}, not 1000"
  fi
  if pct status "$id" | grep -q running; then restart+=("$id"); fi
done

if [ "${#restart[@]}" -gt 0 ] && confirm "Restart" "These containers need a restart to see the share:\n\n${restart[*]}\n\nRestart them now?"; then
  for id in "${restart[@]}"; do
    msg_info "Restarting ${id}"
    pct reboot "$id"
    msg_ok "Restarted ${id}"
  done
fi
echo -e "\n${INFO} Done. In Radarr, Sonarr and qBittorrent use paths under ${BL}${INSIDE}${CL}; in Jellyfin or Plex add ${BL}${INSIDE}/media${CL} (or wherever your media lives).\n"
