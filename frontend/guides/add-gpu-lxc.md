## Doing it by hand

On the Proxmox host (Proxmox VE 8.2 or newer):

```bash
ls -l /dev/dri                                   # card0/card1 and renderD128
pct set 105 -dev0 /dev/dri/renderD128,mode=0666 -dev1 /dev/dri/card0,mode=0666
pct reboot 105
pct exec 105 -- bash -c "apt install -y vainfo && vainfo"
```

The same is possible in the web interface: **the container > Resources > Add > Device Passthrough**.

## Using it

1. Run it on the Proxmox host and pick the container.
2. It adds every `/dev/dri` device of the host and restarts the container.
3. Check inside the container: `apt install -y vainfo && vainfo` lists the codecs the GPU can decode and encode.
4. Turn on hardware acceleration in the app, for example Jellyfin's **Dashboard > Playback > Transcoding > VAAPI**.

For NVIDIA cards, see [GPU passthrough](#gpu-passthrough): they need their driver installed on the host and in the container.
