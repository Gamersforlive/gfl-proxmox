## Manual install

authentik's documented Docker Compose install. On Debian 13 with [Docker](#docker~manual-install):

```bash
mkdir -p /opt/authentik && cd /opt/authentik
curl -fsSL https://goauthentik.io/docker-compose.yml -o compose.yaml
echo "PG_PASS=$(openssl rand -base64 36 | tr -d '\n')" >> .env
echo "AUTHENTIK_SECRET_KEY=$(openssl rand -base64 60 | tr -d '\n')" >> .env
echo "COMPOSE_PORT_HTTP=9000" >> .env
echo "COMPOSE_PORT_HTTPS=9443" >> .env
docker compose pull && docker compose up -d
```

## Docker

The steps above are the Docker install. Upgrade by downloading the newest `docker-compose.yml` again and running `docker compose up -d` (the container's `update` command does exactly that).

## Using it

1. Open `http://<container-ip>:9000/if/flow/initial-setup/` (with the slash at the end) and set the password for the `akadmin` user.
2. Log in at `http://<container-ip>:9000`, open the **Admin interface**, and create your own user under **Directory > Users** (add it to the `authentik Admins` group).
3. Connect an app, for example Grafana or Nextcloud:
   - **Applications > Create with Provider**, choose **OAuth2/OpenID Provider**, give it the app's redirect URL.
   - Copy the Client ID, Client Secret and the OpenID configuration URL into the app's "OpenID Connect" settings.
4. For apps without logins of their own, use a **Proxy Provider** with an outpost: authentik puts its login page in front of the app.
5. Turn on two-factor login under **Flows and Stages**, or let users add it themselves in their settings.

Put authentik behind HTTPS (for example `https://auth.example.com`) before connecting apps; most apps require HTTPS for OpenID Connect.
