## Manual install

On a machine with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/portainer && cd /opt/portainer
cat > compose.yaml <<'EOF'
services:
  portainer:
    image: portainer/portainer-ce:lts
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9443:9443"
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data:/data
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. `lts` follows Portainer's long-term-support releases; use `latest` for the newest features.

## Using it

1. Open `https://<container-ip>:9443` within 5 minutes of starting and accept the self-signed certificate warning.
2. Create the admin user (at least 12 characters).
3. Choose **Get Started** to manage the local Docker.
4. **Stacks > Add stack**: paste a `compose.yaml`, name it and click **Deploy**. Stacks are the easiest way to run apps.
5. Click a container to see its logs, open a console, or restart it.

### Manage other servers

Install the Portainer Agent on another Docker host (**Environments > Add environment > Docker Standalone > Agent**, copy the command) to manage all your Docker machines from one page.

Missed the 5-minute window? Run `docker restart portainer` and try again.
