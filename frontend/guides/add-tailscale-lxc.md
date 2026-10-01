## Doing it by hand

On the Proxmox host, give the container the TUN device, then install Tailscale inside it:

```bash
pct set 105 -dev0 /dev/net/tun,mode=0666
pct reboot 105
pct exec 105 -- bash -c "curl -fsSL https://tailscale.com/install.sh | sh"
pct exec 105 -- tailscale up
```

Use the next free `devN` if the container already has devices (`pct config 105 | grep ^dev`).

## Using it

1. Run it on the Proxmox host and pick a Debian or Ubuntu container.
2. It adds `/dev/net/tun`, restarts the container and installs Tailscale.
3. Sign in: run `pct exec <ID> -- tailscale up` and open the link it prints.
4. The container appears in your Tailscale admin console and is reachable from all your Tailscale devices by its Tailscale IP or name.

### Handy options

- `tailscale up --advertise-routes=192.168.1.0/24` turns it into a subnet router: your whole home network becomes reachable over Tailscale (approve the route in the admin console).
- `tailscale up --advertise-exit-node` lets your phone send all traffic through home.
- `tailscale serve 8096` publishes a local port on your tailnet with HTTPS.
