## Manual install

AdGuard's own installer sets it up as a service in `/opt/AdGuardHome`. On Debian 13, as root:

```bash
apt update && apt install -y curl
curl -fsSL https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
```

Give the machine a static IP first: your whole network will use it for DNS.

## Docker

```yaml
services:
  adguardhome:
    image: adguard/adguardhome:latest
    container_name: adguardhome
    restart: unless-stopped
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3000:3000/tcp"
      - "80:80/tcp"
    volumes:
      - ./work:/opt/adguardhome/work
      - ./conf:/opt/adguardhome/conf
```

Port 53 must be free on the host: on Ubuntu, turn off the stub resolver of `systemd-resolved` first.

## Using it

1. Open `http://<container-ip>:3000` and follow the setup wizard. Keep DNS on port 53 and pick a port for the web interface (80 is the default after setup).
2. Create your admin login.
3. Point your devices at it. The easiest way is your router: set its DHCP **DNS server** to the AdGuard IP, so every device uses it automatically.
4. Check **Query Log**: you'll see requests arriving and ads being blocked.

### Make it better

- **Filters > DNS blocklists > Add blocklist**: add lists such as HaGeZi Multi or OISD for more blocking.
- **Settings > DNS settings**: use encrypted upstream servers like `https://dns.quad9.net/dns-query` or `https://cloudflare-dns.com/dns-query`.
- A site broken? Find the blocked domain in the Query Log and click **Unblock**.
- Add a second AdGuard container as backup DNS so internet keeps working when you reboot the first.
