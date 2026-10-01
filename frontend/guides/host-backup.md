## Doing it by hand

```bash
mkdir -p /mnt/pve/nas/host-backups
tar -czf "/mnt/pve/nas/host-backups/$(hostname)-config-$(date +%F).tar.gz" \
  /etc /root /var/lib/pve-cluster/config.db /var/spool/cron
```

## Using it

1. Run it on the Proxmox host and choose a folder, ideally on a NAS or USB disk (for example `/mnt/pve/nas/host-backups`).
2. It saves a dated archive with `/etc` (including all VM and container configs in `/etc/pve`), `/root` and the cluster database, and keeps the newest 10.
3. Copy the cron line it prints to back up every night.

### Restoring

On a freshly installed Proxmox host with the same name, unpack what you need, for example the network config:

```bash
tar -xzf pve-config-2026-10-01.tar.gz -C /tmp
cp /tmp/etc/network/interfaces /etc/network/interfaces
```

Guest configs are in `etc/pve/nodes/<host>/qemu-server/` and `lxc/` inside the archive; the guests' disks come from your normal Proxmox backups.
