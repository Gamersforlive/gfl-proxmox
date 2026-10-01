## Manual install

The script runs the LinuxServer.io image with Calibre's converter added. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/calibre-web/config /data/media/books && cd /opt/calibre-web
cat > compose.yaml <<'EOF'
services:
  calibre-web:
    image: lscr.io/linuxserver/calibre-web:latest
    container_name: calibre-web
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Amsterdam
      - DOCKER_MODS=linuxserver/mods:universal-calibre
    ports:
      - "8083:8083"
    volumes:
      - ./config:/config
      - /data/media/books:/books
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. The `universal-calibre` mod adds the converter and makes the first start a few minutes slower.

## Using it

Calibre-Web shows an existing **Calibre library**: a folder with `metadata.db` and one folder per author.

1. Copy your Calibre library (from the Calibre desktop app) into `/data/media/books`. No library yet? Create an empty one in Calibre and copy that.
2. Open `http://<container-ip>:8083`, log in with `admin` / `admin123` and **change the password** under your profile.
3. **Database configuration**: set the location to `/books` and save.
4. **Admin > Edit Basic Configuration > Feature Configuration**: turn on **Enable Uploads** to add books from the browser. Set the converter path to `/usr/bin/ebook-convert`.
5. Read in the browser, download to your e-reader, or **Send to Kindle** (set up your email server under **Admin > Email**).
