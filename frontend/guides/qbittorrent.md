## Manual install

The script's steps for Debian 13, as root. It runs the web-only version (`qbittorrent-nox`) as its own user.

```bash
apt update && apt install -y qbittorrent-nox
groupadd -g 1000 media 2>/dev/null
useradd -r -m -g media -d /var/lib/qbittorrent -s /usr/sbin/nologin qbittorrent
mkdir -p /data/downloads/complete /data/downloads/incomplete
cat > /etc/systemd/system/qbittorrent.service <<'EOF'
[Unit]
Description=qBittorrent (web UI)
After=network-online.target

[Service]
User=qbittorrent
Group=media
UMask=0002
ExecStart=/usr/bin/qbittorrent-nox --webui-port=8090
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now qbittorrent
journalctl -u qbittorrent | grep -i password
```

Without a configured password, qBittorrent prints a temporary one in its log (the last command shows it). The script sets a password for you instead.

## Docker

```yaml
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
      - WEBUI_PORT=8090
    ports:
      - "8090:8090"
      - "6881:6881"
      - "6881:6881/udp"
    volumes:
      - ./config:/config
      - /data:/data
```

The first login's password is in the log: `docker logs qbittorrent`.

## Using it

1. Open `http://<container-ip>:8090` and log in. With the script, the user is `admin` and the password is in `/root/qbittorrent.creds` inside the container.
2. **Tools > Options > Web UI**: change the password to one you'll remember.
3. **Downloads**: the default save path is `/data/downloads/complete`, incomplete files go to `/data/downloads/incomplete`. Keep these if you use Radarr and Sonarr.
4. **Connection**: forward the listening port (default 6881, or the one shown there) on your router for better speeds.

### With Radarr and Sonarr

You don't add torrents by hand: Radarr and Sonarr send them here with a category (`radarr`, `sonarr`) and move the finished files into your library. Leave **Torrent Management Mode** on Manual and don't remove finished torrents yourself; Radarr and Sonarr clean up after importing.

> Use a VPN? Run qBittorrent in a container whose only network is the VPN, or bind it to the VPN interface under **Advanced > Network interface**.
