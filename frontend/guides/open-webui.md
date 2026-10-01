## Manual install

On Debian 13 with [Docker](#docker~manual-install), as root:

```bash
mkdir -p /opt/open-webui && cd /opt/open-webui
cat > compose.yaml <<'EOF'
services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - ./data:/app/backend/data
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. To connect to Ollama right away, add `OLLAMA_BASE_URL=http://<ollama-ip>:11434` under `environment:`.

## Using it

1. Open `http://<container-ip>:8080` and sign up. The first account becomes the admin.
2. **Admin Panel > Settings > Connections**: add Ollama at `http://<ollama-ip>:11434` and click the check mark.
3. Pick a model at the top of a new chat and start talking. Download more models under **Admin Panel > Settings > Models** by typing a name from ollama.com/library.
4. Upload a PDF or document into a chat to ask questions about it.

### More

- **Workspace > Knowledge**: build a collection of your own documents the models can search.
- **Admin Panel > Users**: approve family members who sign up, and set which models they may use.
- Open WebUI also connects to OpenAI-compatible APIs if you want to mix local and cloud models.
