## Manual install

From Debian's packages, with the node exporter. On Debian 13, as root:

```bash
apt update && apt install -y prometheus prometheus-node-exporter
systemctl enable --now prometheus prometheus-node-exporter
```

## Docker

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./data:/prometheus
```

## Using it

Prometheus collects numbers ("metrics") from your machines every few seconds and keeps the history. You look at them in [Grafana](#grafana).

1. Open `http://<container-ip>:9090`. **Status > Targets** shows what it collects; out of the box that's itself and the node exporter.
2. Install the node exporter on other machines (`apt install prometheus-node-exporter`) and add them to `/etc/prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: node
    static_configs:
      - targets: ["localhost:9100", "192.168.1.10:9100", "192.168.1.11:9100"]
```

3. Reload: `systemctl reload prometheus`. The new targets turn green under **Status > Targets**.
4. Try a query in the **Graph** tab, for example `node_load1` or `100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` for CPU use.
5. Add Prometheus as a data source in Grafana and import dashboard 1860.

For Proxmox itself, add the `prometheus-pve-exporter` and scrape it, or point Proxmox's built-in metric server at InfluxDB.
