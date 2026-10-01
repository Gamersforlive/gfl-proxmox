## Doing it by hand

The same information with Proxmox's own commands:

```bash
pct list                                  # every container and whether it runs
pct config 105 | grep -E 'hostname|tags'  # name and tags (GFL containers carry "gfl")
pct exec 105 -- hostname -I               # its IP address
pct exec 105 -- cat /etc/gfl-app          # which app it runs and on which port
pct exec 105 -- apt list --upgradable     # pending updates
```

## Using it

Run it on the Proxmox host shell. You get a table like this:

```text
  ID     STATUS    NAME        APP          UPDATES  OPEN
  105    running   jellyfin    jellyfin     3        http://192.168.1.42:8096
  106    running   radarr      radarr       0        http://192.168.1.43:7878
  110    stopped   minecraft   -            -        -
```

- **OPEN** is the address of the app's web page; click it in most terminals.
- **UPDATES** counts OS packages waiting, from the container's last package refresh. Run [Update all GFL apps](#update-gfl-apps) to install them.
- Containers made before this tool existed still show up; the app name comes from their `update` command.

It only reads: nothing is started, stopped or changed.
