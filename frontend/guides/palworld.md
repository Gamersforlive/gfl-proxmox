## Manual install

With SteamCMD. On Debian 13, as root (see the Valheim guide for the SteamCMD part):

```bash
apt update && apt install -y curl lib32gcc-s1 lib32stdc++6 screen
useradd -r -m -d /opt/steam -s /bin/bash steam
mkdir -p /opt/steam/steamcmd /opt/palworld /opt/steam/.steam/sdk64
curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C /opt/steam/steamcmd
chown -R steam:steam /opt/steam /opt/palworld
runuser -u steam -- /opt/steam/steamcmd/steamcmd.sh +force_install_dir /opt/palworld +login anonymous +app_update 2394010 validate +quit
ln -sf /opt/steam/steamcmd/linux64/steamclient.so /opt/steam/.steam/sdk64/steamclient.so
runuser -u steam -- /opt/palworld/PalServer.sh -port=8211 -players=16 -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS
```

## Docker

```yaml
services:
  palworld:
    image: thijsvanloef/palworld-server-docker:latest
    container_name: palworld
    restart: unless-stopped
    environment:
      - PLAYERS=16
      - SERVER_NAME=My Palworld
      - ADMIN_PASSWORD=change-me
      - SERVER_PASSWORD=
      - MULTIPLAYER=true
    ports:
      - "8211:8211/udp"
      - "27015:27015/udp"
    volumes:
      - ./palworld:/palworld
```

## Using it

1. In Palworld: **Join Multiplayer Game**, enter `<container-ip>:8211` at the bottom and connect.
2. Settings are in `/opt/palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` (one long line). Change `ServerName`, `ServerPassword`, rates like `ExpRate`, then `systemctl restart palworld`.
3. Become admin in game: open chat and type `/AdminPassword <password>` with the password from `/root/palworld.creds`.
4. Forward **UDP 8211** for friends outside your network.

Palworld slowly uses more memory the longer it runs; a nightly restart helps (`systemctl restart palworld` from cron). Saves are in `Pal/Saved/SaveGames`.
