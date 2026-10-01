## Manual install

NeoForge's installer sets up the server. For Minecraft 1.21.1 (NeoForge 21.1.x, Java 21), on Debian 13, as root:

```bash
apt update && apt install -y curl jq screen
mkdir -p /opt/java-21
curl -fsSL "https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jre/hotspot/normal/eclipse" | tar -xz -C /opt/java-21 --strip-components=1
ln -sf /opt/java-21/bin/java /usr/local/bin/java
useradd -r -m -d /opt/minecraft -s /bin/bash minecraft && cd /opt/minecraft
NEO=$(curl -fsSL "https://maven.neoforged.net/api/maven/latest/version/releases/net/neoforged/neoforge?filter=21.1." | jq -r .version)
curl -fsSL -o /tmp/installer.jar "https://maven.neoforged.net/releases/net/neoforged/neoforge/${NEO}/neoforge-${NEO}-installer.jar"
chown -R minecraft:minecraft /opt/minecraft
runuser -u minecraft -- java -jar /tmp/installer.jar --installServer /opt/minecraft
echo "eula=true" > eula.txt      # only if you accept https://aka.ms/MinecraftEULA
printf -- '-Xms6G\n-Xmx6G\n' > user_jvm_args.txt
runuser -u minecraft -- ./run.sh nogui
```

The `filter` ends with a dot on purpose: `21.1` alone would also match `21.11`.

## Docker

```yaml
services:
  minecraft:
    image: itzg/minecraft-server:latest
    container_name: minecraft-neoforge
    restart: unless-stopped
    tty: true
    stdin_open: true
    environment:
      - EULA=TRUE
      - TYPE=NEOFORGE
      - VERSION=1.21.1
      - MEMORY=6G
    ports:
      - "25565:25565"
    volumes:
      - ./data:/data
```

## Using it

### Run a modpack

1. Download the pack's **server files** from CurseForge or Modrinth (or export them from your launcher), and check its NeoForge and Minecraft version.
2. Stop the server: `systemctl stop minecraft`.
3. Copy the pack's `mods`, `config`, `defaultconfigs` and `kubejs` (if present) folders into `/opt/minecraft`.
4. Fix ownership: `chown -R minecraft:minecraft /opt/minecraft`, then `systemctl start minecraft`.
5. Watch the start-up in `mc-console`. Modpacks take a few minutes the first time.

Players need the same pack (client-only mods like minimaps and shaders don't go on the server).

### Everyday

- Memory: `/opt/minecraft/user_jvm_args.txt`; big packs want 6 to 10 GB.
- Settings: `/opt/minecraft/server.properties`. Operators: `op YourName` in the console.
- Another Minecraft version: create the container with `MC_VERSION` set (for example `MC_VERSION=26.1`), which also picks the right Java.
- Forward **TCP 25565** for friends outside your network. Back up the `world` folder before updating mods.
