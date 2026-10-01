## Manual install

Home Assistant's official container. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/home-assistant/config && cd /opt/home-assistant
cat > compose.yaml <<'EOF'
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: homeassistant
    restart: unless-stopped
    network_mode: host
    privileged: true
    environment:
      - TZ=Europe/Amsterdam
    volumes:
      - ./config:/config
      - /run/dbus:/run/dbus:ro
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. Host networking is needed for discovery of devices like Chromecasts, Hue bridges and Sonos.

## Using it

1. Open `http://<container-ip>:8123`, create your account and set your home's location.
2. Home Assistant lists devices it found; add them. Add others under **Settings > Devices & services > Add integration**.
3. Build dashboards, and automations under **Settings > Automations & scenes** ("turn the porch light on at sunset").
4. Install the companion app on your phone for notifications, presence and location.

### Container vs the VM

This version has no **Add-on store**. Run what add-ons would give you as separate apps: [Mosquitto](#mosquitto), [Zigbee2MQTT](#zigbee2mqtt), [Node-RED](#node-red), [Frigate](#frigate). Prefer add-ons and one-click backups? Use the [Home Assistant OS VM](#haos-vm) instead.

### USB sticks

Pass the stick into the Proxmox container first (on the host: `pct set <ID> -dev0 /dev/serial/by-id/<your-stick>`), then add it under `devices:` in `compose.yaml` and `docker compose up -d`.
