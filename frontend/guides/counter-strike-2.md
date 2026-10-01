## Manual install

With SteamCMD (about 60 GB). On Debian 13, as root:

```bash
apt update && apt install -y curl lib32gcc-s1 lib32stdc++6 screen
useradd -r -m -d /opt/steam -s /bin/bash steam
mkdir -p /opt/steam/steamcmd /opt/cs2 /opt/steam/.steam/sdk64
curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C /opt/steam/steamcmd
chown -R steam:steam /opt/steam /opt/cs2
runuser -u steam -- /opt/steam/steamcmd/steamcmd.sh +force_install_dir /opt/cs2 +login anonymous +app_update 730 validate +quit
ln -sf /opt/steam/steamcmd/linux64/steamclient.so /opt/steam/.steam/sdk64/steamclient.so
runuser -u steam -- /opt/cs2/game/bin/linuxsteamrt64/cs2 -dedicated -usercon -port 27015 +game_type 0 +game_mode 1 +map de_dust2
```

## Docker

```yaml
services:
  cs2:
    image: joedwards32/cs2:latest
    container_name: cs2
    restart: unless-stopped
    environment:
      - CS2_SERVERNAME=My CS2 server
      - CS2_RCONPW=choose-one
      - CS2_STARTMAP=de_dust2
      - SRCDS_TOKEN=          # Game Server Login Token, optional
    ports:
      - "27015:27015/tcp"
      - "27015:27015/udp"
      - "27020:27020/udp"
    volumes:
      - ./cs2:/home/steam/cs2-dedicated
```

## Using it

1. In Counter-Strike 2, open the console (enable it under **Settings > Game > Enable Developer Console**) and type `connect <container-ip>:27015`.
2. Change name and passwords in `/opt/cs2/game/csgo/cfg/server.cfg`, and map, mode and players in `/opt/cs2/server.env`. Restart: `systemctl restart cs2`.
3. Common modes: casual `GAME_TYPE=0 GAME_MODE=0`, competitive `0 1`, wingman `0 2`, deathmatch `1 2`.
4. Remote control from the game console: `rcon_password <password from /root/counter-strike-2.creds>`, then `rcon changelevel de_mirage`.
5. To be listed publicly and let friends find it, get a **Game Server Login Token** for app 730 at steamcommunity.com/dev/managegameservers, put it in `GSLT=` in `server.env`, and forward **27015 TCP and UDP**.
