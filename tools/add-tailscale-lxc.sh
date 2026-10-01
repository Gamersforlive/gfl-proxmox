#!/usr/bin/env bash
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Adds Tailscale to an existing Debian/Ubuntu container: passes /dev/net/tun in and installs it.

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Add Tailscale to a container"

pick_ct CTID "Which container should get Tailscale?"
OS=$(pct config "$CTID" | awk '/^ostype:/ {print $2}')
if [ "$OS" != "debian" ] && [ "$OS" != "ubuntu" ]; then
  msg_error "Container ${CTID} runs ${OS}; this tool supports Debian and Ubuntu."
  exit 1
fi
confirm "Tailscale" "Add Tailscale to container ${CTID}?\n\nThe container restarts once." || cancelled

if ! pct config "$CTID" | grep -q '/dev/net/tun'; then
  DEV=$(next_dev_index "$CTID")
  pct set "$CTID" "-dev${DEV}" "/dev/net/tun,mode=0666" >/dev/null
  msg_ok "Passed /dev/net/tun into ${CTID}"
fi
msg_info "Restarting container ${CTID}"
if pct status "$CTID" | grep -q running; then pct reboot "$CTID"; else pct start "$CTID"; fi
sleep 5
msg_ok "Container ${CTID} is running"

msg_info "Installing Tailscale in ${CTID}"
pct exec "$CTID" -- bash -c "apt-get update && apt-get install -y curl && curl -fsSL https://tailscale.com/install.sh | sh" >>"$GFL_LOG" 2>&1
msg_ok "Installed Tailscale in ${CTID}"
echo -e "\n${INFO} Sign it in: ${BL}pct exec ${CTID} -- tailscale up${CL} and open the link it prints.\n"
