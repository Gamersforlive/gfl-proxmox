## Manual install

The same steps by hand, on the Proxmox host shell. Pick a free VM ID and a storage that holds VM disks (here `local-lvm`):

```bash
VMID=200; STORAGE=local-lvm
VER=$(curl -fsSL https://api.github.com/repos/home-assistant/operating-system/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
cd /tmp && curl -fsSLO "https://github.com/home-assistant/operating-system/releases/download/${VER}/haos_ova-${VER}.qcow2.xz"
unxz "haos_ova-${VER}.qcow2.xz"
qm create $VMID -name haos -machine q35 -bios ovmf -agent 1 -cores 2 -memory 4096 \
  -net0 virtio,bridge=vmbr0 -ostype l26 -scsihw virtio-scsi-pci -onboot 1 -tablet 0
qm set $VMID -efidisk0 ${STORAGE}:1,efitype=4m,pre-enrolled-keys=0
qm set $VMID -scsi0 ${STORAGE}:0,import-from=/tmp/haos_ova-${VER}.qcow2,discard=on,ssd=1
qm set $VMID -boot order=scsi0
qm resize $VMID scsi0 32G
qm start $VMID
rm /tmp/haos_ova-${VER}.qcow2
```

Secure Boot keys must not be pre-enrolled (`pre-enrolled-keys=0`), or Home Assistant OS won't boot.

## Docker

Home Assistant also runs as a container, without the add-on store (run those apps as separate containers instead):

```yaml
services:
  homeassistant:
    image: ghcr.io/home-assistant/home-assistant:stable
    container_name: homeassistant
    restart: unless-stopped
    network_mode: host
    privileged: true
    environment:
      - TZ=Europe/Amsterdam
    volumes:
      - ./config:/config
      - /run/dbus:/run/dbus:ro
```

## Using it

1. Wait a few minutes after the first boot, then open `http://homeassistant.local:8123` or `http://<vm-ip>:8123` (the VM's console in Proxmox shows the IP).
2. Create your account, set your home's location, and Home Assistant shows devices it found on your network.
3. **Settings > Devices & services > Add integration** for everything else: Hue, Sonos, Shelly, your TV, weather...
4. **Settings > Add-ons > Add-on store**: Mosquitto broker, Zigbee2MQTT, File editor, Studio Code Server, ESPHome.

### USB sticks (Zigbee, Z-Wave, Bluetooth)

Shut the VM down, then in Proxmox: **Hardware > Add > USB Device > Use USB Vendor/Device ID**, pick the stick, and start the VM again.

### Backups

Home Assistant makes its own backups (**Settings > System > Backups**); also include the VM in your Proxmox backup schedule.
