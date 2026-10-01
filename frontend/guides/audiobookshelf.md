## Manual install

Audiobookshelf has its own apt repository. On Debian 13, as root:

```bash
apt update && apt install -y curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://advplyr.github.io/audiobookshelf-ppa/KEY.gpg | gpg --dearmor -o /etc/apt/keyrings/audiobookshelf.gpg
cat > /etc/apt/sources.list.d/audiobookshelf.sources <<'EOF'
Types: deb
URIs: https://advplyr.github.io/audiobookshelf-ppa
Suites: ./
Signed-By: /etc/apt/keyrings/audiobookshelf.gpg
EOF
apt update && apt install -y audiobookshelf
mkdir -p /data/media/audiobooks /data/media/podcasts
systemctl enable --now audiobookshelf
```

The port is set in `/etc/default/audiobookshelf` (13378 by default).

## Docker

```yaml
services:
  audiobookshelf:
    image: ghcr.io/advplyr/audiobookshelf:latest
    container_name: audiobookshelf
    restart: unless-stopped
    ports:
      - "13378:80"
    volumes:
      - ./config:/config
      - ./metadata:/metadata
      - /data/media/audiobooks:/audiobooks
      - /data/media/podcasts:/podcasts
```

## Using it

1. Open `http://<container-ip>:13378` and create the root user.
2. **Settings > Libraries > Add**: a Books library at `/data/media/audiobooks`, and a Podcasts library at `/data/media/podcasts`.
3. Put each audiobook in its own folder, ideally `Author/Title/` with the audio files inside. Click **Scan**.
4. Install the Audiobookshelf app (Android, iOS) and log in with `http://<container-ip>:13378`. It remembers where you stopped on every device and can download books for offline listening.
5. For podcasts, search and subscribe in the Podcasts library; new episodes download automatically.
