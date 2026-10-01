## Manual install

Nginx Proxy Manager ships as a Docker image. On Debian 13 with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/nginx-proxy-manager && cd /opt/nginx-proxy-manager
cat > compose.yaml <<'EOF'
services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install.

## Using it

1. Open `http://<container-ip>:81` and create the admin account.
2. On your router, forward ports **80** and **443** to this container's IP.
3. At your domain registrar or DNS provider, point a name (for example `jellyfin.example.com`) at your home IP. A wildcard `*.example.com` record saves you doing this per app.
4. **Hosts > Proxy Hosts > Add Proxy Host**:
   - Domain: `jellyfin.example.com`
   - Forward to: `http`, the app's IP, its port (`8096` for Jellyfin)
   - Tick **Websockets Support** and **Block Common Exploits**
5. On the **SSL** tab choose **Request a new SSL Certificate**, tick **Force SSL**, accept the Let's Encrypt terms and save. Certificates renew by themselves.

### Keep admin pages private

Use **Access Lists** to require a login or limit an app to your home IPs, and never publish the Proxmox UI (port 8006) or Nginx Proxy Manager's own port 81.
