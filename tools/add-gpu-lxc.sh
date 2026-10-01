#!/usr/bin/env bash
# GFL Proxmox Scripts · MIT · https://github.com/gamersforlive/gfl-proxmox
# Passes the host's Intel/AMD GPU (/dev/dri) into an existing container, for transcoding or AI.

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Add GPU to a container"

if ! ls /dev/dri/renderD* >/dev/null 2>&1; then
  msg_error "No /dev/dri render device on this host. Is an Intel/AMD GPU present with its driver loaded?"
  exit 1
fi
pick_ct CTID "Which container should get the GPU?"
confirm "GPU passthrough" "Pass these devices into container ${CTID}?\n\n$(ls /dev/dri/renderD* /dev/dri/card* 2>/dev/null | tr '\n' ' ')\n\nThe container restarts once." || cancelled

for node in /dev/dri/renderD* /dev/dri/card*; do
  [ -e "$node" ] || continue
  if pct config "$CTID" | grep -q "${node},"; then continue; fi
  DEV=$(next_dev_index "$CTID")
  pct set "$CTID" "-dev${DEV}" "${node},mode=0666" >/dev/null
  msg_ok "Added ${node} as dev${DEV}"
done
if pct status "$CTID" | grep -q running; then
  msg_info "Restarting container ${CTID}"
  pct reboot "$CTID"
  msg_ok "Restarted container ${CTID}"
fi
echo -e "\n${INFO} Check it inside the container: ${BL}apt install vainfo && vainfo${CL}\n"
