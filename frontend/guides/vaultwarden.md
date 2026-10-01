## Manual install

Vaultwarden is distributed as a Docker image. On Debian 13 with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/vaultwarden && cd /opt/vaultwarden
cat > compose.yaml <<'EOF'
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    environment:
      - SIGNUPS_ALLOWED=true
      - DOMAIN=https://vault.example.com
    ports:
      - "8000:80"
    volumes:
      - ./data:/data
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. Set `DOMAIN` to the HTTPS address you'll use; it's needed for some features (like passkeys and attachments).

## Using it

Browsers only allow the web vault over **HTTPS**, so put Vaultwarden behind a reverse proxy first:

1. Publish it with [Nginx Proxy Manager](#nginx-proxy-manager), [Caddy](#caddy) or a [Cloudflare tunnel](#cloudflared) at, for example, `https://vault.example.com` (forward to port 8000).
2. Open that address and **Create account**. Use a strong master password you won't forget: it can't be recovered.
3. Create accounts for your family, then turn sign-ups off: set `SIGNUPS_ALLOWED=false` in `compose.yaml` and run `docker compose up -d`.
4. Install the official **Bitwarden** apps and browser extensions. On the login screen choose **Self-hosted** and enter your address.
5. Import your passwords: **Tools > Import data** in the web vault takes exports from Chrome, Firefox, 1Password, LastPass and others.

### Back it up

Everything lives in `/opt/vaultwarden/data`. Back up that folder regularly (Proxmox backups of the container cover it), and keep an encrypted export (**Tools > Export vault**) somewhere safe.
