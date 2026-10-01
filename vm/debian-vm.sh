#!/usr/bin/env bash
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Creates a Debian 13 virtual machine from the official cloud image, set up with cloud-init.
# Upstream: https://cloud.debian.org/images/cloud/

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Debian 13 VM"

VMID="${VMID:-$(pvesh get /cluster/nextid)}"
NAME="${NAME:-debian}"
CORES="${CORES:-2}"
RAM="${RAM:-2048}"
DISK="${DISK:-32G}"
BRG="${BRG:-vmbr0}"
VLAN="${VLAN:-}"
NET="${NET:-dhcp}"
GATE="${GATE:-}"
NS="${NS:-}"
CIUSER="${CIUSER:-gfl}"
if [[ "$DISK" =~ ^[0-9]+$ ]]; then DISK="${DISK}G"; fi
if [ "$NET" != "dhcp" ] && ! [[ "$NET" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
  msg_error "NET must be dhcp or an address like 192.168.1.60/24 (got '${NET}')"
  exit 1
fi
if qm status "$VMID" >/dev/null 2>&1 || pct status "$VMID" >/dev/null 2>&1; then
  msg_error "ID ${VMID} is already used by another VM or container."
  exit 1
fi

confirm "Debian 13 VM" "Create VM ${VMID} (${NAME}) running Debian 13?\n\n${CORES} cores, ${RAM} MiB RAM, ${DISK} disk\nNetwork: ${BRG}${VLAN:+ VLAN ${VLAN}}, ${NET}${GATE:+ via ${GATE}}\nYou log in as '${CIUSER}'.\n(Change these on the website's Custom settings, or set VMID, NAME, CORES, RAM, DISK, BRG, NET, GATE before running.)" || cancelled
PW=$(whiptail --backtitle "$BACKTITLE" --title "Password" --passwordbox "Password for the user '${CIUSER}':" 10 64 3>&1 1>&2 2>&3) || cancelled
if [ -z "$PW" ]; then
  msg_error "A password is required."
  exit 1
fi
SSHKEY=""
if [ -f /root/.ssh/authorized_keys ] && confirm "SSH keys" "Also let the SSH keys from this host's /root/.ssh/authorized_keys log in?"; then
  SSHKEY=/root/.ssh/authorized_keys
fi
pick_storage STORAGE images

URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"; stop_spinner' EXIT
msg_info "Downloading the Debian 13 cloud image"
fetch "$URL" -o "${TMP}/debian.qcow2"
msg_ok "Downloaded the Debian 13 cloud image"

msg_info "Creating VM ${VMID}"
qm create "$VMID" -name "$NAME" -tags "gfl;debian" -agent 1 -cores "$CORES" -memory "$RAM" \
  -net0 "virtio,bridge=${BRG}${VLAN:+,tag=${VLAN}}" -ostype l26 -scsihw virtio-scsi-single -serial0 socket -vga serial0 -onboot 1 >>"$GFL_LOG"
qm set "$VMID" -scsi0 "${STORAGE}:0,import-from=${TMP}/debian.qcow2,discard=on,ssd=1" >>"$GFL_LOG"
qm set "$VMID" -ide2 "${STORAGE}:cloudinit" -boot order=scsi0 >>"$GFL_LOG"
IPCONF="ip=${NET}"
if [ -n "$GATE" ]; then IPCONF+=",gw=${GATE}"; fi
qm set "$VMID" -ciuser "$CIUSER" -cipassword "$PW" -ipconfig0 "$IPCONF" -ciupgrade 1 >>"$GFL_LOG"
if [ -n "$NS" ]; then qm set "$VMID" -nameserver "$NS" >>"$GFL_LOG"; fi
if [ -n "$SSHKEY" ]; then qm set "$VMID" -sshkeys "$SSHKEY" >>"$GFL_LOG"; fi
qm resize "$VMID" scsi0 "$DISK" >>"$GFL_LOG"
qm set "$VMID" -description "<div align='center'><h2>Debian 13</h2><p>Installed with <a href='${GFL_SITE}'>GFL Proxmox Scripts</a></p></div>" >>"$GFL_LOG"
msg_ok "Created VM ${VMID}"

msg_info "Starting VM ${VMID}"
qm start "$VMID"
msg_ok "Started VM ${VMID}"
echo -e "\n${INFO} Log in on the VM's console (xterm.js) or over SSH as ${BL}${CIUSER}${CL}."
echo -e "${INFO} Recommended first step inside the VM: ${BL}sudo apt install qemu-guest-agent && sudo systemctl start qemu-guest-agent${CL}\n"
