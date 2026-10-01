// GFL Proxmox Scripts website. Plain JS, no build step.
// Routes (hash): ""            -> catalog
//                "#<slug>"     -> one script, e.g. #jellyfin
//                "#<doc-id>"   -> a docs page, e.g. #getting-started
(() => {
  const $ = (sel, el = document) => el.querySelector(sel);
  const app = $("#app");
  const state = { data: null, docs: [], cat: "all", q: "", cfg: {}, mode: "quick" };
  const CFG = window.GFL_CONFIG;
  try { state.mode = localStorage.getItem("gfl-install-mode") === "custom" ? "custom" : "quick"; } catch { /* storage blocked */ }

  const CAT_COLORS = {
    docker: "#2496ed", media: "#a855f7", network: "#22d3ee", security: "#34d399", monitoring: "#fbbf24",
    ai: "#f472b6", gaming: "#84cc16", database: "#60a5fa", vm: "#c084fc", tools: "#f59e0b"
  };
  const TYPE_LABEL = { ct: "LXC", vm: "VM", tool: "Tool" };

  const esc = (s) => String(s ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  const scriptPath = (s) => s.script || `ct/${s.slug}.sh`;
  const command = (s) => `bash -c "$(curl -fsSL ${state.data.rawBase}/${scriptPath(s)})"`;
  const sourceUrl = (path) => `${state.data.repo}/blob/main/${path}`;
  const catName = (id) => (state.data.categories.find((c) => c.id === id) || {}).name || id;
  const initials = (name) => name.replace(/\(.*\)/, "").split(/\s+/).filter(Boolean).slice(0, 2).map((w) => w[0]).join("").toUpperCase();
  const ram = (mib) => (mib >= 1024 ? `${+(mib / 1024).toFixed(1)} GiB` : `${mib} MiB`);

  const icon = (s) =>
    `<span class="mono-icon" style="background:linear-gradient(135deg, ${CAT_COLORS[s.category]}33, ${CAT_COLORS[s.category]}11);border-color:${CAT_COLORS[s.category]}55;color:${CAT_COLORS[s.category]}">${esc(initials(s.name))}</span>`;
  const typeTag = (s) => `<span class="tag tag-${s.type}">${TYPE_LABEL[s.type]}</span>`;
  const cmdBox = (text, live = false) =>
    `<div class="cmd"${live ? " data-cmd" : ""}><code>${esc(text)}</code><button class="copy" type="button" data-copy="${esc(text)}" aria-label="Copy command">` +
    `<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="9" y="9" width="12" height="12" rx="2"/><path d="M5 15V5a2 2 0 0 1 2-2h10"/></svg><span>Copy</span></button></div>`;

  function specs(s) {
    if (!s.resources || !s.resources.cpu) return `<div class="specs"><span>runs on the host</span></div>`;
    const r = s.resources;
    const port = s.port ? `<span>:${s.port}</span>` : "";
    return `<div class="specs"><span>${r.cpu} vCPU</span><span>${ram(r.ram)}</span><span>${r.disk} GB</span>${port}</div>`;
  }

  // ---------- catalog ----------
  function matches(s) {
    if (state.cat !== "all" && s.category !== state.cat) return false;
    if (!state.q) return true;
    const hay = [s.name, s.slug, s.summary, catName(s.category), TYPE_LABEL[s.type], ...(s.flags || [])].join(" ").toLowerCase();
    return state.q.toLowerCase().split(/\s+/).every((w) => hay.includes(w));
  }

  function renderHome() {
    const { scripts, categories } = state.data;
    const count = (t) => scripts.filter((s) => s.type === t).length;
    const list = scripts.filter(matches);
    const cats = [{ id: "all", name: "All scripts" }, ...categories];
    const n = (id) => (id === "all" ? scripts.length : scripts.filter((s) => s.category === id).length);
    const catBtn = (c, cls) => `<button type="button" class="${cls}${state.cat === c.id ? " on" : ""}" data-cat="${c.id}">${esc(c.name)}${cls ? "" : `<span class="count">${n(c.id)}</span>`}</button>`;
    const heading = state.q ? `Results for “${esc(state.q)}”` : state.cat === "all" ? "All scripts" : esc(catName(state.cat));

    app.innerHTML = `
      <section class="hero">
        <div>
          <div class="eyebrow">For Proxmox VE 8.2 and 9</div>
          <h1>One command. <em>A new app</em> on your Proxmox.</h1>
          <p>Paste a command into the Proxmox shell, press Enter, pick default settings. You get a small, updatable container with the app installed and running, and the address to open it.</p>
          ${cmdBox(command(scripts.find((s) => s.slug === "post-pve-install")))}
          <p class="hint">New host? Start with the post-install setup above, then read <a href="#getting-started">Getting started</a>.</p>
          <div class="hero-stats"><span><b>${count("ct")}</b>apps</span><span><b>${count("vm")}</b>virtual machines</span><span><b>${count("tool")}</b>host tools</span></div>
        </div>
        <div class="term" aria-label="Example: installing Jellyfin">
          <div class="term-bar"><i></i><i></i><i></i><span>pve · Shell · example</span></div>
<pre><span class="t-p">root@pve</span>:<span class="t-i">~</span># bash -c "$(curl -fsSL …/ct/jellyfin.sh)"

   <span class="t-pu">GamersForLive</span> · Jellyfin

  <span class="t-ok">✔</span> Templates on local, disk on local-lvm
  <span class="t-ok">✔</span> Using template debian-13-standard_13.1-2_amd64
  <span class="t-ok">✔</span> Created container 105
  <span class="t-ok">✔</span> Passed the GPU (/dev/dri) into the container
  <span class="t-ok">✔</span> Container 105 is up at 192.168.1.42
  <span class="t-ok">✔</span> Installed Jellyfin
  <span class="t-ok">✔</span> Done! Jellyfin is installed

  <span class="t-i">i</span> Open Jellyfin: <span class="t-i">http://192.168.1.42:8096</span>
  <span class="t-i">i</span> Update later: run <span class="t-i">update</span> in the container
<span class="t-p">root@pve</span>:<span class="t-i">~</span># <span class="cursor"></span></pre>
        </div>
      </section>

      <div class="shell">
        <aside class="rail" aria-label="Categories">
          <h4>Categories</h4>
          ${cats.map((c) => catBtn(c, "")).join("")}
          <h4>Docs</h4>
          ${state.docs.slice(0, 5).map((d) => `<a href="#${d.id}">${esc(d.title)}</a>`).join("")}
        </aside>
        <section aria-label="Scripts">
          <div class="chips">${cats.map((c) => catBtn(c, "chip")).join("")}</div>
          <div class="section-head"><h2>${heading}</h2><p>${list.length} of ${scripts.length} scripts</p></div>
          ${list.length ? `<div class="grid">${list.map(card).join("")}</div>` : `<div class="empty">Nothing matches “${esc(state.q)}”. Try a shorter word, or <button class="chip" type="button" data-clear>show everything</button></div>`}
        </section>
      </div>`;
  }

  function card(s) {
    return `<a class="card" href="#${s.slug}">
      <div class="card-top">${icon(s)}<div><h3>${esc(s.name)}</h3><div class="cat">${esc(catName(s.category))}</div></div>${typeTag(s)}</div>
      <p>${esc(s.summary)}</p>
      ${specs(s)}
    </a>`;
  }

  // ---------- one script ----------
  function renderScript(s) {
    const r = s.resources || {};
    const flags = (s.flags || []).map((f) => `<span class="tag tag-flag">${f === "gpu" ? "GPU ready" : f === "docker" ? "Docker" : esc(f)}</span>`).join("");
    const url = s.port ? (s.proto && !/^https?$/.test(s.proto) ? `${s.proto}://<container-ip>:${s.port}` : `${s.proto || "http"}://<container-ip>:${s.port}`) : null;
    const where = s.type === "tool" ? "Run this in the Proxmox host shell. It asks before changing anything." : s.type === "vm" ? "Run this in the Proxmox host shell. It creates a new virtual machine." : "Run this in the Proxmox host shell. It creates a new container.";

    const resourcesPanel = s.type === "tool" ? "" : `
      <div class="panel"><h2>Default settings</h2><dl class="kv">
        <dt>Type</dt><dd>${s.type === "ct" ? "Unprivileged LXC container" : "Virtual machine"}</dd>
        <dt>OS</dt><dd>${esc(r.os || (s.type === "ct" ? "Debian 13" : "Debian 13 cloud image"))}</dd>
        <dt>CPU</dt><dd class="m">${r.cpu} ${r.cpu === 1 ? "core" : "cores"}</dd>
        <dt>Memory</dt><dd class="m">${ram(r.ram)} (${r.ram} MiB)</dd>
        <dt>Disk</dt><dd class="m">${r.disk} GB</dd>
        ${s.port ? `<dt>Port</dt><dd class="m">${s.port}</dd>` : ""}
      </dl><p class="hint">Change any of these under <button type="button" class="linkish" data-mode="custom">Custom settings</button> above.</p></div>`;

    const afterPanel = s.type === "tool" ? "" : `
      <div class="panel"><h2>After install</h2><dl class="kv">
        ${url ? `<dt>Open</dt><dd class="m">${esc(url)}</dd>` : ""}
        <dt>Login</dt><dd>${esc(s.login || "No login needed")}</dd>
        <dt>Update</dt><dd>${s.type === "ct" ? "run update in the container console" : "from inside the VM"}</dd>
      </dl></div>`;

    app.innerHTML = `
      <div class="shell">
        ${scriptRail(s.slug)}
        <article class="detail">
          <header class="detail-head">${icon(s)}<div>
            <h1>${esc(s.name)}</h1>
            <div class="row">${typeTag(s)}<span class="tag tag-flag">${esc(catName(s.category))}</span>${flags}</div>
          </div></header>
          <p class="lede">${esc(s.description)}</p>

          ${installPanel(s, where)}

          ${resourcesPanel || afterPanel ? `<div class="cols">${resourcesPanel}${afterPanel}</div>` : ""}

          ${s.notes && s.notes.length ? `<div class="panel"><h2>Good to know</h2><ul class="notes">${s.notes.map((n) => `<li>${esc(n)}</li>`).join("")}</ul></div>` : ""}

          <div class="links">
            <a class="btn" href="${esc(s.website)}" target="_blank" rel="noopener">Website ↗</a>
            <a class="btn" href="${esc(s.docs)}" target="_blank" rel="noopener">Official docs ↗</a>
            <a class="btn" href="${esc(sourceUrl(scriptPath(s)))}" target="_blank" rel="noopener">Script source ↗</a>
            ${s.type === "ct" ? `<a class="btn" href="${esc(sourceUrl(`install/${s.slug}-install.sh`))}" target="_blank" rel="noopener">Installer source ↗</a>` : ""}
            <a class="btn" href="https://discord.gamersforlive.com" target="_blank" rel="noopener">Get help on Discord ↗</a>
          </div>
        </article>
      </div>`;
    document.title = `${s.name} · GFL Proxmox Scripts`;
    if (CFG.fieldsFor(s)) CFG.refresh(app, s, cfgValues(s), command(s));
  }

  // Quick install (defaults) or Custom settings (a form that builds the command).
  function installPanel(s, where) {
    const custom = CFG.fieldsFor(s) && state.mode === "custom";
    const seg = CFG.fieldsFor(s)
      ? `<div class="seg" role="group" aria-label="Install mode">
           <button type="button" data-mode="quick" aria-pressed="${!custom}">Quick install</button>
           <button type="button" data-mode="custom" aria-pressed="${!!custom}">Custom settings</button>
         </div>`
      : "";
    const form = CFG.fieldsFor(s)
      ? `<section class="panel cfg" data-cfg ${custom ? "" : "hidden"} aria-label="Custom settings">
           <div class="cfg-head"><div><h2>Custom settings</h2><p class="hint">Your command updates as you type. Bridge, gateway, VLAN, DNS and storage are remembered for the next app.</p></div>
             <button type="button" class="btn btn-small" data-reset>Reset to defaults</button></div>
           <form class="cfg-form" autocomplete="off" onsubmit="return false">${CFG.formHtml(s, cfgValues(s))}</form>
           <div class="cfg-foot"><div class="cfg-status" data-status></div>${cmdBox(command(s), true)}</div>
         </section>`
      : "";
    return `
      <div class="panel">
        <div class="install-head"><h2>${s.type === "tool" ? "Run it" : "Install"}</h2>${seg}</div>
        <p>${where}</p>
        <div data-quick ${custom ? "hidden" : ""}>${cmdBox(command(s))}</div>
        <div data-custom ${custom ? "" : "hidden"}><div class="cfg-status" data-status></div>${cmdBox(command(s), true)}</div>
        <p class="hint">Not sure how? Follow <a href="#getting-started">Getting started</a>. Read the <a href="${esc(sourceUrl(scriptPath(s)))}" target="_blank" rel="noopener">script source</a> before running it.</p>
      </div>
      ${form}`;
  }

  function cfgValues(s) {
    if (!state.cfg[s.slug]) state.cfg[s.slug] = CFG.initialValues(s);
    return state.cfg[s.slug];
  }

  const currentScript = () => state.data && state.data.scripts.find((x) => x.slug === decodeURIComponent(location.hash.slice(1)));

  function setMode(mode) {
    const s = currentScript();
    if (!s) return;
    state.mode = mode;
    try { localStorage.setItem("gfl-install-mode", mode); } catch { /* storage blocked */ }
    const custom = mode === "custom";
    app.querySelectorAll("[data-mode]").forEach((b) => b.hasAttribute("aria-pressed") && b.setAttribute("aria-pressed", String(b.dataset.mode === mode)));
    $("[data-quick]", app).hidden = custom;
    $("[data-custom]", app).hidden = !custom;
    $("[data-cfg]", app).hidden = !custom;
    if (custom) $("[data-cfg]", app).scrollIntoView({ behavior: "smooth", block: "start" });
  }

  function onConfigInput(e) {
    const el = e.target.closest("[data-k]");
    const s = currentScript();
    if (!el || !s) return;
    const v = cfgValues(s);
    v[el.dataset.k] = el.type === "checkbox" ? (el.checked ? el.dataset.on : el.dataset.off) : el.value;
    CFG.remember(v);
    CFG.refresh(app, s, v, command(s));
  }

  function scriptRail(active) {
    const { scripts, categories } = state.data;
    return `<aside class="rail" aria-label="All scripts">${categories.map((c) => {
      const items = scripts.filter((s) => s.category === c.id);
      return `<h4>${esc(c.name)}</h4>${items.map((s) => `<a href="#${s.slug}" class="${s.slug === active ? "on" : ""}">${esc(s.name)}</a>`).join("")}`;
    }).join("")}</aside>`;
  }

  // ---------- docs ----------
  function renderDoc(d) {
    const i = state.docs.indexOf(d);
    const prev = state.docs[i - 1], next = state.docs[i + 1];
    const groups = [...new Set(state.docs.map((x) => x.group))];
    app.innerHTML = `
      <div class="shell">
        <aside class="rail" aria-label="Documentation">${groups.map((g) =>
          `<h4>${esc(g)}</h4>${state.docs.filter((x) => x.group === g).map((x) => `<a href="#${x.id}" class="${x === d ? "on" : ""}">${esc(x.title)}</a>`).join("")}`
        ).join("")}</aside>
        <article class="doc">
          <div class="eyebrow">${esc(d.group)}</div>
          <h1>${esc(d.title)}</h1>
          <p class="lede">${esc(d.lede)}</p>
          ${d.html}
          <nav class="pager" aria-label="More docs">
            ${prev ? `<a href="#${prev.id}"><small>Previous</small>${esc(prev.title)}</a>` : "<span></span>"}
            ${next ? `<a href="#${next.id}" style="text-align:right"><small>Next</small>${esc(next.title)}</a>` : "<span></span>"}
          </nav>
        </article>
      </div>`;
    document.title = `${d.title} · GFL Proxmox Scripts`;
  }

  // ---------- routing ----------
  function route() {
    const id = decodeURIComponent(location.hash.replace(/^#/, ""));
    const doc = state.docs.find((d) => d.id === id);
    const script = state.data.scripts.find((s) => s.slug === id);
    document.querySelectorAll("[data-nav]").forEach((a) => a.classList.toggle("active", a.dataset.nav === (doc ? "docs" : "scripts")));
    if (doc) renderDoc(doc);
    else if (script) renderScript(script);
    else { renderHome(); document.title = "GFL Proxmox Scripts"; }
  }

  function toast(msg) {
    const t = $("#toast");
    t.textContent = msg;
    t.classList.add("show");
    clearTimeout(toast.timer);
    toast.timer = setTimeout(() => t.classList.remove("show"), 1800);
  }

  async function copy(btn) {
    const text = btn.dataset.copy;
    try {
      await navigator.clipboard.writeText(text);
      btn.classList.add("done");
      setTimeout(() => btn.classList.remove("done"), 1500);
      toast("Copied. Paste it into the Proxmox shell.");
    } catch {
      const code = btn.parentElement.querySelector("code");
      const range = document.createRange();
      range.selectNodeContents(code);
      const sel = getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
      toast("Selected. Press Ctrl+C to copy.");
    }
  }

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".copy");
    if (btn) return btn.disabled ? undefined : copy(btn);
    const mode = e.target.closest("[data-mode]");
    if (mode) return setMode(mode.dataset.mode);
    if (e.target.closest("[data-reset]")) {
      const s = currentScript();
      state.cfg[s.slug] = CFG.defaults(s);
      $(".cfg-form", app).innerHTML = CFG.formHtml(s, state.cfg[s.slug]);
      CFG.refresh(app, s, state.cfg[s.slug], command(s));
      return;
    }
    const cat = e.target.closest("[data-cat]");
    if (cat) { state.cat = cat.dataset.cat; renderHome(); return; }
    if (e.target.closest("[data-clear]")) { state.q = ""; state.cat = "all"; $("#q").value = ""; renderHome(); }
  });

  app.addEventListener("input", onConfigInput);
  app.addEventListener("change", onConfigInput);

  $("#q").addEventListener("input", (e) => {
    state.q = e.target.value.trim();
    if (state.q) state.cat = "all";
    if (location.hash && location.hash !== "#") history.replaceState(null, "", location.pathname + location.search);
    renderHome();
  });
  document.addEventListener("keydown", (e) => {
    if (e.key === "/" && !/input|textarea/i.test(document.activeElement.tagName)) { e.preventDefault(); $("#q").focus(); }
    if (e.key === "Escape" && document.activeElement === $("#q")) { $("#q").value = ""; state.q = ""; renderHome(); }
  });
  window.addEventListener("hashchange", () => { route(); window.scrollTo(0, 0); });

  fetch("data/scripts.json")
    .then((r) => { if (!r.ok) throw new Error(r.status); return r.json(); })
    .then((data) => {
      state.data = data;
      state.docs = window.GFL_DOCS(data.rawBase);
      $("#repo-link").href = data.repo;
      route();
    })
    .catch((err) => {
      app.innerHTML = `<p class="empty">Could not load data/scripts.json (${esc(err.message)}). Serve this folder over HTTP, for example: python3 -m http.server</p>`;
    });
})();
