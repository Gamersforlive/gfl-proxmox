## Manual install

Crafty ships as a Docker image. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/crafty/{backups,logs,servers,config,import} && cd /opt/crafty
cat > compose.yaml <<'EOF'
services:
  crafty:
    image: registry.gitlab.com/crafty-controller/crafty-4:latest
    container_name: crafty
    restart: unless-stopped
    ports:
      - "8443:8443"
      - "19132:19132/udp"
      - "25500-25600:25500-25600"
    volumes:
      - ./backups:/crafty/backups
      - ./logs:/crafty/logs
      - ./servers:/crafty/servers
      - ./config:/crafty/app/config
      - ./import:/crafty/import
EOF
docker compose up -d
cat config/default-creds.txt
```

## Docker

The steps above are the Docker install.

## Using it

1. Open `https://<container-ip>:8443` and accept the certificate warning.
2. Log in as `admin` with the password from `/opt/crafty/config/default-creds.txt` (inside the container). Change it under your user settings.
3. **Servers > Create New Server**: pick Java or Bedrock, the server type (Paper, Fabric, Forge, Vanilla...), the version, the memory and a port **between 25500 and 25600**.
4. Start it, follow the live console, and accept the EULA when Crafty asks.
5. **Schedules**: automatic restarts and backups. **Backups**: one-click and scheduled backups to `/opt/crafty/backups`.

Bring existing servers: copy their folder into `/opt/crafty/import` and use **Import Server**. Forward the ports you use (25500-25600) for friends outside your network.
