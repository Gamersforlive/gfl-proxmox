## Manual install

FlareSolverr ships as a Docker image (it bundles a headless Chromium). On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/flaresolverr
cat > /opt/flaresolverr/compose.yaml <<'EOF'
services:
  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    restart: unless-stopped
    environment:
      - LOG_LEVEL=info
    ports:
      - "8191:8191"
EOF
cd /opt/flaresolverr && docker compose up -d
```

## Docker

Use the `compose.yaml` above. Check it works: `curl http://<ip>:8191` returns a short JSON message saying FlareSolverr is ready.

## Using it

FlareSolverr has no page of its own; Prowlarr uses it in the background.

1. In Prowlarr open **Settings > Indexers > + > FlareSolverr**.
2. Host: `http://<flaresolverr-ip>:8191/`. Add a tag, for example `flaresolverr`. Save.
3. Edit each indexer that shows Cloudflare errors and give it the same tag.

Only tag the indexers that need it: every request through FlareSolverr starts a browser, which is slower and uses memory.
