## Manual install

The script's steps for Debian 13, as root:

```bash
apt update && apt install -y curl sqlite3 libicu76
groupadd -g 1000 media 2>/dev/null
useradd -r -g media -d /var/lib/sonarr -s /usr/sbin/nologin sonarr
mkdir -p /var/lib/sonarr /data/media/tv /data/downloads
curl -fsSL "https://services.sonarr.tv/v1/download/main/latest?version=4&os=linux&arch=x64" | tar -xz -C /opt
chown -R sonarr:media /opt/Sonarr /var/lib/sonarr
cat > /etc/systemd/system/sonarr.service <<'EOF'
[Unit]
Description=Sonarr
After=network.target

[Service]
User=sonarr
Group=media
UMask=0002
ExecStart=/opt/Sonarr/Sonarr -nobrowser -data=/var/lib/sonarr/
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now sonarr
```

## Docker

```yaml
services:
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    ports:
      - "8989:8989"
    volumes:
      - ./config:/config
      - /data:/data
```

## Using it

1. Open `http://<container-ip>:8989`, choose **Forms** login and create your user.
2. **Settings > Media Management > Add Root Folder**: `/data/media/tv`. Turn on **Rename Episodes**.
3. **Settings > Download Clients > +**: qBittorrent at its IP, port `8090`, category `sonarr`.
4. Connect Sonarr in [Prowlarr](#prowlarr) so your indexers sync over.
5. **Series > Add New**: search a show, choose which seasons to monitor, and add it with **Start search for missing episodes**.

### Tips

- **Monitoring**: "Future episodes" grabs only new episodes; "All episodes" fills in the back catalogue too.
- **Anime**: set the series type to Anime so absolute episode numbers work.
- **Calendar**: the Calendar page shows what airs this week; you can subscribe to it from your phone's calendar app (iCal link at the top).

> The [Media bundle](#media-stack) does steps 2 to 4 for you.
