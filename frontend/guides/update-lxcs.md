## Doing it by hand

```bash
for id in $(pct list | awk 'NR>1 && $2=="running" {print $1}'); do
  echo "== $id"
  pct exec "$id" -- bash -c "apt-get update && apt-get -y dist-upgrade"
done
```

## Using it

1. Run it on the Proxmox host. It lists the running containers; untick any you want to skip.
2. It updates Debian, Ubuntu (apt) and Alpine (apk) containers one by one.
3. At the end it lists containers that want a reboot after the update.

This updates the operating system packages of any container, GFL or not. For GFL apps, [Update all GFL apps](#update-gfl-apps) is better: it also updates apps that don't come from apt, like Docker images.

Run it from cron for weekly updates:

```bash
echo '0 3 * * 0 root GFL_MODE=default bash -c "$(curl -fsSL https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main/tools/update-lxcs.sh)"' > /etc/cron.d/gfl-update-lxcs
```
