## Manual install

From the official release. On Debian 13, as root:

```bash
apt update && apt install -y curl libicu76
VER=$(curl -fsSL https://api.github.com/repos/Kareadita/Kavita/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
curl -fsSL "https://github.com/Kareadita/Kavita/releases/download/${VER}/kavita-linux-x64.tar.gz" | tar -xz -C /opt
groupadd -g 1000 media 2>/dev/null
useradd -r -g media -d /opt/Kavita -s /usr/sbin/nologin kavita
chown -R kavita:media /opt/Kavita
cat > /etc/systemd/system/kavita.service <<'EOF'
[Unit]
Description=Kavita
After=network.target

[Service]
User=kavita
WorkingDirectory=/opt/Kavita
ExecStart=/opt/Kavita/Kavita
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now kavita
```

## Docker

```yaml
services:
  kavita:
    image: jvmilazz0/kavita:latest
    container_name: kavita
    restart: unless-stopped
    ports:
      - "5000:5000"
    volumes:
      - ./config:/kavita/config
      - /data/media:/data/media
```

## Using it

1. Open `http://<container-ip>:5000` and create the admin account.
2. **Server Settings > Libraries > Add Library**: choose the type (Book, Manga, Comic) and the folder, for example `/data/media/books` or `/data/media/comics`.
3. Folder layout matters: one folder per series, for example `comics/Saga/Saga v01.cbz`.
4. Read in the browser on any device. Progress syncs, and you can use the OPDS feed (your profile shows the link) in apps like Panels or Chunky.
5. Invite family under **Server Settings > Users** and choose which libraries they see.
