#!/usr/bin/env bash
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Removes old Proxmox kernels. Never touches the running kernel or the newest installed one.

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Clean old kernels"

RUNNING=$(uname -r)
mapfile -t KERNELS < <(dpkg-query -W -f='${Status} ${Package}\n' 'proxmox-kernel-*-pve-signed' 'pve-kernel-*-pve' 2>/dev/null |
  awk '/install ok installed/ {print $4}' | sort -V)
if [ "${#KERNELS[@]}" -eq 0 ]; then
  msg_ok "No versioned kernel packages found"
  exit 0
fi
NEWEST="${KERNELS[-1]}"
msg_ok "Running kernel: ${RUNNING}"

declare -a menu=()
for k in "${KERNELS[@]}"; do
  if [[ "$k" == *"$RUNNING"* ]] || [ "$k" = "$NEWEST" ]; then continue; fi
  menu+=("$k" "" "OFF")
done
if [ "${#menu[@]}" -eq 0 ]; then
  msg_ok "Nothing to clean: only the running and newest kernels are installed"
  exit 0
fi
PICKED=$(whiptail --backtitle "$BACKTITLE" --title "Old kernels" --checklist \
  "Kernels to remove (space toggles). The running and newest kernels are not listed." 20 72 12 "${menu[@]}" 3>&1 1>&2 2>&3) || cancelled
PICKED=$(echo "$PICKED" | tr -d '"')
if [ -z "$PICKED" ]; then cancelled; fi
confirm "Remove kernels" "Remove these kernels?\n\n${PICKED// /\\n}" || cancelled

msg_info "Removing old kernels"
# shellcheck disable=SC2086
DEBIAN_FRONTEND=noninteractive $STD apt-get purge -y $PICKED
$STD proxmox-boot-tool refresh || $STD update-grub
msg_ok "Removed: ${PICKED}"
