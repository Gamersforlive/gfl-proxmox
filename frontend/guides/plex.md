## Manual install

Plex's own apt repository is signed with a SHA-1 key that Debian 13 no longer trusts, so the script installs the official `.deb` from Plex's download API. As root:

```bash
apt update && apt install -y curl jq
URL=$(curl -fsSL https://plex.tv/api/downloads/5.json | jq -r '.computer.Linux.releases[] | select(.build=="linux-x86_64" and .distro=="debian") | .url' | head -n1)
curl -fsSL "$URL" -o /tmp/plex.deb
apt install -y /tmp/plex.deb
rm -f /tmp/plex.deb /etc/apt/sources.list.d/plexmediaserver.list
systemctl enable --now plexmediaserver
```

For hardware transcoding (a Plex Pass feature), pass `/dev/dri` into the container and install the drivers:

```bash
apt install -y va-driver-all vainfo
usermod -aG video,render,media plex
systemctl restart plexmediaserver
```

## Docker

```yaml
services:
  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    network_mode: host
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
      - VERSION=docker
      - PLEX_CLAIM=claim-xxxxxxxx   # from https://www.plex.tv/claim, valid 4 minutes
    volumes:
      - ./config:/config
      - /data/media:/data/media
    devices:
      - /dev/dri:/dev/dri
```

## Using it

1. From a device on the same network, open `http://<container-ip>:32400/web`.
2. Sign in with your Plex account. The server is "claimed" and linked to your account.
3. Give the server a name and add libraries: Movies at `/data/media/movies`, TV Shows at `/data/media/tv`, Music at `/data/media/music`.
4. **Settings > Remote Access**: turn it on and forward port 32400 on your router if you want to watch away from home.

### Hardware transcoding

With Plex Pass: **Settings > Transcoder**, tick **Use hardware acceleration when available**. Play something at a lower quality and check the dashboard shows "(hw)".

### Can't claim the server?

Plex only allows claiming from the same network. If your browser is on another subnet, use an SSH tunnel: `ssh -L 32400:localhost:32400 root@<container-ip>`, then open `http://localhost:32400/web`.
