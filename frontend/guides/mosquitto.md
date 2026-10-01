## Manual install

From Debian's packages, with logins turned on. On Debian 13, as root:

```bash
apt update && apt install -y mosquitto mosquitto-clients
mosquitto_passwd -c /etc/mosquitto/passwd gfl          # asks for a password
chown mosquitto:mosquitto /etc/mosquitto/passwd && chmod 700 /etc/mosquitto/passwd
cat > /etc/mosquitto/conf.d/gfl.conf <<'EOF'
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwd
EOF
systemctl restart mosquitto
```

## Docker

```yaml
services:
  mosquitto:
    image: eclipse-mosquitto:2
    container_name: mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"
    volumes:
      - ./config:/mosquitto/config
      - ./data:/mosquitto/data
```

Put the three config lines above in `./config/mosquitto.conf` (with `password_file /mosquitto/config/passwd`), and create the password file with `docker compose exec mosquitto mosquitto_passwd -c /mosquitto/config/passwd gfl`.

## Using it

MQTT is a message bus: devices **publish** messages to topics and others **subscribe** to them. Home Assistant, Zigbee2MQTT, Tasmota and ESPHome devices all speak it.

Test it from inside the container (password from `/root/mosquitto.creds`):

```bash
mosquitto_sub -h localhost -u gfl -P 'your-password' -t 'test/#' -v &
mosquitto_pub -h localhost -u gfl -P 'your-password' -t test/hello -m 'it works'
```

### Connect Home Assistant

**Settings > Devices & services > Add integration > MQTT**: broker = this container's IP, port 1883, user `gfl` and the password. Devices that announce themselves over MQTT then appear automatically.

Add a separate user per device or app: `mosquitto_passwd /etc/mosquitto/passwd <name>`, then `systemctl restart mosquitto`.
