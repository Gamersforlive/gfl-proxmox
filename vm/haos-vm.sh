#!/usr/bin/env bash
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Creates a Home Assistant OS virtual machine from the official image.
# Upstream: https://www.home-assistant.io/installation/generic-x86-64

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Home Assistant OS VM"

msg_info "Looking up the newest Home Assistant OS release"
VER=$(gh_latest home-assistant/operating-system)
msg_ok "Newest release: ${VER}"

VMID="${VMID:-$(pvesh get /cluster/nextid)}"
CORES="${CORES:-2}"
RAM="${RAM:-4096}"
DISK="${DISK:-32G}"
BRG="${BRG:-vmbr0}"
VLAN="${VLAN:-}"
NAME="${NAME:-haos}"
if [[ "$DISK" =~ ^[0-9]+$ ]]; then DISK="${DISK}G"; fi
if qm status "$VMID" >/dev/null 2>&1 || pct status "$VMID" >/dev/null 2>&1; then
  msg_error "ID ${VMID} is already used by another VM or container."
  exit 1
fi
if [ "${GFL_MODE:-}" != "default" ]; then
  confirm "Home Assistant OS" "Create VM ${VMID} (${NAME}) with Home Assistant OS ${VER}?\n\n${CORES} cores, ${RAM} MiB RAM, ${DISK} disk\nNetwork: ${BRG}${VLAN:+ VLAN ${VLAN}}, DHCP (set a fixed IP inside Home Assistant)\n(Change these on the website's Custom settings, or set VMID, NAME, CORES, RAM, DISK, BRG, VLAN before running.)" || cancelled
fi
pick_storage STORAGE images

URL="https://github.com/home-assistant/operating-system/releases/download/${VER}/haos_ova-${VER}.qcow2.xz"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"; stop_spinner' EXIT
msg_info "Downloading Home Assistant OS ${VER}"
fetch "$URL" -o "${TMP}/haos.qcow2.xz"
unxz "${TMP}/haos.qcow2.xz"
msg_ok "Downloaded Home Assistant OS ${VER}"

msg_info "Creating VM ${VMID}"
qm create "$VMID" -name "$NAME" -tags "gfl;smarthome" -machine q35 -bios ovmf -agent 1 \
  -cores "$CORES" -memory "$RAM" -net0 "virtio,bridge=${BRG}${VLAN:+,tag=${VLAN}}" -ostype l26 \
  -scsihw virtio-scsi-pci -onboot 1 -tablet 0 >>"$GFL_LOG"
qm set "$VMID" -efidisk0 "${STORAGE}:1,efitype=4m,pre-enrolled-keys=0" >>"$GFL_LOG"
qm set "$VMID" -scsi0 "${STORAGE}:0,import-from=${TMP}/haos.qcow2,discard=on,ssd=1" >>"$GFL_LOG"
qm set "$VMID" -boot order=scsi0 >>"$GFL_LOG"
qm resize "$VMID" scsi0 "$DISK" >>"$GFL_LOG"
qm set "$VMID" -description "<div align='center'><h2>Home Assistant OS ${VER}</h2><p>Installed with <a href='${GFL_SITE}'>GFL Proxmox Scripts</a></p></div>" >>"$GFL_LOG"
msg_ok "Created VM ${VMID}"

msg_info "Starting VM ${VMID}"
qm start "$VMID"
msg_ok "Started VM ${VMID}"
echo -e "\n${INFO} First boot takes a few minutes. Then open ${BL}http://homeassistant.local:8123${CL} (or the VM's IP, port 8123)."
echo -e "${INFO} Home Assistant updates itself from Settings > System > Updates.\n"
