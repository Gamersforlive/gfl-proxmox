## Manual install

With SteamCMD. On Debian 13, as root:

```bash
apt update && apt install -y curl lib32gcc-s1 lib32stdc++6 screen
useradd -r -m -d /opt/steam -s /bin/bash steam
mkdir -p /opt/steam/steamcmd /opt/satisfactory
curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C /opt/steam/steamcmd
chown -R steam:steam /opt/steam /opt/satisfactory
runuser -u steam -- /opt/steam/steamcmd/steamcmd.sh +force_install_dir /opt/satisfactory +login anonymous +app_update 1690800 validate +quit
runuser -u steam -- /opt/satisfactory/FactoryServer.sh -Port=7777 -ReliablePort=8888 -log -unattended
```

## Docker

```yaml
services:
  satisfactory:
    image: wolveix/satisfactory-server:latest
    container_name: satisfactory
    restart: unless-stopped
    environment:
      - MAXPLAYERS=4
    ports:
      - "7777:7777/udp"
      - "7777:7777/tcp"
      - "8888:8888/tcp"
    volumes:
      - ./config:/config
```

## Using it

1. In Satisfactory: **Server Manager > Add Server**, enter `<container-ip>` and port `7777`.
2. The first time, **claim** the server: give it a name and an admin password.
3. **Create Game**, choose a starting area, and load it. Players join from the Server Manager with the server's address (and the player password if you set one).
4. For friends outside your network, forward **7777 TCP and UDP** and **8888 TCP**.

Saves are in `/opt/steam/.config/Epic/FactoryGame/Saved/SaveGames/server`. Upload an existing save from the Server Manager's **Manage Saves** tab.
