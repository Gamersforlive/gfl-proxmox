## Manual install

The official headless server, which is free to download. On Debian 13, as root:

```bash
apt update && apt install -y curl xz-utils
useradd -r -m -d /opt/factorio -s /usr/sbin/nologin factorio
curl -fsSL https://factorio.com/get-download/stable/headless/linux64 -o /tmp/factorio.tar.xz
tar -xJf /tmp/factorio.tar.xz -C /opt
cp /opt/factorio/data/server-settings.example.json /opt/factorio/data/server-settings.json
mkdir -p /opt/factorio/saves && chown -R factorio:factorio /opt/factorio
runuser -u factorio -- /opt/factorio/bin/x64/factorio --create /opt/factorio/saves/world.zip
cat > /etc/systemd/system/factorio.service <<'EOF'
[Unit]
Description=Factorio dedicated server
After=network-online.target

[Service]
User=factorio
WorkingDirectory=/opt/factorio
ExecStart=/opt/factorio/bin/x64/factorio --start-server-load-latest --server-settings /opt/factorio/data/server-settings.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now factorio
```

## Docker

```yaml
services:
  factorio:
    image: factoriotools/factorio:stable
    container_name: factorio
    restart: unless-stopped
    ports:
      - "34197:34197/udp"
      - "27015:27015/tcp"
    volumes:
      - ./data:/factorio
```

## Using it

1. In Factorio: **Multiplayer > Connect to address**, enter `<container-ip>` (UDP port 34197 is the default).
2. Edit `/opt/factorio/data/server-settings.json`:
   - `name` and `description`: what players see
   - `game_password`: a password to join
   - `visibility.public`: `true` lists it in the public server browser (needs your factorio.com `username` and `token`)
   Then `systemctl restart factorio`.
3. Admins: create `/opt/factorio/server-adminlist.json` with `["YourName"]`.
4. Friends outside your network: forward **UDP 34197** to the container.

### Saves and mods

Saves are in `/opt/factorio/saves`; the server loads the newest one. Upload an existing save there to continue it. Put mods (with `mod-list.json`) in `/opt/factorio/mods`. Space Age needs every player to own the expansion.
