import { defineConfig, type Plugin } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dir = dirname(fileURLToPath(import.meta.url));

const CANON = "https://minecraft-eggs.docs.potenfyr.in";

const PAGES = [
  {
    path: "",
    title: "Minecraft Eggs: Universal Egg for Every Minecraft Server",
    description:
      "Multi Minecraft: one universal Pterodactyl, Pelican and Feather Panel egg for Vanilla, Paper, Fabric, Forge, NeoForge, Velocity, Bedrock and 19 server types.",
  },
  {
    path: "docs",
    title: "Getting Started: Minecraft Eggs Docs",
    description:
      "Import the Multi Minecraft egg into Pterodactyl, Pelican or Feather Panel, create a server, choose memory and ports, and set egg variables.",
  },
  {
    path: "docs/eggs",
    title: "Egg Catalog: Minecraft Eggs Docs",
    description:
      "The full Multi Minecraft egg catalog: docker images, startup command, panel features and all egg variables generated from the real egg JSON.",
  },
  {
    path: "docs/server-types",
    title: "Server Types: Minecraft Eggs Docs",
    description:
      "All 19 supported Minecraft server types, from Vanilla, Paper and Purpur to Forge, Fabric, Velocity proxies, Bedrock, Nukkit and PocketMine.",
  },
  {
    path: "examples",
    title: "Examples: Minecraft Eggs Docs",
    description:
      "Real Multi Minecraft egg configuration examples: Paper, crossplay with Geyser, Forge modpacks, NeoForge, Velocity proxies, Bedrock and custom engines.",
  },
  {
    path: "about",
    title: "About: Minecraft Eggs Docs",
    description:
      "About the Minecraft-Eggs project, PotenFYR Studios, licensing (Apache-2.0 with Commons Clause) and links to the unified egg catalog.",
  },
  {
    path: "license",
    title: "License: Minecraft Eggs Docs",
    description:
      "Free to fork, modify, self-host and redistribute under Apache-2.0 with the Commons Clause. What you can do, and what you cannot, in plain language.",
  },
] as const;

/** Static JSON-LD graph for the landing route (values from the real egg inventory). */
const JSON_LD = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "@id": `${CANON}/#website`,
      url: `${CANON}/`,
      name: "Minecraft Eggs Docs",
      description:
        "Documentation for the Multi Minecraft egg: one universal Minecraft server egg for Pterodactyl, Pelican and Feather Panel.",
      publisher: { "@id": `${CANON}/#org` },
    },
    {
      "@type": "Organization",
      "@id": `${CANON}/#org`,
      name: "PotenFYR Studios",
      url: "https://potenfyr.in",
      sameAs: [
        "https://github.com/PotenFYR-Studios",
        "https://modrinth.com/organization/potenfyr",
      ],
    },
    {
      "@type": "SoftwareApplication",
      "@id": `${CANON}/#egg`,
      name: "Multi Minecraft",
      applicationCategory: "GameApplication",
      operatingSystem: "Pterodactyl / Pelican / Feather Panel",
      description:
        "One universal Minecraft server egg for Pterodactyl, Pelican and Feather Panel: 19 server types, every version from Alpha to 26.x, automatic Java selection.",
      featureList: [
        "vanilla", "paper", "spigot", "purpur", "folia",
        "fabric", "quilt", "forge", "neoforge", "mohist", "magma",
        "velocity", "bungeecord", "waterfall",
        "bedrock", "nukkit", "pocketmine",
        "github releases", "custom engine",
      ],
      codeRepository: "https://github.com/PotenFYR-Studios/Minecraft-Eggs",
      author: { "@id": `${CANON}/#org` },
      publisher: { "@id": `${CANON}/#org` },
      offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
    },
  ],
};

const OG_ALT =
  "Minecraft Eggs documentation banner: the Multi Minecraft egg serving Vanilla, Paper, Fabric, Forge, Bedrock and more on Pterodactyl, Pelican and Feather Panel";

/** SPA shell with one route's full SEO head: title/description/canonical/OG. */
function seoShell(
  shell: string,
  title: string,
  description: string,
  canon: string,
  jsonLd: string,
): string {
  const attr = (s: string) => s.replace(/"/g, "&quot;");
  return shell
    .replace(/<title>.*?<\/title>/, `<title>${attr(title)}</title>`)
    .replace(
      "</head>",
      `  <meta name="description" content="${attr(description)}">\n` +
      `<link rel="canonical" href="${canon}">\n` +
      `<meta property="og:title" content="${attr(title)}">\n` +
      `<meta property="og:description" content="${attr(description)}">\n` +
      `<meta property="og:url" content="${canon}">\n` +
      `<meta property="og:image" content="${CANON}/og.png">\n` +
      `<meta property="og:image:alt" content="${attr(OG_ALT)}">\n` +
      `<meta name="twitter:card" content="summary_large_image">\n` +
      `<meta name="twitter:image" content="${CANON}/og.png">\n` +
      jsonLd +
      `</head>`,
    );
}

/** Emit /<path>/index.html and /<path>.html copies of the SPA shell with
 *  per-page SEO meta. scripts/prerender.ts fills the body afterwards. */
function multiPageEmit(): Plugin {
  return {
    name: "mceggs-multi-page",
    closeBundle() {
      const outDir = resolve(__dir, "dist");
      const shell = readFileSync(resolve(outDir, "index.html"), "utf8");
      for (const p of PAGES) {
        const dir = resolve(outDir, p.path);
        mkdirSync(dir, { recursive: true });
        const canon = `${CANON}/${p.path}${p.path ? "/" : ""}`;
        const jsonLd =
          p.path === ""
            ? `<script type="application/ld+json">${JSON.stringify(JSON_LD)}</script>\n`
            : "";
        const html = seoShell(shell, p.title, p.description, canon, jsonLd);
        writeFileSync(resolve(dir, "index.html"), html);
        // Extension twin: /docs/eggs.html alongside /docs/eggs/index.html.
        if (p.path) writeFileSync(resolve(outDir, `${p.path}.html`), html);
      }
      // GitHub Pages soft-404 fallback: full chrome + its own meta (unique
      // title/description so the fallback never mirrors the landing page).
      writeFileSync(
        resolve(outDir, "404.html"),
        seoShell(
          shell,
          "Page Not Found: Minecraft Eggs Docs",
          "The page you requested does not exist. Browse the Multi Minecraft egg docs, the full egg catalog, all 19 server types and configuration examples.",
          `${CANON}/404.html`,
          "",
        ),
      );
    },
  };
}

export default defineConfig({
  root: __dir,
  base: "/",
  plugins: [react(), tailwindcss(), multiPageEmit()],
  build: {
    outDir: "dist",
    emptyOutDir: true,
    sourcemap: false,
  },
  server: { port: 5175 },
});
