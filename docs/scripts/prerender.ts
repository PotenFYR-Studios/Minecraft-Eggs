// Static prerender: renderToString() the app for every route and inject the
// markup into the #root div of each emitted HTML file, so crawlers get full
// body content while hydrateRoot() takes over on the client (no re-render
// flash, no hydration mismatch; all render output is deterministic).
//
// Runs after `vite build`; per-route head tags (title/description/canonical/
// OG/JSON-LD) are applied by the multiPageEmit() plugin in vite.config.ts.
// Needs no extra dependencies: react-dom/server + the Bun runtime.

import { readFile, writeFile } from "node:fs/promises";
import { StrictMode, createElement } from "react";
import { renderToString } from "react-dom/server";
import App from "../src/App";
import type { ReactElement } from "react";

/** StrictMode-wrapped app, matching the client entry in src/main.tsx. */
function appElement(): ReactElement {
  return createElement(StrictMode, null, createElement(App));
}

const DIST = decodeURIComponent(new URL("../dist", import.meta.url).pathname);

// Every emitted page with its file twins, plus the 404 fallback (rendered at
// an unknown path; pageFromPath() falls back to "home", exactly what the
// client would render for a soft-404 URL, so hydration still matches).
const ROUTES: { pathname: string; files: string[] }[] = [
  { pathname: "/", files: ["index.html"] },
  { pathname: "/docs/", files: ["docs/index.html", "docs.html"] },
  { pathname: "/docs/eggs/", files: ["docs/eggs/index.html", "docs/eggs.html"] },
  { pathname: "/docs/server-types/", files: ["docs/server-types/index.html", "docs/server-types.html"] },
  { pathname: "/examples/", files: ["examples/index.html", "examples.html"] },
  { pathname: "/about/", files: ["about/index.html", "about.html"] },
  { pathname: "/license/", files: ["license/index.html", "license.html"] },
  { pathname: "/definitely-not-a-real-page/", files: ["404.html"] },
];

type LocStub = Pick<Location, "href" | "protocol" | "host" | "hostname" | "origin" | "pathname" | "search" | "hash">;

/** Point the bare `location` global (read in App at render time) at a route. */
function stubLocation(pathname: string): void {
  const href = `https://minecraft-eggs.docs.potenfyr.in${pathname}`;
  const stub: LocStub = {
    href,
    protocol: "https:",
    host: "minecraft-eggs.docs.potenfyr.in",
    hostname: "minecraft-eggs.docs.potenfyr.in",
    origin: "https://minecraft-eggs.docs.potenfyr.in",
    pathname,
    search: "",
    hash: "",
  };
  Object.defineProperty(globalThis, "location", { value: stub, writable: true, configurable: true });
}

// ---------------------------------------------------------------- main
try {
  let filled = 0;
  for (const route of ROUTES) {
    stubLocation(route.pathname);
    const appHtml = renderToString(appElement());
    if (appHtml.length < 500) {
      throw new Error(`suspiciously small render for ${route.pathname} (${appHtml.length} chars)`);
    }
    for (const file of route.files) {
      const target = `${DIST}/${file}`;
      const html = await readFile(target, "utf8");
      if (!html.includes('<div id="root"></div>')) {
        throw new Error(`root div placeholder not found in ${file}`);
      }
      // Replacer fn: appHtml may contain "$" sequences, never treat them as patterns.
      const out = html.replace('<div id="root"></div>', () => `<div id="root">${appHtml}</div>`);
      await writeFile(target, out);
      filled++;
      console.log(`[prerender] ${file} <- ${route.pathname} (+${appHtml.length} chars body)`);
    }
  }
  console.log(`[prerender] ${ROUTES.length} routes rendered into ${filled} HTML files`);
} catch (err) {
  console.error("[prerender] ERROR:", err);
  process.exit(1);
}
