#!/usr/bin/env bash
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Updates the OS packages in every running container (Debian, Ubuntu and Alpine).

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Update all containers"

declare -a menu=()
while read -r id status _ name; do
  [ "$status" = "running" ] || continue
  menu+=("$id" "$name" "ON")
done < <(pct list | awk 'NR>1 {print $1, $2, $3, $NF}')
if [ "${#menu[@]}" -eq 0 ]; then
  msg_warn "No containers are running."
  exit 0
fi
if [ "${GFL_MODE:-}" = "default" ]; then
  # Unattended (for example from cron): update every running container.
  PICKED=$(pct list | awk 'NR>1 && $2=="running" {print $1}' | tr '\n' ' ')
else
  PICKED=$(whiptail --backtitle "$BACKTITLE" --title "Update containers" --checklist \
    "Running containers to update (space toggles):" 20 64 12 "${menu[@]}" 3>&1 1>&2 2>&3) || cancelled
fi

declare -a reboot_needed=() failed=()
for id in $(echo "$PICKED" | tr -d '"'); do
  name=$(pct config "$id" | awk '/^hostname:/ {print $2}')
  os=$(pct config "$id" | awk '/^ostype:/ {print $2}')
  msg_info "Updating ${id} (${name})"
  case "$os" in
    debian | ubuntu | devuan)
      cmd="export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get -y -o Dpkg::Options::=--force-confold dist-upgrade && apt-get -y autoremove && apt-get -y autoclean" ;;
    alpine)
      cmd="apk -U upgrade" ;;
    *)
      msg_warn "Skipped ${id} (${name}): ${os} is not supported"
      continue ;;
  esac
  if pct exec "$id" -- bash -c "$cmd" >>"$GFL_LOG" 2>&1 || pct exec "$id" -- sh -c "$cmd" >>"$GFL_LOG" 2>&1; then
    msg_ok "Updated ${id} (${name})"
    if pct exec "$id" -- test -e /var/run/reboot-required 2>/dev/null; then
      reboot_needed+=("${id} (${name})")
    fi
  else
    msg_error "Failed to update ${id} (${name}); see ${GFL_LOG}"
    failed+=("${id} (${name})")
  fi
done

echo
if [ "${#reboot_needed[@]}" -gt 0 ]; then
  msg_warn "These containers want a reboot: ${reboot_needed[*]}"
fi
if [ "${#failed[@]}" -gt 0 ]; then
  msg_error "These containers failed: ${failed[*]}"
  exit 1
fi
msg_ok "All selected containers are up to date"
