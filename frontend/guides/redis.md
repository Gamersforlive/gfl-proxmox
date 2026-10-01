## Manual install

From Debian's packages, with a password and network access. On Debian 13, as root:

```bash
apt update && apt install -y redis-server
printf '\nbind 0.0.0.0 -::*\nrequirepass choose-a-password\n' >> /etc/redis/redis.conf
systemctl restart redis-server
```

## Docker

```yaml
services:
  redis:
    image: redis:8
    container_name: redis
    restart: unless-stopped
    command: ["redis-server", "--requirepass", "choose-a-password", "--appendonly", "yes"]
    ports:
      - "6379:6379"
    volumes:
      - ./data:/data
```

## Using it

The password is in `/root/redis.creds` inside the container. Apps connect with host `<container-ip>`, port `6379` and that password; many take a URL like `redis://:password@192.168.1.70:6379/0`.

Try it:

```bash
redis-cli -a 'your-password' ping          # PONG
redis-cli -a 'your-password' set hello world
redis-cli -a 'your-password' get hello
redis-cli -a 'your-password' info memory
```

Redis keeps data in memory and saves snapshots to disk. Give the container enough RAM for everything you store, and use one database number per app (`/0`, `/1`, ...) if several share it.
