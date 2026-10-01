// Documentation pages. Each page is { id, group, title, lede, html }.
// `raw` is the base URL the scripts are served from (from data/scripts.json).
window.GFL_DOCS = (raw) => {
  const run = (path) => `<div class="cmd"><code>bash -c "$(curl -fsSL ${raw}/${path})"</code><button class="copy" type="button" data-copy='bash -c "$(curl -fsSL ${raw}/${path})"'><span>Copy</span></button></div>`;
  return [
    {
      id: "getting-started", group: "Start here", title: "Getting started",
      lede: "Install your first app on Proxmox in about two minutes. You need a Proxmox VE 8.2 or newer host and a web browser.",
      html: `
<h2>1. Open the Proxmox shell</h2>
<p>In the Proxmox web interface, click your node under <b>Datacenter</b> in the left tree, then click <b>Shell</b>. You are now root on the host. SSH as root works too.</p>

<h2>2. On a brand-new host: run the post-install setup</h2>
<p>Without a paid subscription, Proxmox points at repositories you cannot use, so <code>apt update</code> fails. This script fixes that and asks before every change.</p>
${run("tools/post-pve-install.sh")}

<h2>3. Pick an app and run its command</h2>
<p>Every app page has one command. Copy it, paste it into the shell (right-click or <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>V</kbd>) and press Enter. For example, Jellyfin:</p>
${run("ct/jellyfin.sh")}

<h2>4. Choose default settings</h2>
<p>A menu asks how to set up the container. <b>Default settings</b> is right for almost everyone: the next free ID, DHCP on <code>vmbr0</code>, an unprivileged container, and CPU, memory and disk sized for that app. Pick <b>Advanced</b> to choose a static IP, VLAN, password or size. See <a href="#settings">Settings and overrides</a>.</p>

<h2>5. Open the app</h2>
<p>When the script finishes it prints the address to open, such as <code>http://192.168.1.42:8096</code>. The container also appears in the Proxmox tree with a <b>gfl</b> tag, and its <b>Notes</b> panel links back to the app's page here.</p>

<div class="callout"><p>Read a script before you run it as root. Every command on this site links to its source on GitHub. See <a href="#security">Security</a>.</p></div>`
    },
    {
      id: "how-it-works", group: "Start here", title: "How the scripts work",
      lede: "Each app is two small scripts plus a shared library. Knowing the flow makes errors easy to read.",
      html: `
<p>When you run <code>ct/jellyfin.sh</code> on the host, this happens:</p>
<div class="flow">
  <div><span class="tag tag-tool where">host</span><b>ct/jellyfin.sh</b> sets the app's defaults (2 cores, 2048 MiB, 16 GB, GPU on) and loads <code>misc/build.func</code>.</div>
  <div><span class="tag tag-tool where">host</span><b>Checks</b>: you are root, on Proxmox VE 8.2 or newer, on an amd64 CPU.</div>
  <div><span class="tag tag-tool where">host</span><b>Settings</b>: the default/advanced menu, then a summary to confirm.</div>
  <div><span class="tag tag-tool where">host</span><b>Template</b>: finds the newest Debian 13 template with <code>pveam</code> and downloads it if needed.</div>
  <div><span class="tag tag-tool where">host</span><b>pct create</b> builds the container, adds GPU or <code>/dev/net/tun</code> devices if the app needs them, and starts it.</div>
  <div><span class="tag tag-ct where">container</span><b>install/jellyfin-install.sh</b> is copied in with <code>misc/install.func</code> and runs inside: update the OS, install the app, create services.</div>
  <div><span class="tag tag-ct where">container</span><b>Finishing touches</b>: a login banner with the IP, console autologin when you set no password, and the <code>update</code> command.</div>
  <div><span class="tag tag-tool where">host</span><b>Done</b>: the Notes panel is filled in and the app's address is printed.</div>
</div>

<h2>The repository</h2>
<div class="table-wrap"><table>
<tr><th>Folder</th><th>What is in it</th></tr>
<tr><td><code>ct/</code></td><td>One script per app. Runs on the host; defines defaults and the app's update steps.</td></tr>
<tr><td><code>install/</code></td><td>One installer per app. Runs inside the new container.</td></tr>
<tr><td><code>vm/</code></td><td>Scripts that create full virtual machines (Home Assistant OS, Debian).</td></tr>
<tr><td><code>tools/</code></td><td>Maintenance for the Proxmox host itself.</td></tr>
<tr><td><code>misc/</code></td><td>The shared libraries: <code>core.func</code>, <code>build.func</code>, <code>install.func</code>, <code>tools.func</code>.</td></tr>
<tr><td><code>frontend/</code></td><td>This website. The catalog lives in <code>frontend/data/scripts.json</code>.</td></tr>
</table></div>

<h2>Logs</h2>
<p>Commands run quietly behind a spinner. Their output goes to <code>/var/log/gfl-install.log</code> (on the host for host steps, inside the container for install steps). When something fails, the last 20 lines are printed for you. Run with <code>VERBOSE=yes</code> to see everything live.</p>`
    },
    {
      id: "settings", group: "Using the scripts", title: "Settings and overrides",
      lede: "Default settings suit most apps. Advanced settings and environment variables let you change anything.",
      html: `
<h2>Default settings</h2>
<div class="table-wrap"><table>
<tr><th>Setting</th><th>Default</th></tr>
<tr><td>Container ID</td><td>Next free ID (<code>pvesh get /cluster/nextid</code>)</td></tr>
<tr><td>Hostname</td><td>The app's short name, like <code>jellyfin</code></td></tr>
<tr><td>OS</td><td>Debian 13, newest Proxmox template</td></tr>
<tr><td>Type</td><td>Unprivileged, with nesting (plus keyctl for Docker apps)</td></tr>
<tr><td>CPU, RAM, disk</td><td>Sized per app; shown on each app page</td></tr>
<tr><td>Network</td><td><code>vmbr0</code>, DHCP, no VLAN</td></tr>
<tr><td>Password</td><td>None: the Proxmox console logs you in automatically</td></tr>
<tr><td>Start at boot</td><td>Yes</td></tr>
<tr><td>GPU</td><td>Passed in when the app benefits and the host has <code>/dev/dri</code></td></tr>
</table></div>

<h2>Advanced settings</h2>
<p>Choose <b>Advanced</b> in the first menu to set the ID, hostname, container type, root password, CPU, RAM, disk, bridge, static IP and gateway, VLAN, GPU, SSH root login and verbose output. Press <kbd>Esc</kbd> on any question to cancel without changing anything.</p>

<h2>Environment variables</h2>
<p>Put variables in front of the command to change defaults without the menus. Add <code>GFL_MODE=default</code> to skip the menus completely, which is useful for automation.</p>
<pre><code>var_cpu=4 var_ram=8192 var_disk=64 GFL_MODE=default \\
  bash -c "$(curl -fsSL ${raw}/ct/ollama.sh)"</code></pre>
<div class="table-wrap"><table>
<tr><th>Variable</th><th>What it sets</th></tr>
<tr><td><code>var_cpu</code>, <code>var_ram</code>, <code>var_disk</code></td><td>Cores, memory in MiB, disk in GB</td></tr>
<tr><td><code>var_os</code>, <code>var_version</code></td><td>Template, for example <code>ubuntu</code> and <code>24.04</code> (apps are tested on Debian 13)</td></tr>
<tr><td><code>var_unprivileged</code></td><td><code>1</code> unprivileged (default) or <code>0</code> privileged</td></tr>
<tr><td><code>var_gpu</code></td><td><code>yes</code> or <code>no</code>: pass <code>/dev/dri</code> through</td></tr>
<tr><td><code>CT_ID</code>, <code>HN</code></td><td>Container ID and hostname</td></tr>
<tr><td><code>BRG</code>, <code>NET</code>, <code>GATE</code>, <code>VLAN</code></td><td>Bridge, <code>dhcp</code> or <code>192.168.1.50/24</code>, gateway, VLAN tag</td></tr>
<tr><td><code>PW</code></td><td>Root password (leave unset for console autologin)</td></tr>
<tr><td><code>GFL_STORAGE</code>, <code>GFL_TEMPLATE_STORAGE</code></td><td>Storage for the disk and for templates, skipping the storage menu</td></tr>
<tr><td><code>VERBOSE</code></td><td><code>yes</code> shows every command's output</td></tr>
<tr><td><code>GFL_RAW</code></td><td>Where scripts are downloaded from (a fork, a commit or a local folder)</td></tr>
</table></div>

<h2>Changing things later</h2>
<p>Everything the script sets is a normal Proxmox setting. Change CPU and memory in the container's <b>Resources</b> tab, grow the disk with <b>Resources &gt; Volume Action &gt; Resize</b>, and change the network under <b>Network</b>.</p>`
    },
    {
      id: "updating", group: "Using the scripts", title: "Updating apps",
      lede: "Every container gets an update command that knows how to update that app.",
      html: `
<h2>Update one app</h2>
<p>Open the container's <b>Console</b> in Proxmox (or run <code>pct enter &lt;ID&gt;</code> on the host) and type:</p>
<pre><code>update</code></pre>
<p>This downloads the app's current <code>ct/</code> script and runs its update steps. What that means depends on the app:</p>
<div class="table-wrap"><table>
<tr><th>Kind of app</th><th>What <code>update</code> does</th></tr>
<tr><td>From a package repository (Jellyfin, Caddy, Grafana, databases)</td><td>Updates all packages with apt, the app included</td></tr>
<tr><td>Docker apps (Portainer, Vaultwarden, Open WebUI...)</td><td>Updates the OS, pulls the newest image, recreates the container, removes old images</td></tr>
<tr><td>Radarr, Sonarr, Prowlarr</td><td>Updates the OS. The apps update themselves from their own web UI</td></tr>
<tr><td>Uptime Kuma, Wings, Ollama, Minecraft</td><td>Fetches the newest release and restarts the service</td></tr>
</table></div>

<h2>Update every container's OS</h2>
<p>This tool runs apt (or apk) in all running containers and tells you which ones want a reboot:</p>
${run("tools/update-lxcs.sh")}
<p>To run it every Sunday night without questions, add a cron entry on the host:</p>
<pre><code>echo '0 3 * * 0 root GFL_MODE=default bash -c "$(curl -fsSL ${raw}/tools/update-lxcs.sh)"' &gt; /etc/cron.d/gfl-update-lxcs</code></pre>

<h2>Before a big update</h2>
<p>Take a snapshot first: select the container, open <b>Snapshots</b>, click <b>Take Snapshot</b>. If the update goes wrong, roll back in one click.</p>`
    },
    {
      id: "storage", group: "Using the scripts", title: "Storage and shared folders",
      lede: "Give containers access to your media, downloads or backups on the host, a ZFS pool or a NAS.",
      html: `
<h2>Add a folder from the host</h2>
<p>A bind mount makes a host folder appear inside a container. Stop the container, then on the host:</p>
<pre><code># host folder /tank/data shows up as /data inside container 105
pct set 105 -mp0 /tank/data,mp=/data</code></pre>
<p>Use <code>-mp1</code>, <code>-mp2</code> and so on for more folders.</p>

<h2>Permissions in unprivileged containers</h2>
<p>Unprivileged containers shift every user ID by 100000. User or group 1000 inside the container is 101000 on the host. The media apps here (Radarr, Sonarr, Prowlarr, qBittorrent) all use the group <code>media</code> with ID 1000, so give that group the folder on the host:</p>
<pre><code>chown -R 101000:101000 /tank/data
chmod -R 775 /tank/data</code></pre>

<h2>A media stack that uses hardlinks</h2>
<p>Mount the same host folder at <code>/data</code> in qBittorrent, Radarr, Sonarr and Jellyfin. Downloads land in <code>/data/downloads</code>, and Radarr and Sonarr move them into <code>/data/media</code> as instant hardlinks instead of copies. This saves time and doubles nothing on disk.</p>
<pre><code>/tank/data
├── downloads/   qBittorrent saves here
└── media/
    ├── movies/  Radarr root folder, Jellyfin library
    └── tv/      Sonarr root folder, Jellyfin library</code></pre>

<h2>A NAS share</h2>
<p>Add the share to Proxmox under <b>Datacenter &gt; Storage &gt; Add &gt; SMB/CIFS</b> or <b>NFS</b>. It appears on the host at <code>/mnt/pve/&lt;name&gt;</code>; bind-mount that path as above.</p>`
    },
    {
      id: "gpu-passthrough", group: "Using the scripts", title: "GPU passthrough",
      lede: "Hardware transcoding for Jellyfin and faster AI in Ollama need the host's GPU inside the container.",
      html: `
<h2>Intel and AMD</h2>
<p>Scripts for apps that benefit (Jellyfin, Ollama) pass <code>/dev/dri</code> into the container automatically when the host has it. For any other existing container use:</p>
${run("tools/add-gpu-lxc.sh")}
<p>Check it inside the container:</p>
<pre><code>apt install -y vainfo && vainfo</code></pre>
<p>A list of supported profiles means it works. In Jellyfin, open <b>Dashboard &gt; Playback &gt; Transcoding</b>, choose <b>Video Acceleration API (VAAPI)</b> and device <code>/dev/dri/renderD128</code>.</p>

<h2>NVIDIA</h2>
<p>NVIDIA needs the same driver version on the host and in the container. The outline:</p>
<ol>
<li>On the host, install the kernel headers (<code>apt install proxmox-default-headers</code>) and the NVIDIA driver, then reboot. <code>nvidia-smi</code> must work on the host.</li>
<li>Pass the devices into the container:
<pre><code>pct set 105 -dev0 /dev/nvidia0 -dev1 /dev/nvidiactl \\
  -dev2 /dev/nvidia-uvm -dev3 /dev/nvidia-uvm-tools</code></pre></li>
<li>Inside the container, install the <b>same</b> driver version without its kernel module (for the <code>.run</code> installer: <code>--no-kernel-module</code>).</li>
<li>Run <code>nvidia-smi</code> in the container to confirm.</li>
</ol>
<div class="callout warn"><p>After a host driver update, update the driver inside every container that uses the GPU to the same version.</p></div>`
    },
    {
      id: "backups", group: "Using the scripts", title: "Backups",
      lede: "Proxmox backs up containers and VMs itself. Set it up once and it runs every night.",
      html: `
<h2>Back up your containers and VMs</h2>
<ol>
<li>Go to <b>Datacenter &gt; Backup &gt; Add</b>.</li>
<li>Pick a storage that is <b>not</b> the disk your guests run on: a USB disk, a NAS, or a Proxmox Backup Server.</li>
<li>Set a schedule (for example <code>daily 02:00</code>), choose <b>Snapshot</b> mode, and select all guests.</li>
<li>Under <b>Retention</b>, keep for example 7 daily, 4 weekly and 3 monthly backups.</li>
</ol>
<p>Proxmox Backup Server stores each chunk of data once, so daily backups only add what changed. Run it on another machine.</p>

<h2>Back up the host itself</h2>
<p>Guest backups do not include the host's own configuration. This tool saves <code>/etc</code> (with <code>/etc/pve</code>), <code>/root</code> and the cluster database:</p>
${run("tools/host-backup.sh")}

<h2>Test a restore</h2>
<p>A backup you have never restored is a guess. Once in a while, restore a container to a new ID, start it, check it works, then delete it.</p>`
    },
    {
      id: "troubleshooting", group: "Help", title: "Troubleshooting",
      lede: "The error message tells you which step failed. Find it below.",
      html: `
<h2>"No storage can hold templates"</h2>
<p>No storage allows container templates. Go to <b>Datacenter &gt; Storage</b>, edit <code>local</code>, and tick <b>Container template</b> under Content.</p>

<h2>"Container did not get an IP address"</h2>
<p>The container started but nothing answered its DHCP request. Check that the bridge (<code>vmbr0</code> by default) is connected to your network and that your router hands out addresses. Or run again with <b>Advanced</b> and a static IP.</p>

<h2>"The container cannot resolve deb.debian.org"</h2>
<p>DNS does not work inside the container. It copies the host's DNS settings, so check <b>your node &gt; System &gt; DNS</b>. With a static IP, check the gateway too.</p>

<h2>"The installer failed inside container ..."</h2>
<p>The container is left running so you can look around:</p>
<pre><code>pct enter 105
tail -n 50 /var/log/gfl-install.log</code></pre>
<p>Often the cause is a download that timed out. Remove the container and try again, with full output this time:</p>
<pre><code>pct destroy 105 --purge
VERBOSE=yes bash -c "$(curl -fsSL ${raw}/ct/jellyfin.sh)"</code></pre>

<h2>Docker apps fail to start containers</h2>
<p>Docker needs <b>nesting</b> and <b>keyctl</b>, which the scripts turn on. If you built the container another way, set them under <b>Options &gt; Features</b> and restart it.</p>

<h2>wg-easy cannot create the WireGuard interface</h2>
<p>The WireGuard module must be loaded on the host. Run <code>modprobe wireguard</code> on the host and restart the container. The script adds it to <code>/etc/modules</code> so this survives reboots.</p>

<h2>"update: command not found"</h2>
<p>The container was not made by these scripts, or the file was removed. Recreate it with:</p>
<pre><code>printf '#!/usr/bin/env bash\\nbash -c "$(curl -fsSL ${raw}/ct/APP.sh)"\\n' &gt; /usr/bin/update
chmod +x /usr/bin/update</code></pre>
<p>Replace <code>APP</code> with the app's short name, as in its script URL.</p>`
    },
    {
      id: "security", group: "Help", title: "Security",
      lede: "These scripts run as root on your host. Here is what they do and how to check them.",
      html: `
<h2>Read before you run</h2>
<p>Every app page links to its source. Look at the <code>ct/</code> script and its <code>install/</code> script before you run them; they are short on purpose. The host-side logic is in <code>misc/build.func</code>.</p>

<h2>What the scripts do on your host</h2>
<ul>
<li>Create one container or VM, with the settings shown in the summary before you confirm.</li>
<li>Download templates with <code>pveam</code> and images from the app's official source.</li>
<li>Host tools change only what their confirmation screen names.</li>
<li>Nothing is sent anywhere. There is no telemetry.</li>
</ul>

<h2>Safer defaults</h2>
<ul>
<li>Containers are <b>unprivileged</b> unless you pick otherwise: root inside is not root on the host.</li>
<li>Passwords that scripts create are random and saved in <code>/root/&lt;app&gt;.creds</code> inside the container, readable only by root.</li>
<li>Apps come from official repositories, releases or images.</li>
</ul>

<h2>Pin a version</h2>
<p>To run exactly the code you reviewed, point both the URL and <code>GFL_RAW</code> at one commit:</p>
<pre><code>C=&lt;commit-sha&gt;
GFL_RAW=https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/$C \\
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/gamersforlive/gfl-proxmox/$C/ct/jellyfin.sh)"</code></pre>

<h2>Exposing apps to the internet</h2>
<p>Put apps behind a reverse proxy with HTTPS (Nginx Proxy Manager, Caddy) or a Cloudflare Tunnel, and use a VPN (wg-easy, Tailscale) for admin pages. Never forward the Proxmox web UI (port 8006) to the internet.</p>`
    },
    {
      id: "contributing", group: "Help", title: "Write your own script",
      lede: "Adding an app takes two files and one catalog entry.",
      html: `
<h2>1. The host script: <code>ct/myapp.sh</code></h2>
<pre><code>#!/usr/bin/env bash
source &lt;(curl -fsSL "\${GFL_RAW:-${raw}}/misc/build.func")

APP="My App"
var_tags="\${var_tags:-tools}"
var_cpu="\${var_cpu:-1}"
var_ram="\${var_ram:-1024}"
var_disk="\${var_disk:-4}"
var_os="\${var_os:-debian}"
var_version="\${var_version:-13}"
var_unprivileged="\${var_unprivileged:-1}"
var_port="8080"
var_note="Create your login on first visit"

variables
color
catch_errors
header_info

update_script() {
  require_install /opt/myapp
  update_packages
  exit
}

start
build_container
finish</code></pre>
<p>The file name must match <code>APP</code> in lower case with spaces as dashes (<code>my-app.sh</code>), or set <code>var_slug</code>. Add <code>var_docker="yes"</code> for Docker apps, <code>var_gpu="yes"</code> for GPU apps and <code>var_tun="yes"</code> for VPN clients.</p>

<h2>2. The installer: <code>install/myapp-install.sh</code></h2>
<pre><code>#!/usr/bin/env bash
source /opt/gfl/install.func
color
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing My App"
$STD apt-get install -y myapp
msg_ok "Installed My App"

motd_ssh
customize
cleanup_lxc</code></pre>

<h2>Helpers you can use</h2>
<div class="table-wrap"><table>
<tr><th>Helper</th><th>Does</th></tr>
<tr><td><code>msg_info</code>, <code>msg_ok</code>, <code>msg_warn</code>, <code>msg_error</code></td><td>Status lines with a spinner</td></tr>
<tr><td><code>$STD command</code></td><td>Runs a command quietly, logging its output</td></tr>
<tr><td><code>fetch URL</code></td><td><code>curl -fsSL</code> with retries</td></tr>
<tr><td><code>gh_latest owner/repo</code></td><td>Newest GitHub release tag</td></tr>
<tr><td><code>add_repo name key uri suite components</code></td><td>Adds an apt repository with its own keyring</td></tr>
<tr><td><code>install_docker</code>, <code>compose_up dir</code></td><td>Docker from Docker's repo; start <code>/opt/dir/compose.yaml</code></td></tr>
<tr><td><code>gen_pw</code>, <code>save_creds lines...</code></td><td>Random password; save logins to <code>/root/&lt;app&gt;.creds</code></td></tr>
<tr><td><code>require_install</code>, <code>update_packages</code>, <code>update_compose dir</code></td><td>Building blocks for <code>update_script</code></td></tr>
</table></div>

<h2>3. Add it to the catalog</h2>
<p>Add an entry to <code>frontend/data/scripts.json</code> with the same defaults as your script. The site picks it up automatically.</p>

<h2>4. Test it from your own copy</h2>
<p>Clone your fork onto a Proxmox test host and point <code>GFL_RAW</code> at the folder. curl reads <code>file://</code> URLs, so nothing needs to be pushed first:</p>
<pre><code>git clone https://github.com/you/gfl-proxmox /root/gfl-proxmox
GFL_RAW=file:///root/gfl-proxmox bash /root/gfl-proxmox/ct/myapp.sh</code></pre>`
    },
    {
      id: "faq", group: "Help", title: "FAQ",
      lede: "Short answers to the questions people ask most.",
      html: `
<h3>Container or VM?</h3>
<p>Containers (LXC) share the host's kernel, so they start in seconds and use very little memory. Use a VM when you need your own kernel: Home Assistant OS, Windows, or a different operating system.</p>
<h3>Does this work on a Raspberry Pi or other ARM board?</h3>
<p>No. The scripts need an amd64 (x86-64) Proxmox VE host.</p>
<h3>Which Proxmox versions are supported?</h3>
<p>Proxmox VE 8.2 and newer, including 9.x.</p>
<h3>Where is the password for my app?</h3>
<p>On the app's page under <b>After install</b>. Generated passwords are in <code>/root/&lt;app&gt;.creds</code> inside the container; read one from the host with <code>pct exec &lt;ID&gt; -- cat /root/&lt;app&gt;.creds</code>.</p>
<h3>How do I remove an app?</h3>
<p>Stop the container and delete it: <b>More &gt; Remove</b> in the web UI, or <code>pct destroy &lt;ID&gt; --purge</code>. Bind-mounted host folders are not deleted.</p>
<h3>Can I run several apps in one container?</h3>
<p>You can, but one app per container keeps updates, backups and resource limits simple. Containers cost very little.</p>
<h3>Is this the community-scripts project?</h3>
<p>No. GFL Proxmox Scripts is the GamersForLive collection, inspired by the community-scripts ProxmoxVE project and written from scratch, with gaming servers and the GFL media stack in mind.</p>`
    }
  ];
};
