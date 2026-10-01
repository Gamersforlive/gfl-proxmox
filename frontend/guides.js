// Per-app guides: frontend/guides/<slug>.md, split into tabs by "## " headings.
// A small, safe Markdown renderer: headings (###), paragraphs, lists, fenced code (with a copy
// button for shell blocks), "> " callouts, **bold**, `code` and [links](url). All text is escaped.
window.GFL_GUIDES = (() => {
  const cache = new Map();
  const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));

  function inline(text) {
    let s = esc(text);
    s = s.replace(/`([^`]+)`/g, "<code>$1</code>");
    s = s.replace(/\*\*([^*]+)\*\*/g, "<b>$1</b>");
    s = s.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (m, t, u) => {
      const internal = u.startsWith("#");
      if (!internal && !/^https?:\/\//.test(u)) return t;
      return `<a href="${u}"${internal ? "" : ' target="_blank" rel="noopener"'}>${t}</a>`;
    });
    return s;
  }

  function render(md) {
    const lines = md.replace(/\r/g, "").split("\n");
    const out = [];
    let i = 0;
    while (i < lines.length) {
      const line = lines[i];
      if (/^```/.test(line)) {
        const lang = line.slice(3).trim();
        const code = [];
        i++;
        while (i < lines.length && !/^```/.test(lines[i])) code.push(lines[i++]);
        i++;
        const text = code.join("\n");
        const shell = /^(bash|sh|shell)$/.test(lang);
        out.push(`<div class="code-block">${lang ? `<span class="code-lang">${esc(lang)}</span>` : ""}` +
          `<pre><code>${esc(text)}</code></pre>` +
          `<button class="copy copy-small" type="button" data-copy="${esc(text)}"><span>${shell ? "Copy" : "Copy"}</span></button></div>`);
        continue;
      }
      if (/^### /.test(line)) { out.push(`<h3>${inline(line.slice(4))}</h3>`); i++; continue; }
      if (/^> /.test(line)) {
        const q = [];
        while (i < lines.length && /^> /.test(lines[i])) q.push(lines[i++].slice(2));
        out.push(`<div class="callout"><p>${inline(q.join(" "))}</p></div>`);
        continue;
      }
      if (/^(- |\d+\. )/.test(line)) {
        const ordered = /^\d+\. /.test(line);
        const items = [];
        while (i < lines.length && /^(- |\d+\. |  \S)/.test(lines[i])) {
          if (/^  \S/.test(lines[i]) && items.length) items[items.length - 1] += " " + lines[i].trim();
          else items.push(lines[i].replace(/^(- |\d+\. )/, ""));
          i++;
        }
        out.push(`<${ordered ? "ol" : "ul"}>${items.map((x) => `<li>${inline(x)}</li>`).join("")}</${ordered ? "ol" : "ul"}>`);
        continue;
      }
      if (!line.trim()) { i++; continue; }
      const para = [];
      while (i < lines.length && lines[i].trim() && !/^(```|### |> |- |\d+\. )/.test(lines[i])) para.push(lines[i++]);
      out.push(`<p>${inline(para.join(" "))}</p>`);
    }
    return out.join("\n");
  }

  // Splits a guide into [{ id, title, html }] by "## " headings.
  function sections(md) {
    const parts = [];
    let cur = null;
    for (const line of md.replace(/\r/g, "").split("\n")) {
      const m = /^## (.+)$/.exec(line);
      if (m) {
        cur = { title: m[1].trim(), body: [] };
        parts.push(cur);
      } else if (cur) cur.body.push(line);
    }
    return parts.map((p) => ({
      id: p.title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, ""),
      title: p.title,
      html: render(p.body.join("\n"))
    }));
  }

  async function load(slug) {
    if (!cache.has(slug)) {
      cache.set(slug, fetch(`guides/${slug}.md`).then((r) => (r.ok ? r.text() : "")).then(sections).catch(() => []));
    }
    return cache.get(slug);
  }

  return { load };
})();
