#!/usr/bin/env bash
# GFL Proxmox Scripts - Traefik installer. Runs inside the new container.
# Traefik reads routes from files in /opt/traefik/dynamic, so it works for apps in other containers.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Traefik stack"
mkdir -p /opt/traefik/dynamic /opt/traefik/letsencrypt
cat >/opt/traefik/compose.yaml <<'YAML'
services:
  traefik:
    image: traefik:v3
    container_name: traefik
    restart: unless-stopped
    command:
      - --api.dashboard=true
      - --api.insecure=true
      - --providers.file.directory=/etc/traefik/dynamic
      - --providers.file.watch=true
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.le.acme.httpchallenge=true
      - --certificatesresolvers.le.acme.httpchallenge.entrypoint=web
      - --certificatesresolvers.le.acme.storage=/letsencrypt/acme.json
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - ./dynamic:/etc/traefik/dynamic
      - ./letsencrypt:/letsencrypt
YAML
cat >/opt/traefik/dynamic/example.yml.disabled <<'YAML'
# Rename to example.yml and change the names and addresses. Traefik picks it up by itself.
http:
  routers:
    jellyfin:
      rule: Host(`jellyfin.example.com`)
      entryPoints: [websecure]
      service: jellyfin
      tls:
        certResolver: le
  services:
    jellyfin:
      loadBalancer:
        servers:
          - url: http://192.168.1.42:8096
YAML
msg_ok "Wrote /opt/traefik/compose.yaml"
docker_app traefik

motd_ssh
customize
cleanup_lxc
