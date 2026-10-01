## Manual install

The official dedicated server from terraria.org. On Debian 13, as root:

```bash
apt update && apt install -y curl unzip screen
NAME=$(curl -fsSL https://terraria.org/api/get/dedicated-servers-names | sed -n 's/^\["\([^"]*\)".*/\1/p')
curl -fsSL "https://terraria.org/api/download/pc-dedicated-server/${NAME}" -o /tmp/terraria.zip
unzip -q /tmp/terraria.zip -d /tmp/terraria
mkdir -p /opt/terraria/server /opt/terraria/worlds
cp -r /tmp/terraria/*/Linux/. /opt/terraria/server/
chmod +x /opt/terraria/server/TerrariaServer.bin.x86_64
cd /opt/terraria/server && ./TerrariaServer.bin.x86_64 -config /opt/terraria/serverconfig.txt
```

With `serverconfig.txt`:

```text
world=/opt/terraria/worlds/World.wld
autocreate=2
worldname=World
difficulty=0
maxplayers=8
port=7777
password=
```

## Docker

```yaml
services:
  terraria:
    image: ryshe/terraria:latest
    container_name: terraria
    restart: unless-stopped
    stdin_open: true
    tty: true
    command: -world /root/.local/share/Terraria/Worlds/World.wld -autocreate 2
    ports:
      - "7777:7777"
    volumes:
      - ./worlds:/root/.local/share/Terraria/Worlds
```

## Using it

1. In Terraria: **Multiplayer > Join via IP**, enter `<container-ip>` and port `7777`.
2. Change the password, world size (`autocreate=1` small, `2` medium, `3` large), difficulty and player count in `/opt/terraria/serverconfig.txt`, then `systemctl restart terraria`.
3. Open the console with `game-console` (leave with Ctrl+A, then D). Useful commands: `save`, `kick <player>`, `ban <player>`, `password <new>`, `exit`.
4. Bring an existing world: copy its `.wld` file to `/opt/terraria/worlds` and set `world=` to it.
5. Forward **TCP 7777** for friends outside your network.

For mods, use tModLoader's own server instead; for server-side plugins, TShock.
