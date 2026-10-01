## Manual install

On Debian 13 with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/n8n/data && chown -R 1000:1000 /opt/n8n/data && cd /opt/n8n
cat > compose.yaml <<'EOF'
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    environment:
      - GENERIC_TIMEZONE=Europe/Amsterdam
      - TZ=Europe/Amsterdam
      - N8N_SECURE_COOKIE=false
    ports:
      - "5678:5678"
    volumes:
      - ./data:/home/node/.n8n
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. `N8N_SECURE_COOKIE=false` allows logging in over plain http on your LAN; remove it once n8n is behind HTTPS and set `WEBHOOK_URL=https://n8n.example.com/` so webhooks get the right address.

## Using it

1. Open `http://<container-ip>:5678` and create the owner account.
2. **Create workflow**. Every workflow starts with a trigger: a schedule, a webhook, a new email, a Discord message and many more.
3. Add nodes after it with **+**: HTTP requests, Discord, Telegram, Google Sheets, databases, AI models, code.
4. Click **Test workflow** to run it once and see each node's data, then switch it to **Active**.

### Ideas to start with

- Post to Discord when a Minecraft server goes down (with an Uptime Kuma webhook as trigger).
- A daily message with your Proxmox backups' status.
- Save email attachments to Paperless-ngx's consume folder.
- Connect [Ollama](#ollama) to summarise RSS feeds or answer questions.
