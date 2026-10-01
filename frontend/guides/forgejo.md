## Manual install

From the official binary on Codeberg. On Debian 13, as root:

```bash
apt update && apt install -y curl jq git git-lfs
VER=$(curl -fsSL https://codeberg.org/api/v1/repos/forgejo/forgejo/releases/latest | jq -r .tag_name)
curl -fsSL "https://codeberg.org/forgejo/forgejo/releases/download/${VER}/forgejo-${VER#v}-linux-amd64" -o /usr/local/bin/forgejo
chmod 755 /usr/local/bin/forgejo
adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
mkdir -p /var/lib/forgejo/{custom,data,log} /etc/forgejo
chown -R git:git /var/lib/forgejo && chmod -R 750 /var/lib/forgejo
chown root:git /etc/forgejo && chmod 770 /etc/forgejo
```

Then create `/etc/systemd/system/forgejo.service` (the same as the Gitea one, with `forgejo` in place of `gitea`) and run `systemctl enable --now forgejo`.

## Docker

```yaml
services:
  forgejo:
    image: codeberg.org/forgejo/forgejo:16
    container_name: forgejo
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

1. Open `http://<container-ip>:3000` for the installer.
2. Choose **SQLite3**, set **Server Domain** and **Base URL** to the address you'll use, and create the admin account at the bottom. Click **Install Forgejo**.
3. Create repositories, organisations and teams. Push with `git remote add origin http://<ip>:3000/you/project.git` and `git push -u origin main`.
4. **New migration** imports repositories (with issues, pull requests and releases) from GitHub, GitLab or Gitea.
5. **Forgejo Actions**: enable them per repository and register a runner (`forgejo-runner`) to run GitHub-Actions-style workflows.

Forgejo started as a fork of Gitea and stays compatible with Gitea's API and most tools.
