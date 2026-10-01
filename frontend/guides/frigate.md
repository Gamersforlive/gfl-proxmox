## Manual install

Frigate runs in Docker. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/frigate/config /data/frigate && cd /opt/frigate
cat > compose.yaml <<'EOF'
services:
  frigate:
    image: ghcr.io/blakeblackshear/frigate:stable
    container_name: frigate
    restart: unless-stopped
    shm_size: "512mb"
    ports:
      - "8971:8971"
      - "8554:8554"
      - "8555:8555/tcp"
      - "8555:8555/udp"
    volumes:
      - ./config:/config
      - /data/frigate:/media/frigate
      - type: tmpfs
        target: /tmp/cache
        tmpfs:
          size: 1000000000
    devices:
      - /dev/dri:/dev/dri
EOF
docker compose up -d
docker logs frigate 2>&1 | grep -i password
```

Raise `shm_size` with more or higher-resolution cameras (the Frigate docs have a calculator).

## Docker

The steps above are the Docker install.

## Using it

1. Open `https://<container-ip>:8971`, accept the certificate warning, and log in as `admin` with the password from `/root/frigate.creds`.
2. Add a camera to `/opt/frigate/config/config.yml` (or edit it under **Settings > Configuration editor**):

```yaml
cameras:
  frontdoor:
    ffmpeg:
      hwaccel_args: preset-vaapi
      inputs:
        - path: rtsp://user:password@192.168.1.100:554/stream1
          roles: [detect, record]
    detect:
      width: 1280
      height: 720
record:
  enabled: true
  retain:
    days: 7
```

3. Save and restart Frigate. The camera appears with live view, and people and cars get boxes around them.
4. Find your camera's RTSP address in its app or manual (many use `/stream1` and `/stream2`; use the low-resolution stream for `detect`).
5. Connect to Home Assistant with the **Frigate** integration (via HACS) for notifications and automations.
