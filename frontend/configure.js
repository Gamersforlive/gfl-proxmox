// "Custom settings" for a script page: a form whose values become environment variables
// in front of the install command. build.func / tools.func read the same variable names.
window.GFL_CONFIG = (() => {
  const IP4 = /^((25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(25[0-5]|2[0-4]\d|1?\d?\d)$/;
  const SHARED_KEY = "gfl-network-defaults"; // remembered per browser: bridge, gateway, DNS...
  const SHARED = ["BRG", "GATE", "VLAN", "MTU", "NS", "SD", "GFL_STORAGE", "GFL_TEMPLATE_STORAGE"];

  const store = {
    get() { try { return JSON.parse(localStorage.getItem(SHARED_KEY) || "{}"); } catch { return {}; } },
    set(v) { try { localStorage.setItem(SHARED_KEY, JSON.stringify(v)); } catch { /* storage blocked: fine */ } }
  };

  const cidr4 = (v) => { const [ip, p] = v.split("/"); return IP4.test(ip || "") && /^\d{1,2}$/.test(p || "") && +p <= 32; };
  const ipNum = (ip) => ip.split(".").reduce((n, o) => n * 256 + +o, 0);
  const sameSubnet = (cidr, gw) => {
    const [ip, p] = cidr.split("/");
    const mask = p == 0 ? 0 : (0xffffffff << (32 - p)) >>> 0;
    return ((ipNum(ip) & mask) >>> 0) === ((ipNum(gw) & mask) >>> 0);
  };
  const intIn = (min, max, unit = "") => (v) =>
    v === "" ? null : !/^\d+$/.test(v) ? "Whole numbers only" : +v < min ? `At least ${min}${unit}` : max && +v > max ? `At most ${max}${unit}` : null;
  const ram = (mib) => (mib >= 1024 ? `${+(mib / 1024).toFixed(2)} GiB` : `${mib} MiB`);

  // ---- field definitions -------------------------------------------------------------
  // f(key, label, type, opts): type is number | text | select | switch
  const f = (k, label, type, o = {}) => ({ k, label, type, ...o });

  function ctFields(s) {
    const r = s.resources;
    return [
      { group: "Container", fields: [
        f("CT_ID", "Container ID", "number", { ph: "next free", check: intIn(100, 999999999), hint: "Empty = next free ID" }),
        f("HN", "Hostname", "text", { def: s.slug, check: (v) => /^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/.test(v) ? null : "Lowercase letters, numbers and dashes" }),
        f("var_version", "Debian version", "select", { def: "13", options: [["13", "Debian 13 (trixie)"], ["12", "Debian 12 (bookworm)"]] }),
        f("var_unprivileged", "Container type", "select", { def: "1", options: [["1", "Unprivileged (recommended)"], ["0", "Privileged"]],
          warn: (v, all) => all.var_netmount === "yes" && v === "1" ? "Becomes privileged: SMB/NFS mounts inside need it" : v === "0" ? "Root in a privileged container is root on the host. Only use it when you need it." : null }),
        f("var_netmount", "Allow SMB/NFS mounts inside", "switch", { def: "no", on: "yes", off: "no", hint: "Makes the container privileged. Usually better: the NAS share tool." }),
        f("var_onboot", "Start at boot", "switch", { def: "1" })
      ] },
      { group: "Resources", fields: [
        f("var_cpu", "CPU cores", "number", { def: String(r.cpu), check: intIn(1, 512), req: true }),
        f("var_ram", "Memory (MiB)", "number", { def: String(r.ram), check: intIn(128, 0, " MiB"), req: true, live: (v) => (/^\d+$/.test(v) ? `= ${ram(+v)}` : "") }),
        f("var_swap", "Swap (MiB)", "number", { def: "512", check: intIn(0, 0), req: true }),
        f("var_disk", "Disk (GB)", "number", { def: String(r.disk), check: intIn(1, 0, " GB"), req: true })
      ] },
      { group: "Network", fields: [
        f("BRG", "Bridge", "text", { def: "vmbr0", check: (v) => /^[A-Za-z0-9._-]+$/.test(v) ? null : "Like vmbr0", req: true }),
        f("ipv4", "IPv4", "select", { def: "dhcp", options: [["dhcp", "DHCP (automatic)"], ["static", "Static address"]] }),
        f("NET", "IPv4 address / prefix", "text", { ph: "192.168.1.50/24", show: (v) => v.ipv4 === "static", req: true, check: (v) => cidr4(v) ? null : "Like 192.168.1.50/24" }),
        f("GATE", "IPv4 gateway", "text", { ph: "192.168.1.1", show: (v) => v.ipv4 === "static", check: (v) => !v || IP4.test(v) ? null : "Like 192.168.1.1",
          warn: (v, all) => v && IP4.test(v) && cidr4(all.NET || "") && !sameSubnet(all.NET, v) ? "Gateway is outside that subnet" : !v ? "No gateway: the container can't reach the internet" : null }),
        f("ipv6", "IPv6", "select", { def: "none", options: [["none", "None"], ["auto", "SLAAC (auto)"], ["dhcp", "DHCPv6"], ["static", "Static address"]] }),
        f("IPV6", "IPv6 address / prefix", "text", { ph: "fd00::50/64", show: (v) => v.ipv6 === "static", req: true, check: (v) => /^[0-9a-f:]+\/\d{1,3}$/i.test(v) ? null : "Like fd00::50/64" }),
        f("GATE6", "IPv6 gateway", "text", { ph: "fd00::1", show: (v) => v.ipv6 === "static", check: (v) => !v || /^[0-9a-f:]+$/i.test(v) ? null : "Like fd00::1" }),
        f("VLAN", "VLAN tag", "number", { ph: "none", check: intIn(1, 4094) }),
        f("NS", "DNS server(s)", "text", { ph: "host default", hint: "Separate several with spaces", check: (v) => !v || v.split(/\s+/).every((x) => IP4.test(x) || /^[0-9a-f:]+$/i.test(x)) ? null : "IP addresses only" }),
        f("SD", "Search domain", "text", { ph: "host default", check: (v) => !v || /^[A-Za-z0-9.-]+$/.test(v) ? null : "Like home.lan" }),
        f("MTU", "MTU", "number", { ph: "bridge default", check: intIn(576, 65520) }),
        f("MAC", "MAC address", "text", { ph: "random", check: (v) => !v || /^([0-9a-f]{2}:){5}[0-9a-f]{2}$/i.test(v) ? null : "Like BC:24:11:AA:BB:CC" })
      ] },
      { group: "Storage", fields: [
        f("GFL_STORAGE", "Disk storage", "text", { ph: "ask if several", hint: "For example local-lvm or local-zfs", check: (v) => !v || /^[A-Za-z0-9._-]+$/.test(v) ? null : "A storage name from Datacenter > Storage" }),
        f("GFL_TEMPLATE_STORAGE", "Template storage", "text", { ph: "ask if several", hint: "Usually local", check: (v) => !v || /^[A-Za-z0-9._-]+$/.test(v) ? null : "A storage name" }),
        f("MP_HOST", "Host folder to mount", "text", { ph: "none", hint: "A folder or NAS share on the host, like /mnt/gfl/nas", check: (v) => !v || /^\/[A-Za-z0-9._\/-]*$/.test(v) ? null : "An absolute path like /mnt/gfl/nas" }),
        f("MP_PATH", "Mount it at", "text", { def: "/data", show: (v) => !!(v.MP_HOST || "").trim(), req: true, hint: "Media apps use /data", check: (v) => /^\/[A-Za-z0-9._\/-]*$/.test(v) ? null : "A path like /data" })
      ] },
      { group: "Access and extras", fields: [
        f("password", "Root password", "select", { def: "none", options: [["none", "None: console logs in automatically"], ["ask", "Ask me in the terminal"]], hint: "Never put a password in a command; the script asks for it." }),
        f("SSH", "Allow root SSH login", "switch", { def: "no", on: "yes", off: "no" }),
        f("var_gpu", "Pass through GPU (/dev/dri)", "switch", { def: (s.flags || []).includes("gpu") ? "yes" : "no", on: "yes", off: "no" }),
        f("VERBOSE", "Verbose output", "switch", { def: "no", on: "yes", off: "no" }),
        f("confirm", "Show a summary and ask before creating", "switch", { def: "yes", on: "yes", off: "no" })
      ] }
    ];
  }

  function vmFields(s) {
    const r = s.resources, debian = s.slug === "debian-vm";
    const net = [
      f("BRG", "Bridge", "text", { def: "vmbr0", req: true, check: (v) => /^[A-Za-z0-9._-]+$/.test(v) ? null : "Like vmbr0" }),
      f("VLAN", "VLAN tag", "number", { ph: "none", check: intIn(1, 4094) })
    ];
    if (debian) {
      net.splice(1, 0,
        f("ipv4", "IPv4", "select", { def: "dhcp", options: [["dhcp", "DHCP (automatic)"], ["static", "Static address"]] }),
        f("NET", "IPv4 address / prefix", "text", { ph: "192.168.1.60/24", show: (v) => v.ipv4 === "static", req: true, check: (v) => cidr4(v) ? null : "Like 192.168.1.60/24" }),
        f("GATE", "IPv4 gateway", "text", { ph: "192.168.1.1", show: (v) => v.ipv4 === "static", check: (v) => !v || IP4.test(v) ? null : "Like 192.168.1.1",
          warn: (v, all) => v && IP4.test(v) && cidr4(all.NET || "") && !sameSubnet(all.NET, v) ? "Gateway is outside that subnet" : null }),
        f("NS", "DNS server(s)", "text", { ph: "host default", check: (v) => !v || v.split(/\s+/).every((x) => IP4.test(x) || /^[0-9a-f:]+$/i.test(x)) ? null : "IP addresses only" }));
    }
    return [
      { group: "Virtual machine", fields: [
        f("VMID", "VM ID", "number", { ph: "next free", check: intIn(100, 999999999), hint: "Empty = next free ID" }),
        f("NAME", "Name", "text", { def: debian ? "debian" : "haos", check: (v) => /^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$/.test(v) ? null : "Letters, numbers, dots and dashes" }),
        ...(debian ? [f("CIUSER", "Login user", "text", { def: "gfl", check: (v) => /^[a-z_][a-z0-9_-]{0,31}$/.test(v) ? null : "Lowercase letters, numbers, - and _" })] : [])
      ] },
      { group: "Resources", fields: [
        f("CORES", "CPU cores", "number", { def: String(r.cpu), req: true, check: intIn(1, 512) }),
        f("RAM", "Memory (MiB)", "number", { def: String(r.ram), req: true, check: intIn(512, 0, " MiB"), live: (v) => (/^\d+$/.test(v) ? `= ${ram(+v)}` : "") }),
        f("DISK", "Disk (GB)", "number", { def: String(r.disk), req: true, check: intIn(debian ? 4 : 32, 0, " GB") })
      ] },
      { group: "Network", fields: net },
      { group: "Storage", fields: [
        f("GFL_STORAGE", "Disk storage", "text", { ph: "ask if several", hint: "For example local-lvm", check: (v) => !v || /^[A-Za-z0-9._-]+$/.test(v) ? null : "A storage name" })
      ] }
    ];
  }

  function toolFields(s) {
    if (s.slug === "host-backup") return [{ group: "Backup", fields: [
      f("DEST", "Backup folder", "text", { ph: "ask in the terminal", hint: "For example /mnt/pve/nas/host-backups", check: (v) => !v || /^\/[A-Za-z0-9._\/-]*$/.test(v) ? null : "An absolute path like /mnt/pve/nas" }),
      f("KEEP", "Backups to keep", "number", { def: "10", req: true, check: intIn(1, 1000) })
    ] }];
    if (s.slug === "update-lxcs") return [{ group: "Mode", fields: [
      f("unattended", "Update every running container without asking", "switch", { def: "no", on: "yes", off: "no", hint: "Handy for a cron job" })
    ] }];
    return null;
  }

  const fieldsFor = (s) => (s.type === "ct" ? ctFields(s) : s.type === "vm" ? vmFields(s) : toolFields(s));

  // ---- values -> environment ------------------------------------------------------------
  function defaults(s) {
    const v = {};
    for (const g of fieldsFor(s) || []) for (const x of g.fields) v[x.k] = x.def ?? "";
    return v;
  }

  function initialValues(s) {
    const v = defaults(s), saved = store.get();
    for (const k of SHARED) if (k in v && saved[k]) v[k] = saved[k];
    return v;
  }

  function visibleFields(s, v) {
    return (fieldsFor(s) || []).flatMap((g) => g.fields).filter((x) => !x.show || x.show(v));
  }

  function errors(s, v) {
    const out = {};
    for (const x of visibleFields(s, v)) {
      const val = (v[x.k] ?? "").trim();
      if (x.req && val === "") out[x.k] = "Required";
      else if (x.check && val !== "") { const e = x.check(val, v); if (e) out[x.k] = e; }
    }
    return out;
  }

  function env(s, v) {
    const d = defaults(s), e = [];
    const put = (k, val) => { if (val !== undefined && val !== "") e.push([k, String(val).trim()]); };
    const changed = (k) => (v[k] ?? "").trim() !== (d[k] ?? "").trim();
    if (s.type === "ct") {
      put("CT_ID", v.CT_ID);
      if (changed("HN")) put("HN", v.HN);
      if (changed("var_version")) put("var_version", v.var_version);
      if (v.var_netmount === "yes") { put("var_unprivileged", "0"); put("var_netmount", "yes"); }
      else if (changed("var_unprivileged")) put("var_unprivileged", v.var_unprivileged);
      for (const k of ["var_cpu", "var_ram", "var_swap", "var_disk", "var_onboot", "BRG"]) if (changed(k)) put(k, v[k]);
      if ((v.MP_HOST || "").trim()) { put("MP_HOST", v.MP_HOST); if (changed("MP_PATH")) put("MP_PATH", v.MP_PATH); }
      if (v.ipv4 === "static") { put("NET", v.NET); put("GATE", v.GATE); }
      if (v.ipv6 === "static") { put("IPV6", v.IPV6); put("GATE6", v.GATE6); } else if (v.ipv6 !== "none") put("IPV6", v.ipv6);
      for (const k of ["VLAN", "MTU", "MAC", "NS", "SD", "GFL_STORAGE", "GFL_TEMPLATE_STORAGE"]) put(k, v[k]);
      if (v.password === "ask") put("GFL_ASK_PW", "yes");
      if (v.SSH === "yes") put("SSH", "yes");
      if (changed("var_gpu")) put("var_gpu", v.var_gpu);
      if (v.VERBOSE === "yes") put("VERBOSE", "yes");
      if (e.length || v.confirm === "no") put("GFL_MODE", v.confirm === "no" ? "default" : "confirm");
    } else if (s.type === "vm") {
      put("VMID", v.VMID);
      for (const k of ["NAME", "CIUSER", "CORES", "RAM", "DISK", "BRG"]) if (k in d && changed(k)) put(k, v[k]);
      if (v.ipv4 === "static") { put("NET", v.NET); put("GATE", v.GATE); }
      for (const k of ["VLAN", "NS", "GFL_STORAGE"]) put(k, v[k]);
    } else {
      put("DEST", v.DEST);
      if ("KEEP" in d && changed("KEEP")) put("KEEP", v.KEEP);
      if (v.unattended === "yes") put("GFL_MODE", "default");
    }
    return e;
  }

  const quote = (val) => (/^[A-Za-z0-9._\/:@%+=,-]+$/.test(val) ? val : `'${val}'`);

  function command(s, v, base) {
    const e = env(s, v);
    return { text: (e.length ? e.map(([k, x]) => `${k}=${quote(x)}`).join(" ") + " " : "") + base, count: e.filter(([k]) => k !== "GFL_MODE").length };
  }

  // Only touches the shared keys this form has, so a tool page can't wipe them.
  function remember(v) {
    const saved = store.get();
    for (const k of SHARED) {
      if (!(k in v)) continue;
      if (v[k]) saved[k] = v[k];
      else delete saved[k];
    }
    store.set(saved);
  }

  // ---- markup -------------------------------------------------------------------------
  const esc = (x) => String(x ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

  function fieldHtml(x, v) {
    const id = `cfg-${x.k}`, val = v[x.k] ?? "";
    let input;
    if (x.type === "select") {
      input = `<select id="${id}" data-k="${x.k}">${x.options.map(([o, l]) => `<option value="${o}"${o === val ? " selected" : ""}>${esc(l)}</option>`).join("")}</select>`;
    } else if (x.type === "switch") {
      const on = x.on ?? "1";
      return `<div class="field field-switch" data-field="${x.k}"><label class="switch" for="${id}">
        <input type="checkbox" id="${id}" data-k="${x.k}" data-on="${on}" data-off="${x.off ?? "0"}"${val === on ? " checked" : ""}>
        <span class="track" aria-hidden="true"></span><span>${esc(x.label)}</span></label>
        ${x.hint ? `<small class="fhint">${esc(x.hint)}</small>` : ""}</div>`;
    } else {
      input = `<input id="${id}" data-k="${x.k}" type="text" ${x.type === "number" ? 'inputmode="numeric"' : ""} value="${esc(val)}" placeholder="${esc(x.ph || "")}" autocomplete="off" spellcheck="false">`;
    }
    return `<div class="field" data-field="${x.k}">
      <label for="${id}">${esc(x.label)}${x.live ? ` <span class="live" data-live="${x.k}"></span>` : ""}</label>
      ${input}
      <small class="fhint" data-msg="${x.k}">${esc(x.hint || "")}</small>
    </div>`;
  }

  function formHtml(s, v) {
    return (fieldsFor(s) || []).map((g) => `<fieldset class="cfg-group"><legend>${esc(g.group)}</legend><div class="cfg-fields">${g.fields.map((x) => fieldHtml(x, v)).join("")}</div></fieldset>`).join("");
  }

  // Updates visibility, messages and both command boxes without re-rendering the inputs.
  function refresh(root, s, v, base) {
    const all = (fieldsFor(s) || []).flatMap((g) => g.fields);
    const errs = errors(s, v);
    for (const x of all) {
      const box = root.querySelector(`[data-field="${x.k}"]`);
      if (!box) continue;
      box.hidden = !!(x.show && !x.show(v));
      const msg = box.querySelector(`[data-msg="${x.k}"]`);
      const input = box.querySelector("[data-k]");
      const val = (v[x.k] ?? "").trim();
      const warn = !errs[x.k] && x.warn && !box.hidden ? x.warn(val, v) : null;
      if (msg) {
        msg.textContent = errs[x.k] || warn || x.hint || "";
        msg.className = "fhint" + (errs[x.k] ? " is-err" : warn ? " is-warn" : "");
      }
      if (input) input.setAttribute("aria-invalid", errs[x.k] ? "true" : "false");
      const live = box.querySelector(`[data-live="${x.k}"]`);
      if (live) live.textContent = x.live(val);
    }
    const bad = Object.keys(errs).length;
    const { text, count } = command(s, v, base);
    root.querySelectorAll("[data-cmd]").forEach((wrap) => {
      wrap.querySelector("code").textContent = text;
      const btn = wrap.querySelector(".copy");
      btn.dataset.copy = text;
      btn.disabled = bad > 0;
      wrap.classList.toggle("is-blocked", bad > 0);
    });
    root.querySelectorAll("[data-status]").forEach((el) => {
      el.textContent = bad ? `Fix ${bad} setting${bad > 1 ? "s" : ""} to get your command` : count ? `${count} setting${count > 1 ? "s" : ""} changed from the defaults` : "Using the defaults. Change anything below.";
      el.className = "cfg-status" + (bad ? " is-err" : "");
    });
  }

  return { fieldsFor, initialValues, defaults, formHtml, refresh, remember };
})();
