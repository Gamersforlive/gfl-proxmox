## Manual install

Navidrome publishes a `.deb` on GitHub that includes its service. On Debian 13, as root:

```bash
apt update && apt install -y curl ffmpeg
VER=$(curl -fsSL https://api.github.com/repos/navidrome/navidrome/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
curl -fsSL "https://github.com/navidrome/navidrome/releases/download/${VER}/navidrome_${VER#v}_linux_amd64.deb" -o /tmp/navidrome.deb
apt install -y /tmp/navidrome.deb
mkdir -p /data/media/music /etc/navidrome /var/lib/navidrome
cat > /etc/navidrome/navidrome.toml <<'EOF'
MusicFolder = "/data/media/music"
DataFolder = "/var/lib/navidrome"
Address = "0.0.0.0"
Port = 4533
EOF
chown -R navidrome:navidrome /var/lib/navidrome
systemctl enable --now navidrome
```

## Docker

```yaml
services:
  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    user: "1000:1000"
    restart: unless-stopped
    ports:
      - "4533:4533"
    volumes:
      - ./data:/data
      - /data/media/music:/music:ro
```

## Using it

1. Open `http://<container-ip>:4533` and create the admin account.
2. The first scan of `/data/media/music` starts by itself; big collections take a while.
3. Listen in the browser, or use a Subsonic app: **Symfonium** or **Tempo** on Android, **Amperfy** or **play:Sub** on iOS, **Feishin** on desktop. Server address `http://<container-ip>:4533`, with your Navidrome login.
4. Add family members under **Settings > Users**; each gets their own playlists and favourites.

Tags matter: Navidrome organises by the files' tags, not folder names. Fix messy tags with a tool like MusicBrainz Picard, or let [Lidarr](#lidarr) manage the collection.
