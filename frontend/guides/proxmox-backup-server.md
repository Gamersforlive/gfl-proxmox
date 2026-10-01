## Manual install

From Proxmox's no-subscription repository. On Debian 13, as root:

```bash
apt update && apt install -y curl
curl -fsSL https://enterprise.proxmox.com/debian/proxmox-archive-keyring-trixie.gpg -o /usr/share/keyrings/proxmox-archive-keyring.gpg
cat > /etc/apt/sources.list.d/pbs.sources <<'EOF'
Types: deb
URIs: http://download.proxmox.com/debian/pbs
Suites: trixie
Components: pbs-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
echo "$(hostname -I | awk '{print $1}') $(hostname)" >> /etc/hosts
apt update && apt install -y proxmox-backup-server
passwd root                                        # the web login is root@pam
proxmox-backup-manager datastore create backups /backup
```

Disable the enterprise repository it adds (`/etc/apt/sources.list.d/pbs-enterprise.*`) unless you have a subscription.

## Docker

Proxmox Backup Server isn't made for Docker. Run it in a container like this script does, in a VM from the official ISO, or on a separate machine (recommended for real backups).

## Using it

1. Open `https://<container-ip>:8007`, accept the certificate warning, and log in as `root` (realm **Linux PAM**) with the password from `/root/proxmox-backup-server.creds`.
2. The datastore **backups** already exists at `/backup`. Put it on big storage: mount a disk or NAS there (on the Proxmox host: `pct set <ID> -mp0 /mnt/bigdisk,mp=/backup`).
3. Copy the **Fingerprint** from the **Dashboard > Show Fingerprint** button.
4. On your Proxmox VE host: **Datacenter > Storage > Add > Proxmox Backup Server**: server `<container-ip>`, user `root@pam` and its password, datastore `backups`, and the fingerprint.
5. **Datacenter > Backup > Add**: choose the new storage, a schedule and all guests. Backups after the first one are quick: only changed chunks are sent.

On the backup server, set **Prune & GC** jobs (keep for example 7 daily, 4 weekly, 6 monthly) and a **Verify** job. Don't back up the backup server's own container to itself.
