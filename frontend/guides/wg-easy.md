## Manual install

wg-easy ships as a Docker image. The WireGuard kernel module lives on the Proxmox host, so load it there first:

```bash
# on the Proxmox host
modprobe wireguard && echo wireguard >> /etc/modules
```

Then on Debian 13 with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/wg-easy && cd /opt/wg-easy
cat > compose.yaml <<'EOF'
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:15
    container_name: wg-easy
    restart: unless-stopped
    environment:
      - INSECURE=true
      - DISABLE_IPV6=true
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    volumes:
      - ./data:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. `INSECURE=true` allows the admin page over plain http on your LAN; remove it if you put wg-easy behind HTTPS.

## Using it

1. Open `http://<container-ip>:51821` and run the setup wizard: create the admin account, then enter your public address (your home IP or a dynamic DNS name such as `home.duckdns.org`) and port 51820.
2. On your router, forward **UDP 51820** to this container.
3. **New client**: give it a name (one per device).
4. On your phone, install the WireGuard app and scan the QR code. On a laptop, download the config file and import it.
5. Turn the tunnel on: you can now reach your home network, Proxmox and all your apps from anywhere.

Remove a lost device by deleting its client. Don't expose port 51821 itself to the internet.
