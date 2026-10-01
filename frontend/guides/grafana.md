## Manual install

From Grafana's apt repository. On Debian 13, as root:

```bash
apt update && apt install -y curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list
apt update && apt install -y grafana
systemctl enable --now grafana-server
```

## Docker

```yaml
services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    user: "472"
    ports:
      - "3000:3000"
    volumes:
      - ./data:/var/lib/grafana
```

## Using it

1. Open `http://<container-ip>:3000`, log in as `admin` / `admin` and choose a new password.
2. **Connections > Data sources > Add**: pick where your numbers live, usually [Prometheus](#prometheus) (`http://<prometheus-ip>:9090`). Click **Save & test**.
3. **Dashboards > New > Import**: enter a dashboard ID from grafana.com and pick your data source. Good ones to start:
   - **1860** Node Exporter Full (CPU, memory, disk, network of a Linux machine)
   - **10347** Proxmox via Prometheus (with the PVE exporter)
4. Build your own: **New dashboard > Add visualization**, choose the data source and a query.

**Alerts**: open a panel, **More > New alert rule**, set a threshold and a contact point (Discord, email, Telegram).
