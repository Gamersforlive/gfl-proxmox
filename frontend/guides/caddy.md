## Manual install

The script installs the official `.deb` from Caddy's GitHub releases (it includes the service). On Debian 13, as root:

```bash
apt update && apt install -y curl
VER=$(curl -fsSL https://api.github.com/repos/caddyserver/caddy/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
curl -fsSL "https://github.com/caddyserver/caddy/releases/download/${VER}/caddy_${VER#v}_linux_amd64.deb" -o /tmp/caddy.deb
apt install -y /tmp/caddy.deb
systemctl enable --now caddy
```

## Docker

```yaml
services:
  caddy:
    image: caddy:2
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./data:/data
      - ./config:/config
```

## Using it

Caddy is configured in one file, `/etc/caddy/Caddyfile`. For each site, write its name and where to send it:

```text
jellyfin.example.com {
	reverse_proxy 192.168.1.42:8096
}

vault.example.com {
	reverse_proxy 192.168.1.50:8000
}
```

Then reload: `systemctl reload caddy` (or `docker compose restart` for Docker).

1. Point the domain names at your home IP at your DNS provider.
2. Forward ports 80 and 443 on your router to Caddy.
3. Reload. Caddy gets HTTPS certificates from Let's Encrypt on its own and renews them.

Check your file before reloading with `caddy validate --config /etc/caddy/Caddyfile`. Logs: `journalctl -u caddy -f`.
