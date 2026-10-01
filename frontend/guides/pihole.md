## Manual install

The script runs Pi-hole's official image. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/pihole/etc-pihole && cd /opt/pihole
cat > compose.yaml <<'EOF'
services:
  pihole:
    image: pihole/pihole:latest
    container_name: pihole
    restart: unless-stopped
    environment:
      - TZ=Europe/Amsterdam
      - FTLCONF_webserver_api_password=choose-a-password
      - FTLCONF_dns_listeningMode=all
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "80:80/tcp"
    volumes:
      - ./etc-pihole:/etc/pihole
EOF
docker compose up -d
```

Without Docker, Pi-hole's own installer works too: `curl -sSL https://install.pi-hole.net | bash` (it asks a few questions).

## Docker

The steps above are the Docker install. Port 53 must be free on the machine.

## Using it

1. Open `http://<container-ip>/admin` and log in with the password from `/root/pihole.creds`.
2. Point your network at it: in your router's DHCP settings, set the **DNS server** to the Pi-hole's IP. Devices pick it up when they renew their address (or reconnect).
3. The dashboard shows queries and blocked percentages. **Query Log** lists every lookup.
4. **Adlists**: add more blocklists (for example from firebog.net), then **Tools > Update Gravity**.
5. A site broken? Find the blocked domain in the Query Log and click **Allow**.

Run two Pi-holes (or Pi-hole plus AdGuard Home) and give your router both, so DNS keeps working while one restarts.
