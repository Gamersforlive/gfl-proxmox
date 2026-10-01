## Manual install

On Node.js 22, running as its own user. On Debian 13, as root:

```bash
apt update && apt install -y curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
apt update && apt install -y nodejs
npm install -g --unsafe-perm node-red
useradd -r -m -d /var/lib/node-red -s /usr/sbin/nologin nodered
cat > /etc/systemd/system/node-red.service <<'EOF'
[Unit]
Description=Node-RED
After=network.target

[Service]
User=nodered
WorkingDirectory=/var/lib/node-red
ExecStart=/usr/bin/env node-red --userDir /var/lib/node-red
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now node-red
```

## Docker

```yaml
services:
  node-red:
    image: nodered/node-red:latest
    container_name: node-red
    restart: unless-stopped
    ports:
      - "1880:1880"
    volumes:
      - ./data:/data
```

## Using it

1. Open `http://<container-ip>:1880`. You see the editor: nodes on the left, your flow in the middle.
2. Drag an **inject** node and a **debug** node onto the canvas, wire them together and click **Deploy**. Click the inject button: the message appears in the debug panel on the right.
3. Install more nodes under **Menu > Manage palette > Install**, for example `node-red-contrib-home-assistant-websocket` for Home Assistant.
4. Connect to [Mosquitto](#mosquitto) with the **mqtt in** and **mqtt out** nodes.

### Add a login first

The editor has no password by default. Generate a password hash and add it to `/var/lib/node-red/settings.js`:

```bash
node-red admin hash-pw
```

```javascript
adminAuth: {
    type: "credentials",
    users: [{ username: "admin", password: "<the hash>", permissions: "*" }]
},
```

Restart with `systemctl restart node-red`.
