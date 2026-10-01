#!/usr/bin/env bash
# GFL Proxmox Scripts - authentik installer. Runs inside the new container.
# Uses authentik's own docker-compose.yml, as its docs describe.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Downloading the authentik stack"
mkdir -p /opt/authentik
cd /opt/authentik || exit 1
fetch https://goauthentik.io/docker-compose.yml -o compose.yaml
cat >.env <<EOF
PG_PASS=$(gen_pw)$(gen_pw)
AUTHENTIK_SECRET_KEY=$(gen_pw)$(gen_pw)$(gen_pw)
AUTHENTIK_ERROR_REPORTING__ENABLED=false
COMPOSE_PORT_HTTP=9000
COMPOSE_PORT_HTTPS=9443
EOF
chmod 600 .env
msg_ok "Wrote /opt/authentik/compose.yaml and .env"
docker_app authentik

motd_ssh
customize
cleanup_lxc
