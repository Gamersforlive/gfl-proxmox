## Manual install

Seerr ships as a Docker image, so the script installs Docker in the container and runs it with Compose. On a Debian 13 machine with Docker (see [Docker](#docker~manual-install)):

```bash
mkdir -p /opt/seerr/config
chown -R 1000:1000 /opt/seerr/config
cat > /opt/seerr/compose.yaml <<'EOF'
services:
  seerr:
    image: ghcr.io/seerr-team/seerr:latest
    container_name: seerr
    init: true
    restart: unless-stopped
    ports:
      - "5055:5055"
    volumes:
      - ./config:/app/config
EOF
cd /opt/seerr && docker compose up -d
```

## Docker

Same as above: copy the `compose.yaml` and run `docker compose up -d`. The image runs as user 1000, so the config folder must belong to uid 1000.

## Using it

1. Open `http://<container-ip>:5055`.
2. Choose your media server (Jellyfin, Plex or Emby) and sign in with its admin account. Seerr uses that server's accounts, so your users log in with their Jellyfin/Plex login.
3. Sync and enable your Movies and Shows libraries.
4. Add Radarr and Sonarr: their address, port and API key, then pick a quality profile and root folder (`/data/media/movies`, `/data/media/tv`). Mark each as the default server.
5. Finish setup.

### Requests

Anyone with access searches for a movie or show and clicks **Request**. Seerr sends it to Radarr or Sonarr, and it shows as available once it's in your library. Under **Users** you can set request limits and auto-approval per person.

> The [Media bundle](#media-stack) does all of the setup above for you.
