# GFL Proxmox Scripts

**One command, one new app on your Proxmox.** Paste a command into the Proxmox shell, pick default
settings, and get a small unprivileged container with the app installed, running and updatable.

Website with every script and the full docs: **https://gamersforlive.github.io/gfl-proxmox**

Questions, problems or app requests: **[join the GamersForLive Discord](https://discord.gamersforlive.com)**

## Quick start

Open your Proxmox node's **Shell** and, on a new host, run the post-install setup first:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main/tools/post-pve-install.sh)"
```

Then install an app, for example Jellyfin:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main/ct/jellyfin.sh)"
```

Needs Proxmox VE 8.2 or newer (9.x included) on an amd64 host.

## What's included

| | |
|---|---|
| **Docker & containers** | Docker, Portainer, Dockge |
| **Media & downloads** | Jellyfin (GPU ready), Radarr, Sonarr, Prowlarr, qBittorrent, all sharing one `/data` layout |
| **Network & DNS** | AdGuard Home, Nginx Proxy Manager, Caddy, Cloudflared |
| **Security & VPN** | WireGuard (wg-easy), Vaultwarden |
| **Monitoring** | Uptime Kuma, Grafana |
| **AI** | Ollama (GPU ready), Open WebUI |
| **Gaming** | Minecraft (Paper, newest stable), Pterodactyl Wings |
| **Databases** | MariaDB, PostgreSQL |
| **Virtual machines** | Home Assistant OS, Debian 13 (cloud-init) |
| **Host tools** | Post-install setup, update all containers, clean old kernels, CPU microcode, add Tailscale to a container, add GPU to a container, host config backup |

Every container gets an `update` command that updates its app the right way.

## Repository layout

```
ct/        one host script per app: defaults + update steps
install/   one installer per app, runs inside the new container
vm/        scripts that create virtual machines
tools/     maintenance for the Proxmox host
misc/      shared libraries (core.func, build.func, install.func, tools.func)
frontend/  the website; the catalog is frontend/data/scripts.json
```

## Development

- Preview the website: `node frontend/dev-server.mjs` and open http://localhost:4173
- Check everything CI checks: `bash -n` on every script, ShellCheck, and `node .github/scripts/check-catalog.mjs`
- Test a script from a local clone on a Proxmox test host:
  `GFL_RAW=file:///root/gfl-proxmox bash /root/gfl-proxmox/ct/myapp.sh`
- Writing a new script: see [Write your own script](https://gamersforlive.github.io/gfl-proxmox/#contributing)

The website deploys to GitHub Pages from `frontend/` on every push to `main`
(Settings → Pages → Source: GitHub Actions).

## Community

Get help, share your setup and suggest new apps on the [GamersForLive Discord](https://discord.gamersforlive.com).
Bugs and pull requests are welcome on GitHub.

App logos in `frontend/icons/` come from [dashboard-icons](https://github.com/homarr-labs/dashboard-icons)
(Apache-2.0); each logo is a trademark of its project.

Inspired by the [community-scripts ProxmoxVE](https://github.com/community-scripts/ProxmoxVE) project.
Not affiliated with Proxmox Server Solutions GmbH. MIT licensed.
