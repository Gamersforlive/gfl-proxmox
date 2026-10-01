## Manual install

Nextcloud's official image with MariaDB, Redis and a cron container. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/nextcloud && cd /opt/nextcloud
cat > .env <<EOF
MYSQL_ROOT_PASSWORD=$(head -c 24 /dev/urandom | base64 | tr -dc A-Za-z0-9)
MYSQL_PASSWORD=$(head -c 24 /dev/urandom | base64 | tr -dc A-Za-z0-9)
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=choose-a-password
NEXTCLOUD_TRUSTED_DOMAINS=$(hostname -I | awk '{print $1}') localhost
EOF
```

Then save the `compose.yaml` from the script (it's in `/opt/nextcloud/compose.yaml` in a container made by it; the Docker tab has the same file) and run `docker compose up -d`. The first start installs Nextcloud and takes a few minutes.

## Docker

```yaml
services:
  db:
    image: mariadb:11
    restart: unless-stopped
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    environment:
      - MARIADB_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MARIADB_DATABASE=nextcloud
      - MARIADB_USER=nextcloud
      - MARIADB_PASSWORD=${MYSQL_PASSWORD}
    volumes:
      - ./db:/var/lib/mysql
  redis:
    image: redis:8-alpine
    restart: unless-stopped
  app:
    image: nextcloud:apache
    restart: unless-stopped
    depends_on: [db, redis]
    ports:
      - "8080:80"
    environment:
      - MYSQL_HOST=db
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - REDIS_HOST=redis
      - NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER}
      - NEXTCLOUD_ADMIN_PASSWORD=${NEXTCLOUD_ADMIN_PASSWORD}
      - NEXTCLOUD_TRUSTED_DOMAINS=${NEXTCLOUD_TRUSTED_DOMAINS}
    volumes:
      - ./html:/var/www/html
      - ./data:/var/www/html/data
  cron:
    image: nextcloud:apache
    restart: unless-stopped
    entrypoint: /cron.sh
    depends_on: [app]
    volumes:
      - ./html:/var/www/html
      - ./data:/var/www/html/data
```

## Using it

1. Wait a few minutes after the install, then open `http://<container-ip>:8080` and log in as `admin` with the password from `/root/nextcloud.creds`.
2. Install the desktop and phone apps from nextcloud.com/install and connect them with the same address. Turn on **auto upload** for photos in the phone app.
3. **Apps**: add Calendar, Contacts, Notes, Deck, Talk and more with one click.
4. Make accounts for family under **Users** and set storage quotas.

### Use a domain

Put Nextcloud behind [Nginx Proxy Manager](#nginx-proxy-manager) or [Caddy](#caddy), then tell Nextcloud the name:

```bash
cd /opt/nextcloud
docker compose exec -u www-data app php occ config:system:set trusted_domains 2 --value=cloud.example.com
docker compose exec -u www-data app php occ config:system:set overwriteprotocol --value=https
```

Check **Administration settings > Overview** for warnings; it tells you what to fix.
