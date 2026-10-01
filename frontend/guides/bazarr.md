## Manual install

The script runs the LinuxServer.io image. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/bazarr/config && cd /opt/bazarr
cat > compose.yaml <<'EOF'
services:
  bazarr:
    image: lscr.io/linuxserver/bazarr:latest
    container_name: bazarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    ports:
      - "6767:6767"
    volumes:
      - ./config:/config
      - /data:/data
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. Bazarr must see your media at the **same path** as Radarr and Sonarr (`/data/...`), or it can't find the files they report.

## Using it

1. Open `http://<container-ip>:6767`.
2. **Settings > Languages**: add the subtitle languages you want and create a **Languages Profile** (for example English and Dutch). Set it as default for movies and series.
3. **Settings > Providers**: add providers such as OpenSubtitles.com (free account), Subdl, Addic7ed.
4. **Settings > Sonarr** and **Settings > Radarr**: enable, enter their address, port and API key, click **Test** and **Save**.
5. Bazarr syncs your library and searches subtitles for everything missing. New downloads get subtitles automatically.

Turn on a login under **Settings > General > Security** before exposing it.
