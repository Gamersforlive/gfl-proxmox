## Manual install

Traefik's official image with file-based routes. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/traefik/dynamic /opt/traefik/letsencrypt && cd /opt/traefik
cat > compose.yaml <<'EOF'
services:
  traefik:
    image: traefik:v3
    container_name: traefik
    restart: unless-stopped
    command:
      - --api.dashboard=true
      - --api.insecure=true
      - --providers.file.directory=/etc/traefik/dynamic
      - --providers.file.watch=true
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.le.acme.httpchallenge=true
      - --certificatesresolvers.le.acme.httpchallenge.entrypoint=web
      - --certificatesresolvers.le.acme.storage=/letsencrypt/acme.json
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - ./dynamic:/etc/traefik/dynamic
      - ./letsencrypt:/letsencrypt
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. When your apps run in Docker on the same machine, add the Docker provider (`--providers.docker=true` and the Docker socket) and route with labels instead.

## Using it

1. Point your domain names at your home IP and forward ports **80** and **443** to this container.
2. Create a file in `/opt/traefik/dynamic`, for example `apps.yml`:

```yaml
http:
  routers:
    jellyfin:
      rule: Host(`jellyfin.example.com`)
      entryPoints: [websecure]
      service: jellyfin
      tls:
        certResolver: le
    redirect-http:
      rule: HostRegexp(`.+`)
      entryPoints: [web]
      middlewares: [to-https]
      service: noop@internal
  middlewares:
    to-https:
      redirectScheme:
        scheme: https
  services:
    jellyfin:
      loadBalancer:
        servers:
          - url: http://192.168.1.42:8096
```

3. Save: Traefik reloads by itself and fetches a certificate within a minute.
4. Watch routers and errors on the dashboard: `http://<container-ip>:8080/dashboard/`.

The dashboard has no login. Keep port 8080 inside your network, or protect it with a router rule and a `basicAuth` middleware.
