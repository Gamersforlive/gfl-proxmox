#!/usr/bin/env bash
# GFL Proxmox Scripts - WireGuard (wg-easy) installer. Runs inside the new container.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

install_docker

msg_info "Writing the wg-easy stack"
mkdir -p /opt/wg-easy
cat >/opt/wg-easy/compose.yaml <<'YAML'
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:15
    container_name: wg-easy
    restart: unless-stopped
    environment:
      - INSECURE=true
      - DISABLE_IPV6=true
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    volumes:
      - ./data:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
YAML
msg_ok "Wrote /opt/wg-easy/compose.yaml"
compose_up wg-easy

motd_ssh
customize
cleanup_lxc
