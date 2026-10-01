// Checks that frontend/data/scripts.json and the scripts agree:
// every entry has its files, and the defaults shown on the site match the ct/ scripts.
// Run: node .github/scripts/check-catalog.mjs
import { readFileSync, existsSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../..", import.meta.url));
const data = JSON.parse(readFileSync(join(root, "frontend/data/scripts.json"), "utf8"));
const errors = [];
const cats = new Set(data.categories.map((c) => c.id));
const slugs = new Set();

for (const s of data.scripts) {
  const where = `${s.slug}:`;
  if (slugs.has(s.slug)) errors.push(`${where} duplicate slug`);
  slugs.add(s.slug);
  if (!cats.has(s.category)) errors.push(`${where} unknown category "${s.category}"`);
  for (const key of ["name", "summary", "description", "website", "docs"]) if (!s[key]) errors.push(`${where} missing "${key}"`);

  const script = s.script || `ct/${s.slug}.sh`;
  if (!existsSync(join(root, script))) { errors.push(`${where} ${script} does not exist`); continue; }
  if (s.type !== "ct") continue;

  if (!existsSync(join(root, `install/${s.slug}-install.sh`))) errors.push(`${where} install/${s.slug}-install.sh does not exist`);
  const src = readFileSync(join(root, script), "utf8");
  const get = (name) => (src.match(new RegExp(`^${name}="(?:\\$\\{${name}:-)?([^"}]*)`, "m")) || [])[1];

  const app = (src.match(/^APP="([^"]+)"/m) || [])[1];
  const slug = get("var_slug") || (app || "").toLowerCase().replace(/ /g, "-");
  if (slug !== s.slug) errors.push(`${where} APP "${app}" gives slug "${slug}"; set var_slug="${s.slug}"`);
  for (const [key, v] of [["cpu", "var_cpu"], ["ram", "var_ram"], ["disk", "var_disk"]]) {
    if (String(s.resources?.[key]) !== get(v)) errors.push(`${where} ${key} is ${s.resources?.[key]} on the site but ${get(v)} in ${script}`);
  }
  if (String(s.port ?? "") !== (get("var_port") ?? "") && s.proto !== "minecraft" && s.proto !== "mysql" && s.proto !== "postgresql") {
    errors.push(`${where} port is ${s.port} on the site but ${get("var_port")} in ${script}`);
  }
  const hasFlag = (f) => (s.flags || []).includes(f);
  if (hasFlag("docker") !== (get("var_docker") === "yes")) errors.push(`${where} docker flag does not match var_docker`);
  if (hasFlag("gpu") !== (get("var_gpu") === "yes")) errors.push(`${where} gpu flag does not match var_gpu`);
}

for (const [dir, suffix] of [["ct", ".sh"], ["vm", ".sh"], ["tools", ".sh"]]) {
  for (const f of readdirSync(join(root, dir)).filter((f) => f.endsWith(suffix))) {
    const path = `${dir}/${f}`;
    if (!data.scripts.some((s) => (s.script || `ct/${s.slug}.sh`) === path)) errors.push(`${path} is not in frontend/data/scripts.json`);
  }
}

if (errors.length) {
  console.error(`Catalog check failed:\n  - ${errors.join("\n  - ")}`);
  process.exit(1);
}
console.log(`Catalog OK: ${data.scripts.length} scripts.`);
