## Manual install

Mojang's Bedrock Dedicated Server. On Debian 13, as root:

```bash
apt update && apt install -y curl jq unzip screen libcurl4t64
URL=$(curl -fsSL -A "Mozilla/5.0" https://net-secondary.web.minecraft-services.net/api/v1.0/download/links \
  | jq -r '.result.links[] | select(.downloadType=="serverBedrockLinux") | .downloadUrl')
mkdir -p /opt/minecraft && cd /opt/minecraft
curl -fsSL -A "Mozilla/5.0" -o bedrock.zip "$URL" && unzip -q bedrock.zip && rm bedrock.zip
LD_LIBRARY_PATH=. ./bedrock_server
```

When updating by hand, don't overwrite `server.properties`, `permissions.json`, `allowlist.json` or the `worlds` folder.

## Docker

```yaml
services:
  bedrock:
    image: itzg/minecraft-bedrock-server:latest
    container_name: minecraft-bedrock
    restart: unless-stopped
    tty: true
    stdin_open: true
    environment:
      - EULA=TRUE
      - VERSION=LATEST
    ports:
      - "19132:19132/udp"
    volumes:
      - ./data:/data
```

## Using it

1. In Minecraft (Windows, Android, iOS): **Play > Servers > Add Server**, address `<container-ip>`, port `19132`.
2. Settings in `/opt/minecraft/server.properties`: `server-name`, `gamemode`, `difficulty`, `allow-cheats`, `max-players`, `level-name`. Restart with `systemctl restart minecraft`.
3. Operators: in `mc-console`, type `op YourGamertag`. Leave the console with Ctrl+A, then D.
4. Only friends: add players with `allowlist add <gamertag>`, then `allowlist on`. (New Bedrock versions ship with an empty allow list switched on; the script turns it off so you can join straight away.)
5. Forward **UDP 19132** for friends outside your network.

### Network transport

Newer Bedrock servers can use two network transports, set with `transport=` in `server.properties`. The script picks `raknet`, the classic one: players connect by IP and port, and port forwarding works as described above. The newer `nethernet` (the server's own default) routes connections through Xbox's signaling service. Try it only if a future game version stops supporting RakNet.

Consoles (Xbox, PlayStation, Switch) can't add custom servers directly; use a DNS-based helper like BedrockConnect or a Realm for those players.
