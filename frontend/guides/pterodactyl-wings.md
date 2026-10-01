## Manual install

Wings is a single binary that runs game servers in Docker. On Debian 13 with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /etc/pterodactyl /var/lib/pterodactyl
curl -fsSL https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 -o /usr/local/bin/wings
chmod 755 /usr/local/bin/wings
cat > /etc/systemd/system/wings.service <<'EOF'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
ConditionPathExists=/etc/pterodactyl/config.yml

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
ExecStart=/usr/local/bin/wings
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
systemctl enable wings
```

In a Proxmox container, Docker needs **nesting** and **keyctl** (the script turns them on).

## Docker

Wings can run in Docker too (it then starts game servers as sibling containers):

```yaml
services:
  wings:
    image: ghcr.io/pterodactyl/wings:latest
    container_name: wings
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "2022:2022"
    environment:
      - TZ=Europe/Amsterdam
      - WINGS_UID=988
      - WINGS_GID=988
      - WINGS_USERNAME=pterodactyl
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/containers/:/var/lib/docker/containers/
      - /etc/pterodactyl/:/etc/pterodactyl/
      - /var/lib/pterodactyl/:/var/lib/pterodactyl/
      - /var/log/pterodactyl/:/var/log/pterodactyl/
      - /tmp/pterodactyl/:/tmp/pterodactyl/
```

## Using it

You need a Pterodactyl **Panel** somewhere; Wings is the worker that runs the servers.

1. In the panel: **Admin > Locations**, create a location if you have none.
2. **Admin > Nodes > Create New**: FQDN = this container's IP (or a domain name), communicate over HTTP (or HTTPS with a certificate), set memory and disk to what you gave the container.
3. On the node's **Configuration** tab, copy the configuration file.
4. Paste it into `/etc/pterodactyl/config.yml` inside the container and start Wings: `systemctl start wings`. The node's heart turns green in the panel.
5. **Allocations** tab: add the IP and port range for game servers (for example 25565-25600), and forward those ports on your router.
6. Create servers in the panel and pick this node.

Check Wings with `journalctl -u wings -f`, or run it in the foreground with `wings --debug` to see what's wrong.
