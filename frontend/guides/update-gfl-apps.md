## Doing it by hand

Every GFL container has an `update` command that updates its app the right way. Run it per container:

```bash
pct snapshot 105 before-update     # optional, needs LVM-thin or ZFS storage
pct exec 105 -- update
```

Roll back if something broke: `pct rollback 105 before-update`. Remove the snapshot once you're happy: `pct delsnapshot 105 before-update`.

## Using it

1. Run it on the Proxmox host. It lists every running GFL container; untick any you want to skip.
2. Choose whether to take a snapshot of each container first. Recommended: if an update breaks an app, roll back under the container's **Snapshots** tab.
3. It updates them one by one and lists any that failed. Details are in `/var/log/gfl-tools.log`.

### Automatic updates

Run it every Sunday at 4:00 with a snapshot first, from cron on the host:

```bash
echo '0 4 * * 0 root GFL_MODE=default SNAPSHOT=yes bash -c "$(curl -fsSL https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main/tools/update-gfl-apps.sh)"' > /etc/cron.d/gfl-update-apps
```

Snapshots pile up with automatic runs. Delete old `gfl-pre-update-...` snapshots from time to time to free space.
