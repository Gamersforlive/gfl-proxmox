## Manual install

With Ollama's own installer, then opened up to your network. On Debian 13, as root:

```bash
apt update && apt install -y curl zstd pciutils
curl -fsSL https://ollama.com/install.sh | sh
mkdir -p /etc/systemd/system/ollama.service.d
printf '[Service]\nEnvironment="OLLAMA_HOST=0.0.0.0:11434"\n' > /etc/systemd/system/ollama.service.d/gfl.conf
systemctl daemon-reload && systemctl restart ollama
```

For an NVIDIA GPU, the container needs the NVIDIA devices and the same driver version as the host; see [GPU passthrough](#gpu-passthrough).

## Docker

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    volumes:
      - ./data:/root/.ollama
    # For an NVIDIA GPU (needs the NVIDIA Container Toolkit on the host):
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: all
    #           capabilities: [gpu]
```

## Using it

1. Download a model inside the container: `ollama pull llama3.2` (about 2 GB). Browse more at ollama.com/library.
2. Chat in the terminal: `ollama run llama3.2`. Type `/bye` to leave.
3. List and remove models with `ollama list` and `ollama rm <model>`.
4. For a chat page in the browser, install [Open WebUI](#open-webui) and point it at `http://<ollama-ip>:11434`.

### Picking a model size

As a rule of thumb, a model needs about its download size in RAM (or GPU memory), plus a bit:

- 1 to 4B parameters (llama3.2, phi): runs on CPU, 4 to 8 GB RAM
- 7 to 8B (llama3.1, qwen): 8 to 12 GB, much faster on a GPU
- 14B and up: wants a GPU with 16 GB or more

Other apps can use Ollama's API at `http://<ollama-ip>:11434`, for example n8n or Home Assistant's conversation agent.
