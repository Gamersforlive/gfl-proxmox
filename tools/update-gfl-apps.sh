#!/usr/bin/env bash
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Runs each GFL container's own `update` command: the app and its OS packages, the right way
# for that app. Can take a snapshot of each container first so a bad update rolls back in a click.
#
# Unattended (cron): GFL_MODE=default SNAPSHOT=yes bash -c "$(curl ... update-gfl-apps.sh)"

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Update all GFL apps"

declare -a menu=()
while read -r id status _ name <&3; do
  [ "$status" = "running" ] || continue
  if ! pct config "$id" 2>/dev/null | grep -qE '^tags:.*\bgfl\b'; then continue; fi
  if ! pct exec "$id" -- test -x /usr/bin/update 2>/dev/null; then continue; fi
  menu+=("$id" "$name" "ON")
done 3< <(pct list | awk 'NR>1 {print $1, $2, $3, $NF}')
if [ "${#menu[@]}" -eq 0 ]; then
  msg_warn "No running GFL containers with an update command were found."
  exit 0
fi

if [ "${GFL_MODE:-}" = "default" ]; then
  PICKED=$(for ((i = 0; i < ${#menu[@]}; i += 3)); do echo "${menu[i]}"; done)
  SNAPSHOT="${SNAPSHOT:-no}"
else
  PICKED=$(whiptail --backtitle "$BACKTITLE" --title "Update GFL apps" --checklist \
    "Apps to update (space toggles):" 20 64 12 "${menu[@]}" 3>&1 1>&2 2>&3) || cancelled
  PICKED=$(echo "$PICKED" | tr -d '"')
  if [ -z "$PICKED" ]; then cancelled; fi
  SNAPSHOT=no
  if confirm "Snapshots" "Take a snapshot of each container before updating it?\n\nIf an update breaks an app, roll back under the container's Snapshots tab.\n(Needs storage that supports snapshots, like LVM-thin or ZFS.)"; then
    SNAPSHOT=yes
  fi
fi

declare -a ok=() failed=()
stamp=$(date +%Y%m%d-%H%M)
for id in $PICKED; do
  name=$(pct config "$id" | awk '/^hostname:/ {print $2}')
  if [ "$SNAPSHOT" = "yes" ]; then
    if pct snapshot "$id" "gfl-pre-update-${stamp}" -description "Before Update all GFL apps" >>"$GFL_LOG" 2>&1; then
      msg_ok "Snapshot gfl-pre-update-${stamp} of ${id} (${name})"
    else
      msg_warn "Could not snapshot ${id} (${name}); its storage may not support snapshots. Updating anyway"
    fi
  fi
  msg_info "Updating ${id} (${name})"
  if pct exec "$id" -- env TERM=dumb bash /usr/bin/update </dev/null >>"$GFL_LOG" 2>&1; then
    msg_ok "Updated ${id} (${name})"
    ok+=("${id} (${name})")
  else
    msg_error "Updating ${id} (${name}) failed; see ${GFL_LOG}"
    failed+=("${id} (${name})")
  fi
done

echo
msg_ok "Updated ${#ok[@]} app(s)"
if [ "${#failed[@]}" -gt 0 ]; then
  msg_error "Failed: ${failed[*]}"
  if [ "$SNAPSHOT" = "yes" ]; then echo -e "${INFO} Roll back with: ${BL}pct rollback <ID> gfl-pre-update-${stamp}${CL}"; fi
  exit 1
fi
if [ "$SNAPSHOT" = "yes" ]; then
  echo -e "${INFO} Happy with the updates? Remove the snapshots under each container's Snapshots tab to free space."
fi
