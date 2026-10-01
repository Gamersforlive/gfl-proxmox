#!/usr/bin/env bash
# GFL Proxmox Scripts - Nextcloud installer. Runs inside the new container.
# Nextcloud's official image with MariaDB and Redis; the admin account is created automatically.
# shellcheck source=/dev/null
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Writing the Nextcloud stack"
mkdir -p /opt/nextcloud
IP=$(hostname -I | awk '{print $1}')
ADMIN_PASS=$(gen_pw)
cat >/opt/nextcloud/.env <<EOF
MYSQL_ROOT_PASSWORD=$(gen_pw)
MYSQL_PASSWORD=$(gen_pw)
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=${ADMIN_PASS}
NEXTCLOUD_TRUSTED_DOMAINS=${IP} $(hostname) localhost
EOF
chmod 600 /opt/nextcloud/.env
cat >/opt/nextcloud/compose.yaml <<'YAML'
services:
  db:
    image: mariadb:11
    container_name: nextcloud-db
    restart: unless-stopped
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    environment:
      - MARIADB_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MARIADB_DATABASE=nextcloud
      - MARIADB_USER=nextcloud
      - MARIADB_PASSWORD=${MYSQL_PASSWORD}
    volumes:
      - ./db:/var/lib/mysql
  redis:
    image: redis:8-alpine
    container_name: nextcloud-redis
    restart: unless-stopped
  app:
    image: nextcloud:apache
    container_name: nextcloud
    restart: unless-stopped
    depends_on:
      - db
      - redis
    ports:
      - "8080:80"
    environment:
      - MYSQL_HOST=db
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - REDIS_HOST=redis
      - NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER}
      - NEXTCLOUD_ADMIN_PASSWORD=${NEXTCLOUD_ADMIN_PASSWORD}
      - NEXTCLOUD_TRUSTED_DOMAINS=${NEXTCLOUD_TRUSTED_DOMAINS}
    volumes:
      - ./html:/var/www/html
      - ./data:/var/www/html/data
  cron:
    image: nextcloud:apache
    container_name: nextcloud-cron
    restart: unless-stopped
    entrypoint: /cron.sh
    depends_on:
      - app
    volumes:
      - ./html:/var/www/html
      - ./data:/var/www/html/data
YAML
save_creds "Nextcloud" "user: admin" "password: ${ADMIN_PASS}"
msg_ok "Wrote /opt/nextcloud/compose.yaml (login in /root/nextcloud.creds)"
docker_app nextcloud

motd_ssh
customize
cleanup_lxc
