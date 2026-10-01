## Manual install

With code-server's install script. On Debian 13, as root:

```bash
apt update && apt install -y curl git build-essential
curl -fsSL https://code-server.dev/install.sh | sh -s -- --method standalone --prefix /usr/local
useradd -m -s /bin/bash coder
mkdir -p /home/coder/.config/code-server /home/coder/projects
cat > /home/coder/.config/code-server/config.yaml <<'EOF'
bind-addr: 0.0.0.0:8080
auth: password
password: choose-a-password
cert: false
EOF
chown -R coder:coder /home/coder
runuser -u coder -- /usr/local/bin/code-server /home/coder/projects
```

The script also creates a `code-server` service so it starts with the container.

## Docker

```yaml
services:
  code-server:
    image: lscr.io/linuxserver/code-server:latest
    container_name: code-server
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - PASSWORD=choose-a-password
      - DEFAULT_WORKSPACE=/config/workspace
    ports:
      - "8443:8443"
    volumes:
      - ./config:/config
```

## Using it

1. Open `http://<container-ip>:8080` and log in with the password from `/root/code-server.creds`.
2. It's Visual Studio Code: open folders under `/home/coder/projects`, use the built-in terminal (**Ctrl+`**), and clone repositories with **Git: Clone**.
3. Install extensions from the Extensions panel (it uses the Open VSX registry; most popular extensions are there).
4. Install languages and tools in the terminal as root (`pct enter <ID>` on the host), for example `apt install -y python3-venv nodejs`.

Some features (clipboard, webviews, the service worker) need HTTPS. For daily use put it behind a reverse proxy with a certificate, or reach it over [Tailscale](#add-tailscale-lxc).
