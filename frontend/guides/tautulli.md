## Manual install

The script runs Tautulli's official image. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/tautulli/config && chown -R 1000:1000 /opt/tautulli/config && cd /opt/tautulli
cat > compose.yaml <<'EOF'
services:
  tautulli:
    image: ghcr.io/tautulli/tautulli:latest
    container_name: tautulli
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
    ports:
      - "8181:8181"
    volumes:
      - ./config:/config
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install.

## Using it

1. Open `http://<container-ip>:8181` and follow the setup wizard.
2. Set a login, then **Sign in with Plex**; Tautulli finds your server. Enter its IP and port 32400 if it doesn't.
3. Finish, and Tautulli starts recording everything that plays. The **Home** page shows what's streaming now.
4. **Settings > Notification Agents**: add Discord, Telegram or email and pick triggers like "playback start" or "recently added".
5. **Newsletters**: a weekly email of everything new on your server for friends and family.
