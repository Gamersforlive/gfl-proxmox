## Manual install

LocalAI runs in Docker. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/localai/models && cd /opt/localai
cat > compose.yaml <<'EOF'
services:
  localai:
    image: localai/localai:latest
    container_name: localai
    restart: unless-stopped
    environment:
      - MODELS_PATH=/models
    ports:
      - "8080:8080"
    volumes:
      - ./models:/models
EOF
docker compose up -d
```

## Docker

The steps above are the Docker install. For an NVIDIA GPU, use a `latest-gpu-nvidia-cuda-12` image tag and give the container the GPU; the LocalAI docs list all image variants.

## Using it

1. Open `http://<container-ip>:8080`. The web UI shows a **Models** gallery.
2. Install a model from the gallery (a small chat model is a good start). It downloads into `/opt/localai/models`.
3. Chat in the web UI, or call the OpenAI-compatible API:

```bash
curl http://<container-ip>:8080/v1/chat/completions -H "Content-Type: application/json" \
  -d '{"model": "<model-name>", "messages": [{"role": "user", "content": "Hello!"}]}'
```

4. Point apps that support OpenAI at `http://<container-ip>:8080/v1` with any API key, and they use your local models: Open WebUI, n8n, Home Assistant and many more.

LocalAI also does image generation, speech-to-text and text-to-speech; install those models from the gallery the same way.
