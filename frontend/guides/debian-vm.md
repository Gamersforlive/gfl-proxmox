## Manual install

The same steps by hand, on the Proxmox host shell:

```bash
VMID=210; STORAGE=local-lvm
cd /tmp && curl -fsSLO https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2
qm create $VMID -name debian -agent 1 -cores 2 -memory 2048 -net0 virtio,bridge=vmbr0 \
  -ostype l26 -scsihw virtio-scsi-single -serial0 socket -vga serial0 -onboot 1
qm set $VMID -scsi0 ${STORAGE}:0,import-from=/tmp/debian-13-genericcloud-amd64.qcow2,discard=on,ssd=1
qm set $VMID -ide2 ${STORAGE}:cloudinit -boot order=scsi0
qm set $VMID -ciuser gfl -cipassword 'choose-a-password' -ipconfig0 ip=dhcp -ciupgrade 1
qm set $VMID -sshkeys /root/.ssh/authorized_keys    # optional
qm resize $VMID scsi0 32G
qm start $VMID
```

For a static address use `-ipconfig0 ip=192.168.1.60/24,gw=192.168.1.1`.

### Make it a template

Instead of starting it, run `qm template $VMID`. Then **Clone** it (full clone) for every new VM in seconds, and change the user, password, SSH keys and IP per clone on its **Cloud-Init** tab.

## Using it

1. Open the VM's **Console** (xterm.js works best with the serial console) or SSH in: `ssh gfl@<vm-ip>`.
2. Install the guest agent so Proxmox shows the IP and can shut it down cleanly:

```bash
sudo apt update && sudo apt install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent
```

3. Install what you need. To run Docker apps, follow the [Docker guide](#docker~manual-install).

Change cloud-init settings later on the VM's **Cloud-Init** tab, then **Regenerate Image** and reboot.
