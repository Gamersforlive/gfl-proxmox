## Manual install

On a machine with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/homepage/config && cd /opt/homepage
cat > compose.yaml <<'EOF'
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    restart: unless-stopped
    environment:
      - HOMEPAGE_ALLOWED_HOSTS=*
    ports:
      - "3000:3000"
    volumes:
      - ./config:/app/config
EOF
docker compose up -d
```

`HOMEPAGE_ALLOWED_HOSTS` lists the addresses people use to open the page. `*` allows any; set it to your domain once you have one, for example `home.example.com`.

## Docker

The steps above are the Docker install.

## Using it

Homepage is configured with YAML files in `/opt/homepage/config`. Save a file and the page reloads by itself.

Add your apps to `services.yaml`:

```yaml
- Media:
    - Jellyfin:
        href: http://192.168.1.42:8096
        description: Movies and TV
        icon: jellyfin.png
    - Radarr:
        href: http://192.168.1.43:7878
        icon: radarr.png
        widget:
          type: radarr
          url: http://192.168.1.43:7878
          key: your-radarr-api-key
```

- `services.yaml`: your apps, in groups. `widget:` shows live info (queue, streams, disk) for many apps.
- `bookmarks.yaml`: plain links.
- `widgets.yaml`: the top bar (search, weather, CPU and memory).
- `settings.yaml`: title, theme, background and layout.

Icons come from the same dashboard-icons set this site uses: write `icon: <app>.png`. See the Homepage docs for every widget type.
