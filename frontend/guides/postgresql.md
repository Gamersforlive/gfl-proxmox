## Manual install

From Debian's packages, reachable from your network with password logins. On Debian 13, as root:

```bash
apt update && apt install -y postgresql
PGCONF=$(find /etc/postgresql -mindepth 2 -maxdepth 2 -type d -name main | head -n1)
echo "listen_addresses = '*'" > "$PGCONF/conf.d/gfl.conf"
echo "host all all 0.0.0.0/0 scram-sha-256" >> "$PGCONF/pg_hba.conf"
systemctl restart postgresql
runuser -u postgres -- psql -c "ALTER USER postgres WITH PASSWORD 'choose-a-password';"
```

## Docker

```yaml
services:
  postgres:
    image: postgres:17
    container_name: postgres
    restart: unless-stopped
    environment:
      - POSTGRES_PASSWORD=choose-a-password
    ports:
      - "5432:5432"
    volumes:
      - ./data:/var/lib/postgresql/data
```

## Using it

The `postgres` password is in `/root/postgresql.creds` inside the container. Make a database and user per app:

```bash
runuser -u postgres -- psql -c "CREATE USER gitea WITH PASSWORD 'another-password';"
runuser -u postgres -- psql -c "CREATE DATABASE gitea OWNER gitea;"
```

The app then connects to `<container-ip>:5432` with that database, user and password.

### Handy

- A prompt: `runuser -u postgres -- psql`. List databases with `\l`, quit with `\q`.
- Back up: `runuser -u postgres -- pg_dump gitea > gitea.sql`; everything: `runuser -u postgres -- pg_dumpall > all.sql`.
- Restrict access: in `pg_hba.conf`, replace `0.0.0.0/0` with your network, like `192.168.1.0/24`.
