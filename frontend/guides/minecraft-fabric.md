## Manual install

Java 25 plus Fabric's server launcher. On Debian 13, as root:

```bash
apt update && apt install -y curl jq screen
mkdir -p /opt/java-25
curl -fsSL "https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jre/hotspot/normal/eclipse" | tar -xz -C /opt/java-25 --strip-components=1
ln -sf /opt/java-25/bin/java /usr/local/bin/java
useradd -r -m -d /opt/minecraft -s /bin/bash minecraft && cd /opt/minecraft
M=https://meta.fabricmc.net/v2/versions
GAME=$(curl -fsSL $M/game | jq -r '[.[]|select(.stable)][0].version')
LOADER=$(curl -fsSL $M/loader | jq -r '[.[]|select(.stable)][0].version')
INSTALLER=$(curl -fsSL $M/installer | jq -r '[.[]|select(.stable)][0].version')
curl -fsSL -o fabric-server.jar "$M/loader/$GAME/$LOADER/$INSTALLER/server/jar"
echo "eula=true" > eula.txt      # only if you accept https://aka.ms/MinecraftEULA
chown -R minecraft:minecraft /opt/minecraft
runuser -u minecraft -- java -Xmx3G -jar fabric-server.jar nogui
```

## Docker

```yaml
services:
  minecraft:
    image: itzg/minecraft-server:latest
    container_name: minecraft-fabric
    restart: unless-stopped
    tty: true
    stdin_open: true
    environment:
      - EULA=TRUE
      - TYPE=FABRIC
      - VERSION=LATEST
      - MEMORY=3G
      - MODRINTH_PROJECTS=fabric-api,lithium
    ports:
      - "25565:25565"
    volumes:
      - ./data:/data
```

## Using it

1. Join from Minecraft with the Fabric loader installed (same Minecraft version) at `<container-ip>`.
2. Add mods: download the **Fabric** versions from modrinth.com into `/opt/minecraft/mods` and `systemctl restart minecraft`. Almost every mod needs **Fabric API**.
3. Server-side performance mods (Lithium, FerriteCore, Krypton) work without players installing them.
4. The console: `mc-console` (leave with Ctrl+A, then D). Make yourself operator with `op YourName`.
5. Settings in `/opt/minecraft/server.properties`; forward **TCP 25565** for friends outside your network.

`update` downloads the newest Fabric loader for the same Minecraft version. To move to another Minecraft version: `MC_VERSION=1.21.1 /opt/minecraft/fabric-update.sh` (and matching mods), then restart.
