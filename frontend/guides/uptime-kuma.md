## Manual install

From source on Node.js 22, as the script does. On Debian 13, as root:

```bash
apt update && apt install -y curl gnupg git
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
apt update && apt install -y nodejs
git clone https://github.com/louislam/uptime-kuma.git /opt/uptime-kuma && cd /opt/uptime-kuma
git checkout "$(git describe --tags "$(git rev-list --tags --max-count=1)")"
npm ci --omit dev && npm run download-dist
cat > /etc/systemd/system/uptime-kuma.service <<'EOF'
[Unit]
Description=Uptime Kuma
After=network.target

[Service]
WorkingDirectory=/opt/uptime-kuma
ExecStart=/usr/bin/node server/server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now uptime-kuma
```

## Docker

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:2
    container_name: uptime-kuma
    restart: unless-stopped
    ports:
      - "3001:3001"
    volumes:
      - ./data:/app/data
```

## Using it

1. Open `http://<container-ip>:3001` and create the admin account.
2. **Add New Monitor**:
   - **HTTP(s)** for websites and web apps (checks the page loads and, optionally, contains a word).
   - **TCP Port** for anything with a port, like a database or a game server.
   - **Ping** for machines.
   - **DNS** to check a domain resolves.
3. **Settings > Notifications > Setup Notification**: Discord webhook, Telegram, email and 90+ others. Attach it to your monitors.
4. **Status Pages > New Status Page**: a public page showing your services, like the ones big sites have.

Tip: set the check interval to 60 seconds and **Retries** to 2 so a single hiccup doesn't page you.
