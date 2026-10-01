## Manual install

From the official binary, following Gitea's docs. On Debian 13, as root:

```bash
apt update && apt install -y curl git git-lfs
VER=$(curl -fsSL https://api.github.com/repos/go-gitea/gitea/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
curl -fsSL "https://dl.gitea.com/gitea/${VER}/gitea-${VER}-linux-amd64" -o /usr/local/bin/gitea
chmod 755 /usr/local/bin/gitea
adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
mkdir -p /var/lib/gitea/{custom,data,log} /etc/gitea
chown -R git:git /var/lib/gitea && chmod -R 750 /var/lib/gitea
chown root:git /etc/gitea && chmod 770 /etc/gitea
cat > /etc/systemd/system/gitea.service <<'EOF'
[Unit]
Description=Gitea
After=network.target

[Service]
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now gitea
```

## Docker

```yaml
services:
  gitea:
    image: docker.gitea.com/gitea:latest
    container_name: gitea
    restart: unless-stopped
    environment:
      - USER_UID=1000
      - USER_GID=1000
    ports:
      - "3000:3000"
      - "2222:22"
    volumes:
      - ./data:/data
```

## Using it

1. Open `http://<container-ip>:3000` to see the installer.
2. Database: **SQLite3** is fine for a home or small team server.
3. Set **Server Domain** and **Gitea Base URL** to the address people will use (for example `http://192.168.1.60:3000/`).
4. At the bottom, open **Administrator Account Settings** and create your admin. Click **Install Gitea**.
5. Create a repository with **+ > New Repository**, then push to it:

```bash
git remote add origin http://192.168.1.60:3000/you/project.git
git push -u origin main
```

### More

- Add your SSH key under **Settings > SSH / GPG Keys** to push over SSH.
- **+ > New Migration** copies repositories (with issues and releases) from GitHub or GitLab.
- **Gitea Actions** runs GitHub-Actions-style workflows once you register a runner (`act_runner`).
