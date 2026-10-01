## Manual install

With SteamCMD. On Debian 13, as root:

```bash
apt update && apt install -y curl lib32gcc-s1 lib32stdc++6 screen
useradd -r -m -d /opt/steam -s /bin/bash steam
mkdir -p /opt/steam/steamcmd /opt/zomboid
curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C /opt/steam/steamcmd
chown -R steam:steam /opt/steam /opt/zomboid
runuser -u steam -- /opt/steam/steamcmd/steamcmd.sh +force_install_dir /opt/zomboid +login anonymous +app_update 380870 validate +quit
runuser -u steam -- /opt/zomboid/start-server.sh -servername myserver -adminpassword 'choose-one'
```

The memory limit is the `-Xmx` value in `/opt/zomboid/ProjectZomboid64.json`.

## Docker

```yaml
services:
  zomboid:
    image: renegademaster/zomboid-dedicated-server:latest
    container_name: zomboid
    restart: unless-stopped
    environment:
      - SERVER_NAME=myserver
      - ADMIN_PASSWORD=choose-one
      - MAX_RAM=6144m
    ports:
      - "16261:16261/udp"
      - "16262:16262/udp"
    volumes:
      - ./server:/home/steam/ZomboidDedicatedServer
      - ./data:/home/steam/Zomboid
```

## Using it

1. In Project Zomboid: **Join > Add server**, IP `<container-ip>`, port `16261`. Create an account by joining with any user name and password.
2. Log in as `admin` with the password from `/root/project-zomboid.creds` to manage the server in game.
3. Settings: `/opt/steam/Zomboid/Server/gfl.ini` (public listing, password, PvP, max players) and `gfl_SandboxVars.lua` (zombies, loot, world). Restart afterwards: `systemctl restart zomboid`.
4. The console: `game-console` in the container (leave with Ctrl+A, then D). Type `help` for commands like `save`, `quit` or `additem`.
5. Forward **UDP 16261-16262** for friends outside your network.

Mods: add Workshop IDs to `WorkshopItems=` and mod IDs to `Mods=` in `gfl.ini`; the server downloads them on start.
