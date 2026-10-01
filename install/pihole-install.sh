#!/usr/bin/env bash
# GFL Proxmox Scripts - Pi-hole installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Pi-hole stack"
mkdir -p /opt/pihole/etc-pihole
PASS=$(gen_pw)
printf 'PIHOLE_PASSWORD=%s\n' "$PASS" >/opt/pihole/.env
chmod 600 /opt/pihole/.env
cat >/opt/pihole/compose.yaml <<'YAML'
services:
  pihole:
    image: pihole/pihole:latest
    container_name: pihole
    restart: unless-stopped
    environment:
      - TZ=Etc/UTC
      - FTLCONF_webserver_api_password=${PIHOLE_PASSWORD}
      # Answer queries from your whole network, not only this subnet.
      - FTLCONF_dns_listeningMode=all
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "80:80/tcp"
    volumes:
      - ./etc-pihole:/etc/pihole
YAML
save_creds "Pi-hole" "password: ${PASS}"
msg_ok "Wrote /opt/pihole/compose.yaml (password in /root/pihole.creds)"
docker_app pihole

motd_ssh
customize
cleanup_lxc
