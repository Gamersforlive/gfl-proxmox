## Manual install

Paperless-ngx runs best in Docker with Redis. On Debian 13 with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/paperless-ngx/{data,media,export,consume} && cd /opt/paperless-ngx
cat > .env <<EOF
PAPERLESS_ADMIN_USER=admin
PAPERLESS_ADMIN_PASSWORD=$(head -c 32 /dev/urandom | base64 | tr -dc A-Za-z0-9 | cut -c1-20)
PAPERLESS_SECRET_KEY=$(head -c 96 /dev/urandom | base64 | tr -dc A-Za-z0-9 | cut -c1-64)
PAPERLESS_TIME_ZONE=Europe/Amsterdam
PAPERLESS_OCR_LANGUAGE=eng
EOF
chmod 600 .env
cat > compose.yaml <<'EOF'
services:
  broker:
    image: docker.io/library/redis:8
    restart: unless-stopped
    volumes:
      - ./redis:/data
  webserver:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    restart: unless-stopped
    depends_on:
      - broker
    ports:
      - "8000:8000"
    env_file: .env
    environment:
      - PAPERLESS_REDIS=redis://broker:6379
    volumes:
      - ./data:/usr/src/paperless/data
      - ./media:/usr/src/paperless/media
      - ./export:/usr/src/paperless/export
      - ./consume:/usr/src/paperless/consume
EOF
docker compose up -d
grep ADMIN_PASSWORD .env
```

Paperless-ngx 3 refuses to start without `PAPERLESS_SECRET_KEY`.

## Docker

The steps above are the Docker install. For OCR in other languages add them, for example `PAPERLESS_OCR_LANGUAGE=nld+eng`.

## Using it

1. Open `http://<container-ip>:8000` and log in as `admin` with the password from `.env` (or `/root/paperless-ngx.creds` when installed with the script). Change it under your profile.
2. Upload documents by dragging them onto the dashboard, or drop files in `/opt/paperless-ngx/consume`. Scanners that can save to a network share can scan straight into that folder.
3. Paperless reads the text (OCR), then guesses the correspondent, document type and tags. Correct a few and it learns.
4. Search finds words inside every document, not just titles.

### Change or reset the admin password

The password in `.env` and `/root/paperless-ngx.creds` is only used on the very first start; editing those files later changes nothing. Change it in Paperless under your profile, or reset it from the container:

```bash
cd /opt/paperless-ngx && docker compose exec webserver python3 manage.py changepassword admin
```

Tips: set up **Mail** to import attachments from an inbox, and **Workflows** to tag documents automatically. Back up with `docker compose exec webserver document_exporter ../export`.
