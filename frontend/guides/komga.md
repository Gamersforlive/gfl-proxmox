## Manual install

The script runs Komga's official image. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/komga/config && chown -R 1000:1000 /opt/komga/config && cd /opt/komga
cat > compose.yaml <<'EOF'
services:
  komga:
    image: gotson/komga:latest
    container_name: komga
    user: "1000:1000"
    restart: unless-stopped
    ports:
      - "25600:25600"
    volumes:
      - ./config:/config
      - /data/media:/data/media
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install.

## Using it

1. Open `http://<container-ip>:25600` and create the admin account.
2. **Libraries > +**: name it Comics, root folder `/data/media/comics`. One folder per series, with `.cbz`, `.cbr`, `.pdf` or `.epub` files inside.
3. Komga scans the folder; series appear with covers. Read in the browser with the built-in reader.
4. Phone and tablet apps: **Mihon/Tachiyomi** (Komga extension), **Panels**, **Paperback**, or any OPDS reader with `http://<container-ip>:25600/opds/v1.2/catalog`.
5. Add users under **Server > Users** and limit which libraries they see.
