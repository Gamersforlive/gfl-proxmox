## Manual install

These are the same steps the script runs, for a Debian 13 machine, VM or container you made yourself. Run them as root.

```bash
apt update && apt install -y curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg
cat > /etc/apt/sources.list.d/jellyfin.sources <<'EOF'
Types: deb
URIs: https://repo.jellyfin.org/debian
Suites: trixie
Components: main
Signed-By: /etc/apt/keyrings/jellyfin.gpg
EOF
apt update && apt install -y jellyfin
systemctl enable --now jellyfin
```

### Hardware transcoding (Intel or AMD)

Pass `/dev/dri` into the container first (the [Add GPU to a container](#add-gpu-lxc) tool does it), then:

```bash
apt install -y va-driver-all vainfo
usermod -aG video,render jellyfin
systemctl restart jellyfin
vainfo
```

### Media folders

Jellyfin only needs to read your media. If you share one `/data` folder with Radarr and Sonarr, let Jellyfin join the shared group:

```bash
groupadd -g 1000 media 2>/dev/null; usermod -aG media jellyfin
```

## Docker

Use the official image. Put this in `compose.yaml` and run `docker compose up -d`:

```yaml
services:
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "8096:8096"
    volumes:
      - ./config:/config
      - ./cache:/cache
      - /data/media:/data/media:ro
    devices:
      - /dev/dri:/dev/dri   # remove this line if you have no Intel/AMD GPU
```

Open `http://<server-ip>:8096`. Inside Docker the libraries are at `/data/media/...`, the path on the right of the volume line.

## Using it

1. Open `http://<container-ip>:8096` and pick your language.
2. Create your admin account. Use a real password: this is also the login for the apps.
3. Add a library for each kind of media: **Movies** pointing at `/data/media/movies`, **Shows** at `/data/media/tv`, **Music** at `/data/media/music`.
4. Finish the wizard and let the first scan run. Covers and descriptions appear as it goes.

### Turn on hardware transcoding

Go to **Dashboard > Playback > Transcoding**, choose **Video Acceleration API (VAAPI)** and device `/dev/dri/renderD128`, tick the codecs your GPU supports, and save. Play a video, open the menu and pick a lower quality; the dashboard shows the transcode using the GPU.

### Watch everywhere

- Install the Jellyfin app on Android, iOS, Android TV, Fire TV, Roku or LG/Samsung TVs and enter `http://<container-ip>:8096`.
- Add users for family and friends under **Dashboard > Users**, and choose which libraries each one sees.
- To watch away from home, put Jellyfin behind [Nginx Proxy Manager](#nginx-proxy-manager) or a [Cloudflare tunnel](#cloudflared), or use [WireGuard](#wg-easy).

> Want Jellyfin to fill itself? The [Media bundle](#media-stack) connects Jellyfin to Radarr, Sonarr and Seerr automatically.
