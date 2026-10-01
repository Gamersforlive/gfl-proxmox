## Doing it by hand

On Proxmox VE 9 (Debian 13 "trixie"), as root on the host:

```bash
# 1. Turn off the enterprise repositories (they need a subscription)
for f in /etc/apt/sources.list.d/pve-enterprise.sources /etc/apt/sources.list.d/ceph.sources; do
  [ -f "$f" ] && echo "Enabled: false" >> "$f"
done

# 2. Add the free no-subscription repository
cat > /etc/apt/sources.list.d/proxmox.sources <<'EOF'
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

# 3. Update
apt update && apt -y dist-upgrade
```

On Proxmox VE 8 the files end in `.list` instead: comment out the line in `pve-enterprise.list` and add `deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription` to a new `.list` file.

You can also do steps 1 and 2 in the web interface: **your node > Updates > Repositories**, disable the enterprise entries and **Add** the "No-Subscription" repository.

## Using it

Run it once on every new Proxmox host. Each step asks first:

1. **Disable the enterprise repositories**: yes, unless you pay for a subscription.
2. **Add the no-subscription repository**: yes, so you keep getting updates.
3. **Hide the subscription pop-up**: optional. It patches a UI file after every update; delete `/etc/apt/apt.conf.d/no-nag-script` to undo it, and clear your browser cache after changing it.
4. **Stop high availability**: only offered on hosts that aren't in a cluster. Say no if you plan to build one.
5. **Update** and **reboot**: yes on a fresh install, especially after a new kernel.

Running it again is safe; answer no to anything you've already done.
