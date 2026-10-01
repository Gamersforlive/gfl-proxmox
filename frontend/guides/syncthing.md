## Manual install

From Syncthing's apt repository, running as its own user. On Debian 13, as root:

```bash
apt update && apt install -y curl
mkdir -p /etc/apt/keyrings
curl -fsSL https://syncthing.net/release-key.gpg -o /etc/apt/keyrings/syncthing.gpg
cat > /etc/apt/sources.list.d/syncthing.sources <<'EOF'
Types: deb
URIs: https://apt.syncthing.net/
Suites: syncthing
Components: stable-v2
Signed-By: /etc/apt/keyrings/syncthing.gpg
EOF
apt update && apt install -y syncthing
useradd -r -m -d /var/lib/syncthing -s /usr/sbin/nologin syncthing
mkdir -p /etc/systemd/system/syncthing@syncthing.service.d
printf '[Service]\nEnvironment=STGUIADDRESS=0.0.0.0:8384\n' > /etc/systemd/system/syncthing@syncthing.service.d/gfl.conf
systemctl daemon-reload && systemctl enable --now syncthing@syncthing
```

## Docker

```yaml
services:
  syncthing:
    image: syncthing/syncthing:latest
    container_name: syncthing
    hostname: syncthing
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
    ports:
      - "8384:8384"
      - "22000:22000/tcp"
      - "22000:22000/udp"
      - "21027:21027/udp"
    volumes:
      - ./data:/var/syncthing
```

## Using it

1. Open `http://<container-ip>:8384`. First go to **Actions > Settings > GUI** and set a user name and password.
2. Install Syncthing on your PC (or **Syncthing-Fork** on Android, **Möbius Sync** on iOS).
3. On the PC, **Add Remote Device** and paste the server's **Device ID** (under **Actions > Show ID**). Accept the request on the server.
4. On the PC, **Add Folder**, choose the folder, and on the **Sharing** tab tick the server. Accept it on the server and save it under `/data/sync/<name>`.
5. Files now stay in sync both ways, directly between your devices.

**Folder types**: "Send Only" on a phone keeps photos flowing to the server without deletions coming back. **File Versioning** (folder settings) keeps old copies when a file changes or is deleted.
