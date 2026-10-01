## Manual install

Jellystat runs in Docker with PostgreSQL. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/jellystat && cd /opt/jellystat
printf 'POSTGRES_PASSWORD=%s\nJWT_SECRET=%s\n' "$(head -c 24 /dev/urandom | base64 | tr -dc A-Za-z0-9)" "$(head -c 48 /dev/urandom | base64 | tr -dc A-Za-z0-9)" > .env
cat > compose.yaml <<'EOF'
services:
  jellystat-db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - ./postgres:/var/lib/postgresql/data
  jellystat:
    image: cyfershepard/jellystat:latest
    restart: unless-stopped
    depends_on:
      - jellystat-db
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_IP=jellystat-db
      - POSTGRES_PORT=5432
      - JWT_SECRET=${JWT_SECRET}
    ports:
      - "3000:3000"
    volumes:
      - ./backup:/app/backend/backup-data
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install.

## Using it

1. Open `http://<container-ip>:3000` and create your login.
2. In Jellyfin, create an API key: **Dashboard > API Keys > +**, name it Jellystat.
3. Back in Jellystat, enter Jellyfin's address (for example `http://192.168.1.42:8096`) and the API key.
4. Jellystat imports the existing history and keeps watching. Browse **Activity**, **Libraries**, **Users** and the statistics pages.

Install the **Playback Reporting** plugin in Jellyfin and import its data under **Settings** to get history from before Jellystat existed.
