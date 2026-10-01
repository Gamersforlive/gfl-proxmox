## Manual install

The script's steps for Debian 13, as root:

```bash
apt update && apt install -y curl sqlite3 libicu76
groupadd -g 1000 media 2>/dev/null
useradd -r -g media -d /var/lib/prowlarr -s /usr/sbin/nologin prowlarr
mkdir -p /var/lib/prowlarr
curl -fsSL "https://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64" | tar -xz -C /opt
chown -R prowlarr:media /opt/Prowlarr /var/lib/prowlarr
cat > /etc/systemd/system/prowlarr.service <<'EOF'
[Unit]
Description=Prowlarr
After=network.target

[Service]
User=prowlarr
Group=media
ExecStart=/opt/Prowlarr/Prowlarr -nobrowser -data=/var/lib/prowlarr/
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now prowlarr
```

## Docker

```yaml
services:
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    ports:
      - "9696:9696"
    volumes:
      - ./config:/config
```

## Using it

Prowlarr is where you add indexers (the sites that list releases). It pushes them to Radarr, Sonarr and Lidarr, so you never set them up three times.

1. Open `http://<container-ip>:9696`, choose **Forms** login and create your user.
2. **Settings > Apps > +**: add Radarr and Sonarr. For each, enter its address (for example `http://192.168.1.43:7878`) and its API key from that app's **Settings > General**. Prowlarr Server is Prowlarr's own address.
3. **Indexers > Add Indexer**: search for the trackers or Usenet indexers you use and enter your account details. Click **Test**, then **Save**.
4. Open Radarr or Sonarr: the indexers appear under **Settings > Indexers** within a minute.

### Cloudflare-protected indexers

Some indexers show a "checking your browser" page. Install [FlareSolverr](#flaresolverr), add it under **Settings > Indexers > + > FlareSolverr** with a tag such as `flaresolverr`, and give that same tag to the indexers that need it.

> The [Media bundle](#media-stack) connects Prowlarr to Radarr, Sonarr and FlareSolverr automatically; you only add the indexers.
