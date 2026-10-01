#!/usr/bin/env bash
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Installs the CPU microcode package (Intel or AMD) for security and stability fixes.

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "CPU microcode"

VENDOR=$(awk -F': ' '/vendor_id/ {print $2; exit}' /proc/cpuinfo)
case "$VENDOR" in
  GenuineIntel) PKG=intel-microcode ;;
  AuthenticAMD) PKG=amd64-microcode ;;
  *) msg_error "Unknown CPU vendor '${VENDOR}'."; exit 1 ;;
esac
msg_ok "CPU vendor: ${VENDOR}"

$STD apt-get update
if ! apt-cache show "$PKG" >/dev/null 2>&1; then
  msg_error "${PKG} is not available. Add 'non-free-firmware' to the Debian repository components, then run this again."
  exit 1
fi
confirm "CPU microcode" "Install ${PKG}? A reboot is needed to load it." || cancelled
msg_info "Installing ${PKG}"
DEBIAN_FRONTEND=noninteractive $STD apt-get install -y "$PKG"
msg_ok "Installed ${PKG}. Reboot the host to load it"
