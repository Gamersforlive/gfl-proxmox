## Doing it by hand

```bash
uname -r                                                    # the kernel you're running: keep it
dpkg -l 'proxmox-kernel-*-pve-signed' | awk '/^ii/ {print $2}'
apt purge proxmox-kernel-6.8.12-1-pve-signed                 # an old one from the list
proxmox-boot-tool refresh
```

Never remove the running kernel or the newest one.

## Using it

1. Run it on the Proxmox host.
2. It shows the old kernels you can remove. The running kernel and the newest installed kernel are never in the list.
3. Tick the ones to remove and confirm. It cleans up and refreshes the boot loader.

Each kernel takes a few hundred MB, mostly in `/boot` and `/lib/modules`. Keep at least one older kernel until you're sure the newest one works on your hardware.
