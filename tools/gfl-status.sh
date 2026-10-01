#!/usr/bin/env bash
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Lists every container made with GFL Proxmox Scripts: app, status, address and pending updates.
# Read-only: it changes nothing.

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "GFL status"

# app_info <ctid> -> "slug|url" for a running container
app_info() {
  local id="$1" info slug port proto path ip
  info=$(pct exec "$id" -- cat /etc/gfl-app 2>/dev/null || true)
  slug=$(sed -n 's/^GFL_SLUG="\(.*\)"/\1/p' <<<"$info")
  port=$(sed -n 's/^GFL_PORT="\(.*\)"/\1/p' <<<"$info")
  proto=$(sed -n 's/^GFL_PROTO="\(.*\)"/\1/p' <<<"$info")
  path=$(sed -n 's/^GFL_PATH="\(.*\)"/\1/p' <<<"$info")
  if [ -z "$slug" ]; then
    # Containers made before /etc/gfl-app existed: the update command names the app.
    slug=$(pct exec "$id" -- cat /usr/bin/update 2>/dev/null | sed -n 's|.*/ct/\([a-z0-9-]*\)\.sh.*|\1|p' | tail -n1 || true)
  fi
  ip=$(pct exec "$id" -- hostname -I 2>/dev/null | awk '{print $1}' || true)
  if [ -n "$port" ] && [ -n "$ip" ]; then
    echo "${slug:-?}|${proto:-http}://${ip}:${port}${path}"
  else
    echo "${slug:-?}|${ip:--}"
  fi
}

pending_updates() { # uses the container's cached package lists; quick and changes nothing
  pct exec "$1" -- sh -c 'apt-get -s -o Debug::NoLocking=1 dist-upgrade 2>/dev/null | grep -c "^Inst " || true' 2>/dev/null | tail -n1
}

printf "\n  ${BOLD}%-6s %-9s %-18s %-20s %-8s %s${CL}\n" "ID" "STATUS" "NAME" "APP" "UPDATES" "OPEN"
count=0 running=0 behind=0
while read -r id status _ name <&3; do
  if ! pct config "$id" 2>/dev/null | grep -qE '^tags:.*\bgfl\b'; then continue; fi
  count=$((count + 1))
  if [ "$status" = "running" ]; then
    running=$((running + 1))
    IFS='|' read -r slug url <<<"$(app_info "$id")"
    upd=$(pending_updates "$id")
    if [ "${upd:-0}" -gt 0 ] 2>/dev/null; then behind=$((behind + 1)); upd="${YW}${upd}${CL}"; else upd="${GN}0${CL}"; fi
    printf "  %-6s ${GN}%-9s${CL} %-18s %-20s %-8b %s\n" "$id" "$status" "$name" "$slug" "$upd" "${BL}${url}${CL}"
  else
    printf "  %-6s ${YW}%-9s${CL} %-18s %-20s %-8s %s\n" "$id" "$status" "$name" "-" "-" "-"
  fi
done 3< <(pct list | awk 'NR>1 {print $1, $2, $3, $NF}')

echo
if [ "$count" -eq 0 ]; then
  msg_warn "No containers made with GFL Proxmox Scripts were found (they carry the 'gfl' tag)."
  exit 0
fi
msg_ok "${count} GFL container(s), ${running} running"
if [ "$behind" -gt 0 ]; then
  echo -e "${INFO} ${behind} container(s) have OS updates waiting. Update everything with:"
  echo -e "     ${BL}bash -c \"\$(curl -fsSL ${GFL_RAW}/tools/update-gfl-apps.sh)\"${CL}"
fi
echo -e "${INFO} Update counts come from each container's last package-list refresh.\n"
