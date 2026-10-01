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
| **Bundles** | Media bundle: qBittorrent, Prowlarr, FlareSolverr, Radarr, Sonarr, Jellyfin and Seerr, created and connected to each other automatically |
| **Docker & containers** | Docker, Portainer, Dockge, Homepage |
| **Media & downloads** | Jellyfin, Plex, Radarr, Sonarr, Lidarr, Prowlarr, Bazarr, qBittorrent, SABnzbd, Seerr, FlareSolverr, Navidrome, Audiobookshelf, Immich, Kavita, Komga, Calibre-Web, Tdarr, Jellystat, Tautulli |
| **Network & DNS** | AdGuard Home, Pi-hole, Nginx Proxy Manager, Caddy, Traefik, Cloudflared |
| **Security & VPN** | WireGuard (wg-easy), Vaultwarden, authentik |
| **Files & automation** | Nextcloud, Syncthing, Paperless-ngx, n8n, Proxmox Backup Server |
| **Monitoring** | Uptime Kuma, Grafana, Prometheus |
| **Smart home** | Home Assistant, Zigbee2MQTT, Mosquitto, Node-RED, Frigate |
| **AI** | Ollama (with model presets), Open WebUI, LocalAI, SearXNG |
| **Developer tools** | Gitea, Forgejo, code-server, Jenkins |
| **Gaming** | Minecraft (Paper, Fabric, NeoForge, Bedrock), Crafty Controller, Pterodactyl Wings, Valheim, Palworld, Satisfactory, Project Zomboid, Counter-Strike 2, Rust, Terraria, Factorio |
| **Databases** | MariaDB, PostgreSQL, Redis |
| **Virtual machines** | Home Assistant OS, Debian 13 (cloud-init) |
| **Host tools** | Post-install setup, GFL status, update all GFL apps, update all containers, mount a NAS share, clean old kernels, CPU microcode, add Tailscale or a GPU to a container, host config backup |

Every container gets an `update` command that updates its app the right way. Every app page on the
website has a guide: install with the script, install by hand, install with Docker, and how to use it.

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
Not affiliated with Proxmox Server Solutions GmbH.

## License

© GamersForLive. All rights reserved: see [LICENSE](LICENSE). In short, you may **run** these scripts
(home or business) and read or change them for your own use, and you're welcome to send improvements.
You may **not** republish, mirror, rebrand or sell the scripts or the website without written permission.
Ask on the [Discord](https://discord.gamersforlive.com).
