## Manual install

Building the same setup by hand takes an evening; this is the outline the bundle follows.

1. **One media folder** on the host, shared by every app, with this layout:

```text
/data
├── downloads/complete
├── downloads/incomplete
└── media/movies, media/tv, media/music
```

```bash
mkdir -p /mnt/gfl/media-data/{downloads/{complete,incomplete},media/{movies,tv,music}}
chown -R 101000:101000 /mnt/gfl/media-data && chmod -R 2775 /mnt/gfl/media-data
```

2. **One container per app**: [qBittorrent](#qbittorrent), [Prowlarr](#prowlarr), [FlareSolverr](#flaresolverr), [Radarr](#radarr), [Sonarr](#sonarr), [Jellyfin](#jellyfin), [Seerr](#seerr). Give each the folder at `/data`: `pct set <ID> -mp0 /mnt/gfl/media-data,mp=/data`.
3. **Radarr and Sonarr**: root folders `/data/media/movies` and `/data/media/tv`; qBittorrent as download client with categories `radarr` and `sonarr`.
4. **Prowlarr**: add Radarr and Sonarr under **Settings > Apps** (their API keys are in their **Settings > General**), and FlareSolverr as an indexer proxy with a tag.
5. **Jellyfin**: finish the wizard and add Movies, Shows and Music libraries on `/data/media/...`.
6. **Seerr**: sign in with Jellyfin, enable the libraries, and add Radarr and Sonarr as default servers.

Everything must use the same `/data` folder, or Radarr and Sonarr copy files instead of hardlinking them.

## Docker

The same stack as one Compose file. Wiring (step 3 to 6 above) is still done in each app's web page.

```yaml
x-common: &common
  restart: unless-stopped
  environment:
    - PUID=1000
    - PGID=1000
    - TZ=Europe/Amsterdam
services:
  qbittorrent:
    <<: *common
    image: lscr.io/linuxserver/qbittorrent:latest
    ports: ["8090:8090", "6881:6881", "6881:6881/udp"]
    environment: [PUID=1000, PGID=1000, TZ=Europe/Amsterdam, WEBUI_PORT=8090]
    volumes: [./qbittorrent:/config, /data:/data]
  prowlarr:
    <<: *common
    image: lscr.io/linuxserver/prowlarr:latest
    ports: ["9696:9696"]
    volumes: [./prowlarr:/config]
  flaresolverr:
    restart: unless-stopped
    image: ghcr.io/flaresolverr/flaresolverr:latest
    ports: ["8191:8191"]
  radarr:
    <<: *common
    image: lscr.io/linuxserver/radarr:latest
    ports: ["7878:7878"]
    volumes: [./radarr:/config, /data:/data]
  sonarr:
    <<: *common
    image: lscr.io/linuxserver/sonarr:latest
    ports: ["8989:8989"]
    volumes: [./sonarr:/config, /data:/data]
  jellyfin:
    restart: unless-stopped
    image: jellyfin/jellyfin:latest
    ports: ["8096:8096"]
    volumes: [./jellyfin:/config, /data/media:/data/media]
  seerr:
    restart: unless-stopped
    image: ghcr.io/seerr-team/seerr:latest
    init: true
    ports: ["5055:5055"]
    volumes: [./seerr:/app/config]
```

Inside one Compose project the apps reach each other by service name, for example `http://radarr:7878`.

## Using it

When the bundle finishes it prints every app's address. Your login is the same everywhere (Seerr uses your Jellyfin login).

1. **Prowlarr** (`:9696`): **Indexers > Add Indexer** and add the sites you use. They appear in Radarr and Sonarr by themselves. Tag Cloudflare-protected ones with `flaresolverr`.
2. **Seerr** (`:5055`): search a movie or show and click **Request**. Share this page with family and friends; they log in with Jellyfin accounts you make for them.
3. Watch the download in **qBittorrent** (`:8090`) or in Radarr/Sonarr's **Activity** page.
4. When it's done, it appears in **Jellyfin** (`:8096`). Install the Jellyfin app on your TV and phone.

### Day to day

- Add a single movie or show directly in Radarr or Sonarr instead of Seerr if you like.
- Quality: Radarr and Sonarr use the "Any" profile by default. Choose **HD-1080p** in **Settings > Profiles** or per title to avoid huge files.
- Update everything at once with [Update all GFL apps](#update-gfl-apps).
- Something not connected? Run the bundle again; it only adds what's missing.
