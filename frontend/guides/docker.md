## Manual install

Docker Engine from Docker's own repository, as the script does. On Debian 13, as root:

```bash
apt update && apt install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.gpg
EOF
apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo '{ "log-driver": "json-file", "log-opts": { "max-size": "10m", "max-file": "3" } }' > /etc/docker/daemon.json
systemctl restart docker
docker run --rm hello-world
```

### In a Proxmox container

Docker needs **nesting** (and **keyctl** in unprivileged containers). Set them on the host before starting the container:

```bash
pct set <ID> -features nesting=1,keyctl=1
```

## Using it

Run each app as a small Compose project in its own folder:

```bash
mkdir -p /opt/whoami && cd /opt/whoami
cat > compose.yaml <<'EOF'
services:
  whoami:
    image: traefik/whoami
    restart: unless-stopped
    ports:
      - "8080:80"
EOF
docker compose up -d
```

### Everyday commands

- `docker compose ps` lists the project's containers; `docker ps` lists all of them.
- `docker compose logs -f` follows the logs; Ctrl+C stops following.
- `docker compose pull && docker compose up -d` updates to the newest images.
- `docker compose down` stops and removes the containers (volumes and folders stay).
- `docker image prune -f` deletes old images to free disk space.
- `docker system df` shows how much space images and volumes use.

Prefer a web page for this? Install [Portainer](#portainer) or [Dockge](#dockge).
