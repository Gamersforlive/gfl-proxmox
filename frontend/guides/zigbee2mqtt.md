## Manual install

The script runs the official image. First pass your Zigbee adapter into the Proxmox container, on the host:

```bash
ls -l /dev/serial/by-id/                       # find your adapter
pct set <ID> -dev0 /dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus-if00-port0,mode=0666
pct reboot <ID>
```

Then, in the container with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/zigbee2mqtt/data && cd /opt/zigbee2mqtt
cat > compose.yaml <<'EOF'
services:
  zigbee2mqtt:
    image: koenkk/zigbee2mqtt:latest
    container_name: zigbee2mqtt
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./data:/app/data
      - /run/udev:/run/udev:ro
    devices:
      - /dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus-if00-port0:/dev/ttyUSB0
EOF
docker compose up -d
```

The script adds the `devices:` lines itself when it finds an adapter in the container. Network adapters (like the SLZB-06) need no device at all.

## Docker

The steps above are the Docker install.

## Using it

1. Install [Mosquitto](#mosquitto) first, if you don't have an MQTT broker.
2. Open `http://<container-ip>:8080`. The onboarding page asks for:
   - **Adapter**: the serial port (`/dev/ttyUSB0`) or the network address (`tcp://192.168.1.80:6638`)
   - **MQTT**: `mqtt://<mosquitto-ip>:1883` with its user and password
3. Submit; Zigbee2MQTT starts and shows the dashboard.
4. Click **Permit join (All)** and put a device in pairing mode (usually a long press). It appears within a minute.
5. In Home Assistant, the MQTT integration shows every Zigbee device automatically.

Rename devices in Zigbee2MQTT before adding them to automations, so their names stay readable everywhere.
