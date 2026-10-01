## Manual install

With SteamCMD, as the script does. On Debian 13, as root:

```bash
apt update && apt install -y curl lib32gcc-s1 lib32stdc++6 screen
useradd -r -m -d /opt/steam -s /bin/bash steam
mkdir -p /opt/steam/steamcmd /opt/valheim
curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C /opt/steam/steamcmd
chown -R steam:steam /opt/steam /opt/valheim
runuser -u steam -- /opt/steam/steamcmd/steamcmd.sh +force_install_dir /opt/valheim +login anonymous +app_update 896660 validate +quit
```

Start it (as the steam user):

```bash
cd /opt/valheim
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH SteamAppId=892970
./valheim_server.x86_64 -nographics -batchmode -name "My Server" -port 2456 -world Dedicated -password "secret123" -public 0
```

The password needs at least 5 characters and may not appear in the server name.

## Docker

The community image `lloesche/valheim-server` handles updates and backups:

```yaml
services:
  valheim:
    image: lloesche/valheim-server:latest
    container_name: valheim
    restart: unless-stopped
    cap_add:
      - sys_nice
    environment:
      - SERVER_NAME=My Server
      - WORLD_NAME=Dedicated
      - SERVER_PASS=secret123
      - SERVER_PUBLIC=false
    ports:
      - "2456-2457:2456-2457/udp"
    volumes:
      - ./config:/config
      - ./data:/opt/valheim
```

## Using it

1. In Valheim: **Join Game > Add server**, enter `<container-ip>:2456`, and the password from `/root/valheim.creds`.
2. Change the name, world or password in `/opt/valheim/server.env`, then `systemctl restart valheim`.
3. Set `PUBLIC=1` to list the server in the community browser.
4. For friends outside your network, forward **UDP 2456-2457** on your router.

### Admins and worlds

- Make yourself admin: add your Steam ID (from the F2 panel in game) to `/opt/steam/valheim-data/adminlist.txt`.
- Worlds are in `/opt/steam/valheim-data/worlds_local`. To bring an existing world, copy its `.db` and `.fwl` files there and set `WORLD` to its name.
- `update` in the container stops the server, updates it through SteamCMD and starts it again.
