## Manual install

From Debian's packages, reachable from your network. On Debian 13, as root:

```bash
apt update && apt install -y mariadb-server
printf '[mysqld]\nbind-address = 0.0.0.0\n' > /etc/mysql/mariadb.conf.d/99-gfl.cnf
systemctl restart mariadb
mariadb -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'choose-a-password'; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
```

## Docker

```yaml
services:
  mariadb:
    image: mariadb:11
    container_name: mariadb
    restart: unless-stopped
    environment:
      - MARIADB_ROOT_PASSWORD=choose-a-root-password
    ports:
      - "3306:3306"
    volumes:
      - ./data:/var/lib/mysql
```

## Using it

The admin login is in `/root/mariadb.creds` inside the container. Give each app its own database and user instead of sharing the admin:

```bash
mariadb -e "CREATE DATABASE nextcloud;"
mariadb -e "CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'another-password';"
mariadb -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'%';"
```

Then give the app host `<container-ip>`, port 3306, that database, user and password.

### Handy

- Open a prompt: `mariadb` (as root inside the container).
- Back up a database: `mariadb-dump nextcloud > nextcloud.sql`; all of them: `mariadb-dump --all-databases > all.sql`.
- A desktop tool like DBeaver or HeidiSQL connects with the admin login.
- Limit who can connect by replacing `'%'` with your app's IP when you create users.
