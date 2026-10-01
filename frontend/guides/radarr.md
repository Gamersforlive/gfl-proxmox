## Manual install

The script's steps for Debian 13, as root. Radarr runs as its own user in a shared `media` group, so it can share one `/data` folder with qBittorrent and Jellyfin.

```bash
apt update && apt install -y curl sqlite3 libicu76
groupadd -g 1000 media 2>/dev/null
useradd -r -g media -d /var/lib/radarr -s /usr/sbin/nologin radarr
mkdir -p /var/lib/radarr /data/media/movies /data/downloads
curl -fsSL "https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64" | tar -xz -C /opt
chown -R radarr:media /opt/Radarr /var/lib/radarr
cat > /etc/systemd/system/radarr.service <<'EOF'
[Unit]
Description=Radarr
After=network.target

[Service]
User=radarr
Group=media
UMask=0002
ExecStart=/opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr/
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now radarr
```

On Debian 12 the ICU package is `libicu72` instead of `libicu76`.

## Docker

The LinuxServer.io image is the usual choice. `PUID`/`PGID` are the user and group that own your media.

```yaml
services:
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    ports:
      - "7878:7878"
    volumes:
      - ./config:/config
      - /data:/data
```

Mount the whole `/data` folder (downloads and library together), not two separate folders, or imports become slow copies instead of instant hardlinks.

## Using it

1. Open `http://<container-ip>:7878`. Choose **Forms** login and create your user.
2. **Settings > Media Management > Add Root Folder**: `/data/media/movies`. Turn on **Rename Movies**.
3. **Settings > Download Clients > +**: qBittorrent, host = qBittorrent's IP, port `8090`, your qBittorrent login, category `radarr`. Test, then save.
4. Indexers: add them once in [Prowlarr](#prowlarr) and connect Radarr there; they appear here automatically.
5. **Movies > Add New**: search a title, pick the root folder and a quality profile, and click **Add Movie** with **Start search** ticked.

### How a download flows

Radarr finds a release through Prowlarr, sends it to qBittorrent with the `radarr` category, waits for it to finish in `/data/downloads`, then hardlinks it into `/data/media/movies/<Movie (Year)>`. Jellyfin or Plex picks it up from there.

> Skip steps 2 to 4: the [Media bundle](#media-stack) sets all of them up for you.
