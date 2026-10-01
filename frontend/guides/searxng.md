## Manual install

SearXNG's official image. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/searxng/config /opt/searxng/cache && cd /opt/searxng
cat > config/settings.yml <<EOF
use_default_settings: true
server:
  secret_key: "$(head -c 32 /dev/urandom | base64 | tr -dc A-Za-z0-9)"
  limiter: false
  image_proxy: true
search:
  formats:
    - html
    - json
EOF
cat > compose.yaml <<EOF
services:
  searxng:
    image: searxng/searxng:latest
    container_name: searxng
    restart: unless-stopped
    environment:
      - SEARXNG_BASE_URL=http://$(hostname -I | awk '{print $1}'):8080/
    ports:
      - "8080:8080"
    volumes:
      - ./config:/etc/searxng
      - ./cache:/var/cache/searxng
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. Set `limiter: true` (and add Valkey/Redis) if you open it to the internet, to keep bots out.

## Using it

1. Open `http://<container-ip>:8080` and search. Results come from many engines at once, without ads or tracking.
2. Make it your browser's default search engine. In Firefox and Chrome, visit the page, then add it under **Settings > Search engine**, or add a custom engine with `http://<container-ip>:8080/search?q=%s`.
3. **Preferences** (top right): choose which engines and categories to use, your language and the theme. Settings are stored in your browser.
4. For AI tools: [Open WebUI](#open-webui) can use it for web search under **Admin Panel > Settings > Web Search** (engine SearXNG, URL `http://<container-ip>:8080/search?q=<query>`); JSON output is already on.
