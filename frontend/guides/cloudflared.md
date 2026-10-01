## Manual install

From Cloudflare's apt repository. On Debian 13, as root:

```bash
apt update && apt install -y curl
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /etc/apt/keyrings/cloudflared.gpg
cat > /etc/apt/sources.list.d/cloudflared.sources <<'EOF'
Types: deb
URIs: https://pkg.cloudflare.com/cloudflared
Suites: any
Components: main
Signed-By: /etc/apt/keyrings/cloudflared.gpg
EOF
apt update && apt install -y cloudflared
```

## Docker

```yaml
services:
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel run
    environment:
      - TUNNEL_TOKEN=your-tunnel-token
```

## Using it

A Cloudflare Tunnel publishes apps on your domain without opening any port on your router. You need a free Cloudflare account with your domain on it.

1. In the Cloudflare dashboard open **Zero Trust > Networks > Tunnels > Create a tunnel**, choose **Cloudflared**, and name it.
2. Copy the install command it shows. In the container, run only the token part:
   `cloudflared service install <token>`
3. The tunnel shows as **Healthy** in the dashboard.
4. **Public Hostname > Add**: subdomain `jellyfin`, domain `example.com`, service `http://192.168.1.42:8096`. Save, and `https://jellyfin.example.com` works within a minute, with HTTPS.

Protect private apps with **Zero Trust > Access > Applications**: add a login page (email code, Google, GitHub) in front of any hostname.
