## Manual install

Paper on Java 25 (Eclipse Temurin), as a service with a console. On Debian 13, as root:

```bash
apt update && apt install -y curl jq screen
mkdir -p /opt/java
curl -fsSL "https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jre/hotspot/normal/eclipse" | tar -xz -C /opt/java --strip-components=1
ln -sf /opt/java/bin/java /usr/local/bin/java
useradd -r -m -d /opt/minecraft -s /bin/bash minecraft
cd /opt/minecraft
VER=26.2   # a Minecraft version with a stable Paper build (see papermc.io/downloads)
URL=$(curl -fsSL -H "User-Agent: my-server" "https://fill.papermc.io/v3/projects/paper/versions/$VER/builds" | jq -r 'map(select(.channel=="STABLE")) | .[0].downloads["server:default"].url')
curl -fsSL -o paper.jar "$URL"
echo "eula=true" > eula.txt     # only if you accept https://aka.ms/MinecraftEULA
chown -R minecraft:minecraft /opt/minecraft
cat > /etc/systemd/system/minecraft.service <<'EOF'
[Unit]
Description=Minecraft server (Paper)
After=network-online.target

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/screen -DmS minecraft /usr/local/bin/java -Xms3G -Xmx3G -jar paper.jar --nogui
ExecStop=/usr/bin/screen -p 0 -S minecraft -X eval 'stuff "stop"\015'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now minecraft
```

Set `-Xms`/`-Xmx` to the container's memory minus about 768 MB.

## Docker

The itzg image runs any server type and downloads it for you:

```yaml
services:
  minecraft:
    image: itzg/minecraft-server:latest
    container_name: minecraft
    restart: unless-stopped
    tty: true
    stdin_open: true
    environment:
      - EULA=TRUE
      - TYPE=PAPER
      - VERSION=LATEST
      - MEMORY=3G
    ports:
      - "25565:25565"
    volumes:
      - ./data:/data
```

## Using it

1. In Minecraft: **Multiplayer > Add Server**, address `<container-ip>` (port 25565 is the default).
2. Open the console in the container with `mc-console`; leave it with **Ctrl+A**, then **D** (the server keeps running). Make yourself operator: `op YourName`.
3. Settings are in `/opt/minecraft/server.properties`: `motd`, `max-players`, `difficulty`, `white-list=true`. Restart after changing them: `systemctl restart minecraft`.
4. Plugins: drop `.jar` files from hangar.papermc.io or modrinth.com into `/opt/minecraft/plugins` and restart.
5. Friends outside your network: forward TCP **25565** on your router to the container.

### Updating and versions

`update` in the container gets the newest Paper build for your current version. Switch versions with `MC_VERSION=26.2 /opt/minecraft/paper-update.sh`, then restart. Back up the world folders first.
