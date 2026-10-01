## Manual install

Immich only supports Docker Compose, using the files from each release. On Debian 13 with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/immich /data/immich/library && cd /opt/immich
curl -fsSL https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml -o compose.yaml
curl -fsSL https://github.com/immich-app/immich/releases/latest/download/example.env -o .env
sed -i \
  -e "s|^UPLOAD_LOCATION=.*|UPLOAD_LOCATION=/data/immich/library|" \
  -e "s|^DB_DATA_LOCATION=.*|DB_DATA_LOCATION=/opt/immich/postgres|" \
  -e "s|^DB_PASSWORD=.*|DB_PASSWORD=$(head -c 32 /dev/urandom | base64 | tr -dc A-Za-z0-9 | cut -c1-20)|" .env
docker compose up -d
```

## Docker

The steps above are the Docker install. Keep `.env` safe: it holds the database password. Put `UPLOAD_LOCATION` on big storage before uploading anything; moving it later is work.

## Using it

1. Open `http://<container-ip>:2283` and create the admin account.
2. Install the Immich app on your phone, enter `http://<container-ip>:2283` and log in.
3. In the app, open **Backup**, choose the albums to back up and turn it on. Photos upload in the background (on Wi-Fi by default).
4. Give it time: after uploading, Immich detects faces, makes thumbnails and builds the search index. **Administration > Jobs** shows progress.
5. Search by what's in a photo ("beach", "dog in snow"), browse **People** and name faces, and share albums with a link.

### Tips

- Add family members under **Administration > Users**. Each has their own library; shared albums and partner sharing let you see each other's photos.
- Import existing photos: point an **External library** at a folder on the server instead of uploading again.
- Immich is fast on a GPU: see the hardware acceleration section of the Immich docs.
- Back up `/data/immich/library` and the database (Immich makes nightly database dumps in `library/backups`).
