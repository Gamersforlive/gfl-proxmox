## Doing it by hand

Mount the share on the Proxmox host, then pass it into containers. SMB example (a NAS at 192.168.1.10 with a share called `media`):

```bash
apt install -y cifs-utils
mkdir -p /etc/gfl/shares /mnt/gfl/nas-media
printf 'username=you\npassword=secret\n' > /etc/gfl/shares/nas-media.cred
chmod 600 /etc/gfl/shares/nas-media.cred
echo '//192.168.1.10/media /mnt/gfl/nas-media cifs credentials=/etc/gfl/shares/nas-media.cred,uid=101000,gid=101000,file_mode=0775,dir_mode=0775,iocharset=utf8,_netdev,nofail,x-systemd.automount 0 0' >> /etc/fstab
systemctl daemon-reload && mount /mnt/gfl/nas-media
pct set 105 -mp0 /mnt/gfl/nas-media,mp=/data
pct reboot 105
```

NFS example: `apt install -y nfs-common`, and the fstab line `192.168.1.10:/volume1/media /mnt/gfl/nas-media nfs rw,hard,_netdev,nofail,x-systemd.automount 0 0`.

### Why uid 101000?

Unprivileged containers shift every user and group ID by 100000. ID 1000 inside (the `media` group the media apps use) is 101000 on the host, so the share is mounted as that ID.

## Using it

1. Run it on the Proxmox host.
2. Choose SMB or NFS, then enter the NAS address and the share name (SMB) or export path (NFS).
3. Give the share a short name; it's mounted at `/mnt/gfl/<name>` and comes back after every reboot.
4. For SMB, enter the login (or leave it empty for a guest share). It's stored in `/etc/gfl/shares/`, readable only by root.
5. Tick the containers that should get the share and where it should appear inside (`/data` for the media apps). Restart them when asked.

For new apps, put the share in **Custom settings > Host folder to mount** on the app's page. For the [Media bundle](#media-stack), enter `/mnt/gfl/<name>` as the media folder.

### NFS permissions

NFS keeps the NAS's own file owners. On the NAS, let uid/gid 101000 write, or map all users to it (`all_squash,anonuid=101000,anongid=101000`).
