## Manual install

On a machine with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/dockge /opt/stacks && cd /opt/dockge
cat > compose.yaml <<'EOF'
services:
  dockge:
    image: louislam/dockge:1
    container_name: dockge
    restart: unless-stopped
    ports:
      - "5001:5001"
    environment:
      - DOCKGE_STACKS_DIR=/opt/stacks
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data:/app/data
      - /opt/stacks:/opt/stacks
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. The stacks folder must have the same path inside and outside the container (`/opt/stacks:/opt/stacks`).

## Using it

1. Open `http://<container-ip>:5001` and create your login.
2. Click **+ Compose**, give the stack a name, and paste or write a `compose.yaml`. Dockge checks it as you type.
3. Click **Deploy** and watch the output live.
4. Use **Update** to pull new images, **Restart** and **Stop** for the whole stack.

Every stack is a plain folder in `/opt/stacks/<name>/compose.yaml`, so you can still manage it with `docker compose` in a terminal. Already have compose projects? Move their folders into `/opt/stacks` and they show up.

Paste a `docker run` command into the converter box at the top to turn it into a compose file.
