## Manual install

The script runs the LinuxServer.io image, sharing `/data`. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/sabnzbd/config /data/downloads/usenet/{complete,incomplete} && cd /opt/sabnzbd
cat > compose.yaml <<'EOF'
services:
  sabnzbd:
    image: lscr.io/linuxserver/sabnzbd:latest
    container_name: sabnzbd
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    ports:
      - "8080:8080"
    volumes:
      - ./config:/config
      - /data:/data
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install.

## Using it

1. Open `http://<container-ip>:8080` and follow the wizard: enter your **Usenet provider's** server, port (563 with SSL), user name and password, and test the connection.
2. **Config > Folders**: temporary folder `/data/downloads/usenet/incomplete`, completed folder `/data/downloads/usenet/complete`.
3. **Config > Categories**: add `radarr` and `sonarr`.
4. **Config > General**: copy the **API key** and set a login.
5. In Radarr and Sonarr: **Settings > Download Clients > + > SABnzbd**, host = this container's IP, port 8080, the API key, category `radarr`/`sonarr`.
6. Add your Usenet indexer in [Prowlarr](#prowlarr); it syncs to Radarr and Sonarr.

Downloads land on the same `/data` folder as your library, so imports are instant moves.
