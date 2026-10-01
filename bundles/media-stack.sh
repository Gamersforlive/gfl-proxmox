#!/usr/bin/env bash
# GFL Proxmox Scripts · (c) GamersForLive · see LICENSE · https://github.com/gamersforlive/gfl-proxmox
# Media bundle: creates a complete movies & TV setup and connects every app to the others.
#
#   qBittorrent  <- download client for Radarr / Sonarr / Lidarr
#   Prowlarr     -> pushes indexers to Radarr / Sonarr / Lidarr (+ FlareSolverr proxy)
#   Radarr/Sonarr/Lidarr -> library folders on one shared /data folder (instant hardlinks)
#   Jellyfin     <- setup wizard done, Movies / Shows / Music libraries added
#   Seerr        <- signed in with Jellyfin, libraries synced, Radarr + Sonarr connected
#
# Every app runs in its own container and shares one login. Running the bundle again reuses
# the containers it finds (by hostname) and only adds what is missing.
#
# Unattended: APPS="qbittorrent prowlarr ..." DATA=/mnt/gfl/media APP_USER=admin APP_PASS=... GFL_MODE=default

# shellcheck source=/dev/null
source <(curl -fsSL "${GFL_RAW:-https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/main}/misc/tools.func")
color
catch_errors
require_pve
tool_header "Media bundle"

CORE="qbittorrent prowlarr flaresolverr radarr sonarr jellyfin seerr"
APPS="${APPS:-}"
DATA="${DATA:-}"
APP_USER="${APP_USER:-}"
APP_PASS="${APP_PASS:-}"

ask_box() { # ask_box VAR "Title" "Question" "default"
  local answer
  answer=$(whiptail --backtitle "$BACKTITLE" --title "$2" --inputbox "$3" 12 74 "$4" 3>&1 1>&2 2>&3) || cancelled
  printf -v "$1" '%s' "$answer"
}

# ---- 1. what to install -------------------------------------------------------------
if [ -z "$APPS" ]; then
  APPS=$(whiptail --backtitle "$BACKTITLE" --title "Media bundle" --checklist \
    "Pick the apps (space toggles). Each runs in its own container and they all get connected." 20 76 9 \
    "qbittorrent" "Downloads torrents" ON \
    "prowlarr" "Manages indexers for everything else" ON \
    "flaresolverr" "Gets past Cloudflare checks for Prowlarr" ON \
    "radarr" "Movies" ON \
    "sonarr" "TV shows" ON \
    "jellyfin" "Plays your library on every device" ON \
    "seerr" "Lets you (and friends) request titles" ON \
    "lidarr" "Music" OFF 3>&1 1>&2 2>&3) || cancelled
  APPS=$(echo "$APPS" | tr -d '"')
fi
for a in $APPS; do
  case " $CORE lidarr " in *" $a "*) ;; *) msg_error "Unknown app '${a}' in APPS"; exit 1 ;; esac
done
if [ -z "$APPS" ]; then cancelled; fi

# ---- 2. where the media lives ---------------------------------------------------------
if [ -z "$DATA" ]; then
  ask_box DATA "Media folder" "Folder on this host for downloads AND the library. Every app gets it at /data.\n\nUse a big disk. For a NAS, first run 'Mount a NAS share into containers' and enter /mnt/gfl/<name> here." "/mnt/gfl/media-data"
fi
if ! [[ "$DATA" =~ ^/[A-Za-z0-9._/-]+$ ]]; then
  msg_error "The media folder must be an absolute path like /mnt/gfl/media-data"
  exit 1
fi

# ---- 3. one login for everything ---------------------------------------------------
if [ -z "$APP_USER" ]; then
  ask_box APP_USER "Login" "User name for qBittorrent, Radarr, Sonarr, Prowlarr, Jellyfin and Seerr" "admin"
fi
if ! [[ "$APP_USER" =~ ^[A-Za-z0-9._-]{2,32}$ ]]; then
  msg_error "The user name may only use letters, numbers, dots, dashes and underscores"
  exit 1
fi
while [ -z "$APP_PASS" ]; do
  p1=$(whiptail --backtitle "$BACKTITLE" --title "Login" --passwordbox "Password for ${APP_USER} (at least 8 characters)" 9 74 3>&1 1>&2 2>&3) || cancelled
  p2=$(whiptail --backtitle "$BACKTITLE" --title "Login" --passwordbox "Type it again" 9 74 3>&1 1>&2 2>&3) || cancelled
  if [ "$p1" != "$p2" ]; then
    whiptail --backtitle "$BACKTITLE" --title "Login" --msgbox "The passwords did not match. Try again." 8 60
  elif [ "${#p1}" -lt 8 ]; then
    whiptail --backtitle "$BACKTITLE" --title "Login" --msgbox "Use at least 8 characters." 8 60
  else
    APP_PASS="$p1"
  fi
done
unset p1 p2

pick_storage GFL_STORAGE rootdir
pick_storage GFL_TEMPLATE_STORAGE vztmpl
export GFL_STORAGE GFL_TEMPLATE_STORAGE

if [ "${GFL_MODE:-}" != "default" ]; then
  confirm "Media bundle" "Create these containers and connect them?\n\n  ${APPS}\n\nMedia folder: ${DATA} (shared as /data)\nLogin: ${APP_USER}\n\nThis takes 10 to 20 minutes." || cancelled
fi

if ! command -v jq >/dev/null 2>&1; then
  msg_info "Installing jq (used to talk to the apps' APIs)"
  $STD apt-get install -y jq
  msg_ok "Installed jq"
fi

# ---- 4. shared folder ---------------------------------------------------------------------
msg_info "Preparing ${DATA}"
mkdir -p "$DATA"/downloads/{complete,incomplete} "$DATA"/media/{movies,tv,music}
# 101000 is uid/gid 1000 ("media") inside unprivileged containers; privileged containers use
# 1000 itself (DATA_OWNER=1000). On a NAS share the mount options decide, so chown may fail.
DATA_OWNER="${DATA_OWNER:-101000}"
chown "${DATA_OWNER}:${DATA_OWNER}" "$DATA" "$DATA"/downloads "$DATA"/downloads/* "$DATA"/media "$DATA"/media/* 2>/dev/null || true
chmod 2775 "$DATA" "$DATA"/downloads "$DATA"/downloads/* "$DATA"/media "$DATA"/media/* 2>/dev/null || true
msg_ok "Prepared ${DATA} (downloads/ and media/movies, tv, music)"

# ---- 5. containers ------------------------------------------------------------------------
declare -A CT IP
# No early "exit" in awk: closing the pipe early would kill pct with SIGPIPE.
existing_ct() { pct list | awk -v n="$1" 'NR>1 && $NF==n && !found {print $1; found=1}'; }
ct_ip() { pct exec "$1" -- hostname -I 2>/dev/null | awk '{print $1}'; }

for app in $APPS; do
  id=$(existing_ct "$app")
  if [ -n "$id" ]; then
    msg_ok "Using the existing ${app} container ${id}"
    if ! pct config "$id" | grep -qE "^mp[0-9]+:.*mp=/data(,|$)"; then
      msg_warn "Container ${id} has no /data folder. Add ${DATA} to it with the 'Mount a NAS share' tool or: pct set ${id} -mp0 ${DATA},mp=/data"
    fi
  else
    id=$(pvesh get /cluster/nextid)
    msg_info "Creating ${app} in container ${id} (a few minutes)"
    if ! CT_ID="$id" HN="$app" MP_HOST="$DATA" MP_PATH=/data GFL_MODE=default VERBOSE=no \
      GFL_APP_USER="$APP_USER" GFL_APP_PASS="$APP_PASS" \
      bash -c "$(curl -fsSL "${GFL_RAW}/ct/${app}.sh")" >>"$GFL_LOG" 2>&1 </dev/null; then
      msg_error "Creating ${app} failed. The end of ${GFL_LOG}:"
      tail -n 25 "$GFL_LOG" | sed 's/\x1b\[[0-9;]*[mK]//g; s/^/     /'
      exit 1
    fi
    msg_ok "Created ${app} in container ${id}"
  fi
  CT[$app]="$id"
  IP[$app]=$(ct_ip "$id")
done

# ---- 6. wiring -----------------------------------------------------------------------------
PROBLEMS=()
problem() { msg_warn "$1"; PROBLEMS+=("$1"); }

# call METHOD URL [JSON] -- uses the headers in the H array. Prints the response body;
# on an HTTP error it logs the app's reply (it says what was wrong) and fails.
H=()
call() {
  local -a args=(-sS -m 30 -X "$1" -H "Content-Type: application/json" -w '\n%{http_code}' "${H[@]}")
  if [ -n "${3:-}" ]; then args+=(--data "$3"); fi
  local out code
  out=$(curl "${args[@]}" "$2" 2>>"$GFL_LOG") || { echo "curl failed: $1 $2" >>"$GFL_LOG"; return 1; }
  code="${out##*$'\n'}"
  out="${out%$'\n'*}"
  if [[ "$code" == 2* ]]; then
    printf '%s' "$out"
  else
    echo "HTTP ${code} from $1 $2: ${out:0:500}" >>"$GFL_LOG"
    return 1
  fi
}
wait_for() { # wait_for URL [tries]
  local i
  for i in $(seq 1 "${2:-120}"); do
    if curl -fsS -m 5 -o /dev/null "${H[@]}" "$1" 2>/dev/null; then return 0; fi
    sleep 2
  done
  return 1
}
port_of() {
  case "$1" in
    radarr) echo 7878 ;; sonarr) echo 8989 ;; lidarr) echo 8686 ;; prowlarr) echo 9696 ;;
  esac
}
api_ver() { case "$1" in prowlarr | lidarr) echo v1 ;; *) echo v3 ;; esac; }
has_app() { [ -n "${CT[$1]:-}" ]; }
field() { jq -nc --arg n "$1" --argjson v "$2" '{name:$n, value:$v}'; }

declare -A KEY
ARRS=""
for app in radarr sonarr lidarr prowlarr; do
  has_app "$app" || continue
  msg_info "Waiting for ${app} to start"
  for i in $(seq 1 90); do
    KEY[$app]=$(pct exec "${CT[$app]}" -- sed -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' "/var/lib/${app}/config.xml" 2>/dev/null || true)
    if [ -n "${KEY[$app]}" ]; then break; fi
    sleep 2
  done
  base="http://${IP[$app]}:$(port_of "$app")/api/$(api_ver "$app")"
  H=(-H "X-Api-Key: ${KEY[$app]:-none}")
  if [ -z "${KEY[$app]}" ] || ! wait_for "${base}/system/status"; then
    problem "${app} did not start in time"
    continue
  fi
  ARRS+=" $app"
  # One login for every *arr: forms login, always required.
  if host=$(call GET "${base}/config/host") &&
    body=$(echo "$host" | jq -c --arg u "$APP_USER" --arg p "$APP_PASS" \
      '.authenticationMethod="forms" | .authenticationRequired="enabled" | .username=$u | .password=$p | .passwordConfirmation=$p') &&
    call PUT "${base}/config/host/$(echo "$host" | jq -r .id)" "$body" >/dev/null; then
    msg_ok "${app} uses your login"
  else
    problem "Could not set the ${app} login"
  fi
done

for app in radarr sonarr lidarr; do
  case " $ARRS " in *" $app "*) ;; *) continue ;; esac
  base="http://${IP[$app]}:$(port_of "$app")/api/$(api_ver "$app")"
  H=(-H "X-Api-Key: ${KEY[$app]}")
  case "$app" in
    radarr) root=/data/media/movies cat_field=movieCategory ;;
    sonarr) root=/data/media/tv cat_field=tvCategory ;;
    lidarr) root=/data/media/music cat_field=musicCategory ;;
  esac

  # Library folder
  if call GET "${base}/rootfolder" | jq -e --arg p "$root" 'any(.[]; .path==$p or .path==($p+"/"))' >/dev/null; then
    msg_ok "${app} already saves to ${root}"
  else
    body=$(jq -nc --arg p "$root" '{path:$p}')
    if [ "$app" = "lidarr" ]; then
      qp=$(call GET "${base}/qualityprofile" | jq '.[0].id')
      mp=$(call GET "${base}/metadataprofile" | jq '.[0].id')
      body=$(jq -nc --arg p "$root" --argjson q "$qp" --argjson m "$mp" \
        '{name:"Music", path:$p, defaultQualityProfileId:$q, defaultMetadataProfileId:$m, defaultMonitorOption:"all", defaultNewItemMonitorOption:"all", defaultTags:[]}')
    fi
    # Right after the first start the *arr can still reject folders; give it a few tries.
    added=0
    for i in 1 2 3 4 5 6; do
      if call POST "${base}/rootfolder" "$body" >/dev/null; then added=1; break; fi
      sleep 10
    done
    if [ "$added" = 1 ]; then msg_ok "${app} saves to ${root}"; else problem "Could not add the ${app} library folder"; fi
  fi

  # qBittorrent as download client
  if has_app qbittorrent; then
    if call GET "${base}/downloadclient" | jq -e 'any(.[]; .name=="qBittorrent")' >/dev/null; then
      msg_ok "${app} already uses qBittorrent"
    else
      fields=$(jq -nc --argjson a "$(field host "\"${IP[qbittorrent]}\"")" --argjson b "$(field port 8090)" \
        --argjson c "$(field useSsl false)" --argjson d "$(field username "$(jq -nc --arg v "$APP_USER" '$v')")" \
        --argjson e "$(field password "$(jq -nc --arg v "$APP_PASS" '$v')")" --argjson f "$(field "$cat_field" "\"${app}\"")" \
        '[$a,$b,$c,$d,$e,$f]')
      body=$(jq -nc --argjson f "$fields" '{enable:true, protocol:"torrent", priority:1, name:"qBittorrent",
        implementation:"QBittorrent", configContract:"QBittorrentSettings", removeCompletedDownloads:true,
        removeFailedDownloads:true, tags:[], fields:$f}')
      if call POST "${base}/downloadclient?forceSave=true" "$body" >/dev/null; then msg_ok "${app} -> qBittorrent connected"; else problem "Could not connect ${app} to qBittorrent"; fi
    fi
  fi

  # Rename files to clean names
  if [ "$app" != "lidarr" ]; then
    key=renameMovies
    if [ "$app" = "sonarr" ]; then key=renameEpisodes; fi
    if n=$(call GET "${base}/config/naming"); then
      call PUT "${base}/config/naming/$(echo "$n" | jq -r .id)" "$(echo "$n" | jq -c --arg k "$key" '.[$k]=true')" >/dev/null || true
    fi
  fi
done

case " $ARRS " in *" prowlarr "*)
  base="http://${IP[prowlarr]}:9696/api/v1"
  H=(-H "X-Api-Key: ${KEY[prowlarr]}")
  if has_app flaresolverr; then
    if call GET "${base}/indexerProxy" | jq -e 'any(.[]; .name=="FlareSolverr")' >/dev/null; then
      msg_ok "Prowlarr already uses FlareSolverr"
    else
      tag=$(call GET "${base}/tag" | jq '[.[] | select(.label=="flaresolverr")][0].id // empty')
      if [ -z "$tag" ]; then tag=$(call POST "${base}/tag" '{"label":"flaresolverr"}' | jq .id); fi
      fields=$(jq -nc --argjson a "$(field host "\"http://${IP[flaresolverr]}:8191/\"")" --argjson b "$(field requestTimeout 60)" '[$a,$b]')
      body=$(jq -nc --argjson f "$fields" --argjson t "$tag" '{name:"FlareSolverr", implementation:"FlareSolverr", configContract:"FlareSolverrSettings", tags:[$t], fields:$f}')
      if call POST "${base}/indexerProxy?forceSave=true" "$body" >/dev/null; then
        msg_ok "Prowlarr -> FlareSolverr connected (tag indexers with \"flaresolverr\" when they need it)"
      else
        problem "Could not connect Prowlarr to FlareSolverr"
      fi
    fi
  fi
  for app in radarr sonarr lidarr; do
    case " $ARRS " in *" $app "*) ;; *) continue ;; esac
    name="${app^}"
    if call GET "${base}/applications" | jq -e --arg n "$name" 'any(.[]; .name==$n)' >/dev/null; then
      msg_ok "Prowlarr already syncs to ${name}"
      continue
    fi
    fields=$(jq -nc --argjson a "$(field prowlarrUrl "\"http://${IP[prowlarr]}:9696\"")" \
      --argjson b "$(field baseUrl "\"http://${IP[$app]}:$(port_of "$app")\"")" \
      --argjson c "$(field apiKey "\"${KEY[$app]}\"")" '[$a,$b,$c]')
    body=$(jq -nc --arg n "$name" --argjson f "$fields" '{name:$n, syncLevel:"fullSync", implementation:$n, configContract:($n+"Settings"), tags:[], fields:$f}')
    if call POST "${base}/applications?forceSave=true" "$body" >/dev/null; then
      msg_ok "Prowlarr -> ${name}: indexers you add in Prowlarr appear there automatically"
    else
      problem "Could not connect Prowlarr to ${name}"
    fi
  done
  ;;
esac

if has_app jellyfin; then
  jf="http://${IP[jellyfin]}:8096"
  auth='MediaBrowser Client="GFL Proxmox Scripts", Device="Proxmox", DeviceId="gfl-proxmox", Version="1.0.0"'
  H=(-H "Authorization: ${auth}")
  msg_info "Waiting for Jellyfin"
  if ! wait_for "${jf}/System/Info/Public"; then
    problem "Jellyfin did not start in time"
  else
    msg_ok "Jellyfin is up"
    if [ "$(call GET "${jf}/System/Info/Public" | jq -r .StartupWizardCompleted)" != "true" ]; then
      ok=1
      call POST "${jf}/Startup/Configuration" '{"UICulture":"en-US","MetadataCountryCode":"US","PreferredMetadataLanguage":"en"}' >/dev/null || ok=0
      call GET "${jf}/Startup/User" >/dev/null || ok=0
      call POST "${jf}/Startup/User" "$(jq -nc --arg u "$APP_USER" --arg p "$APP_PASS" '{Name:$u, Password:$p}')" >/dev/null || ok=0
      call POST "${jf}/Startup/RemoteAccess" '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}' >/dev/null || ok=0
      call POST "${jf}/Startup/Complete" >/dev/null || ok=0
      if [ "$ok" = 1 ]; then msg_ok "Jellyfin setup wizard done (login: ${APP_USER})"; else problem "The Jellyfin setup wizard did not finish"; fi
    fi
    token=$(call POST "${jf}/Users/AuthenticateByName" "$(jq -nc --arg u "$APP_USER" --arg p "$APP_PASS" '{Username:$u, Pw:$p}')" | jq -r '.AccessToken // empty' || true)
    if [ -z "$token" ]; then
      problem "Could not sign in to Jellyfin with your login (was it set up by hand earlier?)"
    else
      H=(-H "Authorization: ${auth}, Token=\"${token}\"")
      have=$(call GET "${jf}/Library/VirtualFolders" | jq -r '.[].Locations[]?' || true)
      for lib in "Movies|movies|/data/media/movies" "Shows|tvshows|/data/media/tv" "Music|music|/data/media/music"; do
        IFS='|' read -r lname ltype lpath <<<"$lib"
        if grep -qx "$lpath" <<<"$have"; then continue; fi
        if call POST "${jf}/Library/VirtualFolders?name=${lname}&collectionType=${ltype}&refreshLibrary=false" \
          "$(jq -nc --arg p "$lpath" '{LibraryOptions:{PathInfos:[{Path:$p}]}}')" >/dev/null; then
          msg_ok "Jellyfin library ${lname} -> ${lpath}"
        else
          problem "Could not add the Jellyfin ${lname} library"
        fi
      done
    fi
  fi
fi

if has_app seerr; then
  if ! has_app jellyfin; then
    msg_warn "Seerr needs Jellyfin to sign in; add Jellyfin and run the bundle again"
  else
    se="http://${IP[seerr]}:5055/api/v1"
    jar=$(mktemp)
    H=(-b "$jar" -c "$jar")
    msg_info "Waiting for Seerr"
    if ! wait_for "${se}/settings/public"; then
      problem "Seerr did not start in time"
    else
      msg_ok "Seerr is up"
      initialized=$(call GET "${se}/settings/public" | jq -r .initialized)
      if [ "$initialized" = "true" ]; then
        login=$(jq -nc --arg u "$APP_USER" --arg p "$APP_PASS" '{username:$u, password:$p}')
      else
        login=$(jq -nc --arg u "$APP_USER" --arg p "$APP_PASS" --arg h "${IP[jellyfin]}" \
          '{username:$u, password:$p, hostname:$h, port:8096, useSsl:false, urlBase:"", email:($u+"@gfl.local"), serverType:2}')
      fi
      signed=0
      for i in $(seq 1 20); do
        if call POST "${se}/auth/jellyfin" "$login" >/dev/null 2>&1; then signed=1; break; fi
        sleep 3
      done
      if [ "$signed" = 0 ]; then
        problem "Seerr could not sign in with Jellyfin"
      else
        if [ "$initialized" != "true" ]; then
          # Seerr 3: POST .../library/sync then enable each; older Jellyseerr: GET ?sync=true / ?enable=
          if libs=$(call POST "${se}/settings/jellyfin/library/sync" '{}' 2>/dev/null); then
            for lid in $(echo "$libs" | jq -r '.[].id'); do call PUT "${se}/settings/jellyfin/library/${lid}" '{"enabled":true}' >/dev/null || true; done
          else
            libs=$(call GET "${se}/settings/jellyfin/library?sync=true")
            call GET "${se}/settings/jellyfin/library?enable=$(echo "$libs" | jq -r '[.[].id] | join(",")')" >/dev/null || true
          fi
          msg_ok "Seerr signed in with Jellyfin, $(echo "$libs" | jq length) libraries enabled"
        fi
        for app in radarr sonarr; do
          case " $ARRS " in *" $app "*) ;; *) continue ;; esac
          if [ "$(call GET "${se}/settings/${app}" | jq length)" != "0" ]; then continue; fi
          profiles=$(curl -fsS -H "X-Api-Key: ${KEY[$app]}" "http://${IP[$app]}:$(port_of "$app")/api/v3/qualityprofile")
          prof=$(echo "$profiles" | jq -c '(map(select(.name=="HD-1080p"))[0] // .[0]) | {id, name}')
          if [ "$app" = "radarr" ]; then
            extra='{activeDirectory:"/data/media/movies", minimumAvailability:"released"}'
          else
            extra='{activeDirectory:"/data/media/tv", activeAnimeProfileId:$p.id, activeAnimeProfileName:$p.name, activeAnimeDirectory:"/data/media/tv", enableSeasonFolders:true}'
          fi
          body=$(jq -nc --arg n "${app^}" --arg h "${IP[$app]}" --argjson port "$(port_of "$app")" --arg k "${KEY[$app]}" --argjson p "$prof" \
            "{name:\$n, hostname:\$h, port:\$port, apiKey:\$k, useSsl:false, baseUrl:\"\", activeProfileId:\$p.id, activeProfileName:\$p.name,
              is4k:false, isDefault:true, externalUrl:\"\", syncEnabled:true, preventSearch:false} + ${extra}")
          if call POST "${se}/settings/${app}" "$body" >/dev/null; then
            msg_ok "Seerr -> ${app^} connected: requests download automatically"
          else
            problem "Could not connect Seerr to ${app^}"
          fi
        done
        if [ "$initialized" != "true" ]; then
          if call POST "${se}/settings/initialize" '{}' >/dev/null; then msg_ok "Seerr setup finished"; else problem "Could not finish the Seerr setup"; fi
        fi
      fi
    fi
    rm -f "$jar"
  fi
fi

# ---- 7. summary ----------------------------------------------------------------------------
echo
echo -e "${BOLD}Your media setup${CL} (login: ${BL}${APP_USER}${CL} everywhere, Seerr uses your Jellyfin login)"
for app in $APPS; do
  case "$app" in
    qbittorrent) port=8090 ;; flaresolverr) port=8191 ;; jellyfin) port=8096 ;; seerr) port=5055 ;; *) port=$(port_of "$app") ;;
  esac
  printf "  %-13s container %-5s http://%s:%s\n" "$app" "${CT[$app]}" "${IP[$app]}" "$port"
done
echo -e "  Media folder: ${BL}${DATA}${CL} (inside every app: /data)\n"
if [ "${#PROBLEMS[@]}" -gt 0 ]; then
  msg_warn "Finished with ${#PROBLEMS[@]} problem(s). Run the bundle again once those apps have fully started; it only adds what's missing."
  exit 1
fi
msg_ok "Everything is connected. Next: open Prowlarr and add the indexers you use. They sync to Radarr and Sonarr automatically."
