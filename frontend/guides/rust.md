## Manual install

With SteamCMD. On Debian 13, as root:

```bash
apt update && apt install -y curl lib32gcc-s1 lib32stdc++6 screen
useradd -r -m -d /opt/steam -s /bin/bash steam
mkdir -p /opt/steam/steamcmd /opt/rust
curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz | tar -xz -C /opt/steam/steamcmd
chown -R steam:steam /opt/steam /opt/rust
runuser -u steam -- /opt/steam/steamcmd/steamcmd.sh +force_install_dir /opt/rust +login anonymous +app_update 258550 validate +quit
cd /opt/rust && export LD_LIBRARY_PATH=/opt/rust/RustDedicated_Data/Plugins/x86_64
runuser -u steam -- ./RustDedicated -batchmode +server.port 28015 +server.level "Procedural Map" \
  +server.seed 12345 +server.worldsize 3500 +server.maxplayers 50 +server.hostname "My Rust" \
  +server.identity myserver +rcon.port 28016 +rcon.password 'choose-one' +rcon.web 1
```

## Docker

```yaml
services:
  rust:
    image: didstopia/rust-server:latest
    container_name: rust
    restart: unless-stopped
    environment:
      - RUST_SERVER_NAME=My Rust
      - RUST_SERVER_SEED=12345
      - RUST_SERVER_WORLDSIZE=3500
      - RUST_RCON_PASSWORD=choose-one
    ports:
      - "28015:28015/udp"
      - "28016:28016/tcp"
    volumes:
      - ./rust:/steamcmd/rust
```

## Using it

1. In Rust, press **F1** and type `client.connect <container-ip>:28015`.
2. Settings are in `/opt/rust/server.env` (name, players, map size, seed). Restart with `systemctl restart rust`. The first start generates the map, which takes a few minutes.
3. Admin: use web RCON (for example the RustAdmin app or rcon.io) with the container's IP, port 28016 and the password from `/root/rust.creds`. Make yourself owner with `ownerid <your steamid64> "name"` and `server.writecfg`.
4. **Wipes**: change `SEED` (new map) and delete `/opt/rust/server/gfl` to start fresh.
5. Forward **UDP 28015** (game) for friends outside your network.

Plugins: install the Oxide/uMod or Carbon framework into `/opt/rust`, then drop plugins into its plugins folder. Re-install the framework after each game update.
