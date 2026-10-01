## Doing it by hand

The packages live in Debian's `non-free-firmware` component, which Proxmox enables by default:

```bash
grep -m1 vendor_id /proc/cpuinfo   # GenuineIntel or AuthenticAMD
apt update
apt install -y intel-microcode     # Intel
apt install -y amd64-microcode     # AMD
reboot
```

## Using it

1. Run it on the Proxmox host. It detects Intel or AMD and installs the matching package.
2. Reboot the host to load the new microcode.
3. Check after the reboot: `journalctl -k | grep -i microcode` shows the loaded revision.

If it says the package isn't available, add `non-free-firmware` to the `Components:` line of `/etc/apt/sources.list.d/debian.sources` and run it again.
