#!/usr/bin/env bash
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# First-run setup for a fresh Proxmox VE 8 or 9 host without a subscription.
# Every step asks first.

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Post-install setup"

MAJOR=$(pve_major)
case "$MAJOR" in
  8) CODENAME=bookworm ;;
  9) CODENAME=trixie ;;
  *) msg_error "Proxmox VE ${MAJOR} is not supported by this script (8 and 9 are)."; exit 1 ;;
esac
msg_ok "Proxmox VE ${MAJOR} (Debian ${CODENAME})"

disable_source() { # disable a deb822 .sources file or comment out a .list file
  local f="$1"
  [ -f "$f" ] || return 0
  if [[ "$f" == *.sources ]]; then
    if grep -q '^Enabled:' "$f"; then
      sed -i 's/^Enabled:.*/Enabled: false/' "$f"
    else
      echo "Enabled: false" >>"$f"
    fi
  else
    sed -i 's/^\([^#]\)/# \1/' "$f"
  fi
}

if confirm "Enterprise repositories" "The enterprise repositories need a paid subscription and make 'apt update' fail without one.\n\nDisable them?"; then
  for f in /etc/apt/sources.list.d/pve-enterprise.{list,sources} /etc/apt/sources.list.d/ceph.{list,sources}; do
    disable_source "$f"
  done
  msg_ok "Disabled the enterprise repositories"
fi

if confirm "No-subscription repository" "Add the free 'pve-no-subscription' repository so you keep getting updates?"; then
  if [ "$MAJOR" = "9" ]; then
    cat >/etc/apt/sources.list.d/proxmox.sources <<EOF
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: ${CODENAME}
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
  else
    echo "deb http://download.proxmox.com/debian/pve ${CODENAME} pve-no-subscription" >/etc/apt/sources.list.d/pve-no-subscription.list
  fi
  msg_ok "Added the pve-no-subscription repository"
fi

if confirm "Subscription pop-up" "Hide the 'No valid subscription' pop-up in the web UI?\n\nThis patches a Proxmox UI file after every update. It is unofficial; undo it by deleting /etc/apt/apt.conf.d/no-nag-script."; then
  cat >/etc/apt/apt.conf.d/no-nag-script <<'EOF'
DPkg::Post-Invoke { "if [ -s /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js ] && ! grep -q -F 'NoMoreNagging' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; then sed -i '/data\.status/{s/\!//;s/active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; fi"; };
EOF
  msg_info "Reinstalling the UI toolkit to apply it"
  $STD apt-get --reinstall install -y proxmox-widget-toolkit
  msg_ok "Hid the subscription pop-up (clear your browser cache)"
fi

if [ ! -f /etc/pve/corosync.conf ] && confirm "High availability" "This host is not in a cluster. Stop the high-availability services to save a little CPU and disk wear?\n\nChoose No if you plan to build a cluster soon."; then
  systemctl disable -q --now pve-ha-lrm pve-ha-crm corosync 2>/dev/null || true
  msg_ok "Stopped the high-availability services"
fi

if confirm "Update" "Update Proxmox VE now? (apt dist-upgrade)"; then
  msg_info "Updating Proxmox VE (this can take a while)"
  $STD apt-get update
  DEBIAN_FRONTEND=noninteractive $STD apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade
  msg_ok "Updated Proxmox VE"
fi

if confirm "Reboot" "Reboot the host now? (recommended after a kernel update)"; then
  msg_ok "Rebooting"
  reboot
fi
msg_ok "Post-install setup finished"
