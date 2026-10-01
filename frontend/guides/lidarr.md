## Manual install

The script's steps for Debian 13, as root:

```bash
apt update && apt install -y curl sqlite3 libicu76
groupadd -g 1000 media 2>/dev/null
useradd -r -g media -d /var/lib/lidarr -s /usr/sbin/nologin lidarr
mkdir -p /var/lib/lidarr /data/media/music /data/downloads
curl -fsSL "https://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64" | tar -xz -C /opt
chown -R lidarr:media /opt/Lidarr /var/lib/lidarr
cat > /etc/systemd/system/lidarr.service <<'EOF'
[Unit]
Description=Lidarr
After=network.target

[Service]
User=lidarr
Group=media
UMask=0002
ExecStart=/opt/Lidarr/Lidarr -nobrowser -data=/var/lib/lidarr/
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now lidarr
```

## Docker

```yaml
services:
  lidarr:
    image: lscr.io/linuxserver/lidarr:latest
    container_name: lidarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    ports:
      - "8686:8686"
    volumes:
      - ./config:/config
      - /data:/data
```

## Using it

1. Open `http://<container-ip>:8686`, choose **Forms** login and create your user.
2. **Settings > Media Management > Add Root Folder**: `/data/media/music`, with the default quality and metadata profiles.
3. **Settings > Download Clients**: add qBittorrent with category `lidarr`.
4. Connect Lidarr in [Prowlarr](#prowlarr) under **Settings > Apps**.
5. **Library > Add New**: search an artist and choose which albums to monitor.

Play your music with [Navidrome](#navidrome) or Jellyfin by pointing them at `/data/media/music`.
