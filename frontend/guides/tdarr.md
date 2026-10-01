## Manual install

The script runs Tdarr's image with a built-in worker node. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/tdarr/{server,configs,logs,cache} && cd /opt/tdarr
cat > compose.yaml <<'EOF'
services:
  tdarr:
    image: ghcr.io/haveagitgat/tdarr:latest
    container_name: tdarr
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - serverIP=0.0.0.0
      - serverPort=8266
      - webUIPort=8265
      - internalNode=true
      - inContainer=true
      - nodeName=node1
    ports:
      - "8265:8265"
      - "8266:8266"
    volumes:
      - ./server:/app/server
      - ./configs:/app/configs
      - ./logs:/app/logs
      - ./cache:/temp
      - /data/media:/media
    devices:
      - /dev/dri:/dev/dri
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. Remove the `devices:` lines if you have no Intel/AMD GPU.

## Using it

1. Open `http://<container-ip>:8265`.
2. **Libraries > Library +**: source `/media/movies`, a transcode cache folder (`/temp`), and turn on **Folder watch**.
3. **Transcode options**: pick a flow or classic plugins. A common goal is "convert to H.265 (HEVC), keep the best audio, remove extra subtitles". Start with community flows for VAAPI or CPU.
4. On the **Nodes** panel, set how many transcode and health-check workers run at once (one or two for a GPU).
5. The dashboard shows each file's progress and how much space you've saved.

> Tdarr replaces originals once a transcode succeeds. Test on a small library first and keep backups of anything you can't download again.
