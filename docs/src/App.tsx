/** App shell: 56px header, pages, footer, ⌘K palette, scroll progress. */
import { useEffect, useMemo, useRef, useState } from "react";
import { Menu, Search, X } from "lucide-react";
import {
  CANONICAL_PAGES, DISCORD_URL, NEST_URL, ORG_URL, REPO_URL, pageFromPath, SITE_URL,
  type PageId,
} from "./catalog";
import Home from "./pages/Home";
import Docs from "./pages/Docs";
import Eggs from "./pages/Eggs";
import ServerTypes from "./pages/ServerTypes";
import Examples from "./pages/Examples";
import About from "./pages/About";
import License from "./pages/License";

const NAV: { id: PageId; to: string; title: string }[] = [
  { id: "home", to: "/", title: "Home" },
  { id: "docs", to: "/docs/", title: "Docs" },
  { id: "eggs", to: "/docs/eggs/", title: "Egg Catalog" },
  { id: "server-types", to: "/docs/server-types/", title: "Server Types" },
  { id: "examples", to: "/examples/", title: "Examples" },
  { id: "about", to: "/about/", title: "About" },
];

export default function App() {
  const page = pageFromPath(location.pathname);
  const [menuOpen, setMenuOpen] = useState(false);
  const [paletteOpen, setPaletteOpen] = useState(false);

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: "instant" as ScrollBehavior });
    setMenuOpen(false);
  }, [page]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setPaletteOpen((v) => !v);
      }
      if (e.key === "Escape") setPaletteOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  return (
    <div className="flex min-h-screen flex-col">
      <ScrollProgress />
      <header className="site-header">
        <a href="/" className="flex items-center gap-2.5 no-underline" aria-label="Minecraft Eggs home">
          <img src="/favicon.png" alt="" width={24} height={24} className="brand-mark rounded-md" />
          <span className="text-[0.95em] font-semibold text-white">
            Minecraft<span className="brand-dot">-Eggs</span>
          </span>
          <span className="mono-label hidden sm:inline">docs</span>
        </a>
        <nav className="hidden items-center gap-1 md:flex" aria-label="Primary">
          {NAV.slice(1).map((n) => (
            <a key={n.id} href={n.to} className={`nav-link${page === n.id ? " active" : ""}`}>{n.title}</a>
          ))}
        </nav>
        <div className="ml-auto flex items-center gap-3">
          <button type="button" onClick={() => setPaletteOpen(true)}
            className="hidden items-center gap-2 rounded-lg border border-linelt bg-white/[0.03] px-3 py-1.5 text-xs text-muted transition-colors hover:border-violet/50 md:inline-flex"
            aria-label="Search docs">
            <Search className="h-3.5 w-3.5" /> Search <span className="kbd">⌘K</span>
          </button>
          <a href={NEST_URL} target="_blank" rel="noopener" className="header-ext hidden lg:inline">Nest</a>
          <a href={ORG_URL} target="_blank" rel="noopener" className="header-ext hidden lg:inline">Website</a>
          <a href={DISCORD_URL} target="_blank" rel="noopener" className="header-ext hidden lg:inline">Discord</a>
          <a href={REPO_URL} target="_blank" rel="noopener" className="header-ext">GitHub</a>
          <button type="button" className="mobile-only items-center text-muted" aria-expanded={menuOpen}
            aria-label="Toggle navigation" onClick={() => setMenuOpen((v) => !v)}>
            {menuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </div>
      </header>
      {menuOpen && (
        <nav className="sticky top-[56px] z-400 border-b border-linelt bg-[#0b0d14]/98 px-4 py-3 backdrop-blur-md md:hidden" aria-label="Mobile">
          {NAV.map((n) => (
            <a key={n.id} href={n.to} className={`sidebar-link${page === n.id ? " active" : ""}`}>{n.title}</a>
          ))}
        </nav>
      )}

      <main className="flex-1">
        {page === "home" && <Home />}
        {page === "docs" && <Docs />}
        {page === "eggs" && <Eggs />}
        {page === "server-types" && <ServerTypes />}
        {page === "examples" && <Examples />}
        {page === "about" && <About />}
        {page === "license" && <License />}
      </main>

      <footer className="site-footer">
        <div className="mx-auto max-w-[1280px] px-6 py-10">
          <div className="flex flex-col justify-between gap-8 md:flex-row">
            <div className="max-w-[420px]">
              <div className="flex items-center gap-2.5">
                <img src="/favicon.png" alt="" width={32} height={32} className="rounded-full ring-1 ring-linelt" />
                <span className="font-mono font-bold text-white">
                  Minecraft<span className="brand-dot">-Eggs</span>
                </span>
              </div>
              <p className="mt-3 text-[0.8em] text-muted">
                One universal egg and one Docker image for every Minecraft server, Vanilla to
                Bedrock, Alpha to 26.x, on Pterodactyl, Pelican and Feather Panel.
              </p>
            </div>
            <div className="flex flex-wrap content-start gap-x-5 gap-y-2 font-mono text-[0.78em]">
              <a className="foot-link" href={REPO_URL} target="_blank" rel="noopener">GitHub Org</a>
              <a className="foot-link" href={ORG_URL} target="_blank" rel="noopener">potenfyr.in</a>
              <a className="foot-link" href={DISCORD_URL} target="_blank" rel="noopener">Support Discord</a>
              <a className="foot-link" href={NEST_URL} target="_blank" rel="noopener">Egg Nest</a>
              <a className="foot-link accent" href={SITE_URL}>Docs</a>
              <a className="foot-link" href="/license/">License</a>
            </div>
          </div>
          <div className="mt-6 flex flex-col justify-between gap-2 border-t border-linelt pt-4 text-[0.75em] text-faint sm:flex-row">
            <span>© 2026 PotenFYR Studios. Released under Apache-2.0 with the Commons Clause.</span>
            <span>Crafted with ♥ for the Minecraft hosting community.</span>
          </div>
        </div>
      </footer>

      {paletteOpen && <Palette onClose={() => setPaletteOpen(false)} />}
    </div>
  );
}

/* ------------------------------------------------------- scroll progress */
function ScrollProgress() {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const onScroll = () => {
      const h = document.documentElement;
      const max = h.scrollHeight - h.clientHeight;
      if (ref.current) ref.current.style.width = `${max > 0 ? (h.scrollTop / max) * 100 : 0}%`;
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);
  return <div ref={ref} className="scroll-progress" style={{ width: 0 }} />;
}

/* --------------------------------------------------------- ⌘K palette */
interface PaletteEntry {
  page: string;
  title: string;
  to: string;
  glyph: string;
}

const PALETTE_INDEX: PaletteEntry[] = [
  { page: "Home", title: "Landing: one egg, every Minecraft server", to: "/", glyph: "→" },
  { page: "Getting started", title: "Import the egg into your panel", to: "/docs/", glyph: "→" },
  { page: "Getting started", title: "Create the server (memory & ports)", to: "/docs/#create", glyph: "§" },
  { page: "Getting started", title: "Set the core variables", to: "/docs/#variables", glyph: "§" },
  { page: "Getting started", title: "Java & memory guidance", to: "/docs/#java", glyph: "§" },
  { page: "Getting started", title: "Reinstalls & safe switching", to: "/docs/#reinstall", glyph: "§" },
  { page: "Egg catalog", title: "Egg facts & docker images", to: "/docs/eggs/", glyph: "→" },
  { page: "Egg catalog", title: "All egg variables", to: "/docs/eggs/#variables", glyph: "§" },
  { page: "Egg catalog", title: "Raw egg JSON", to: "/docs/eggs/#raw", glyph: "§" },
  { page: "Server types", title: "Engine catalog (all 19)", to: "/docs/server-types/#catalog", glyph: "§" },
  { page: "Server types", title: "Java auto-selection map", to: "/docs/server-types/#java-map", glyph: "§" },
  { page: "Server types", title: "Vanilla", to: "/docs/server-types/#vanilla", glyph: "§" },
  { page: "Server types", title: "Paper", to: "/docs/server-types/#paper", glyph: "§" },
  { page: "Server types", title: "Velocity proxy", to: "/docs/server-types/#velocity", glyph: "§" },
  { page: "Server types", title: "Bedrock (BDS)", to: "/docs/server-types/#bedrock", glyph: "§" },
  { page: "Examples", title: "Variable cookbook", to: "/examples/#cookbook", glyph: "§" },
  { page: "Examples", title: "Real egg JSON excerpt", to: "/examples/#raw-excerpt", glyph: "§" },
  { page: "About", title: "Project, studio & license", to: "/about/", glyph: "→" },
  { page: "License", title: "What you can do with the egg", to: "/license/", glyph: "→" },
  ...CANONICAL_PAGES.map((p) => ({ page: "Pages", title: p.title, to: p.path, glyph: "→" })),
];

function Palette({ onClose }: { onClose: () => void }) {
  const [q, setQ] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);
  useEffect(() => inputRef.current?.focus(), []);

  const results = useMemo(() => {
    const needle = q.trim().toLowerCase();
    const hits = needle
      ? PALETTE_INDEX.filter((e) => `${e.title} ${e.page}`.toLowerCase().includes(needle))
      : PALETTE_INDEX;
    return hits.slice(0, 14);
  }, [q]);

  return (
    <div className="fixed inset-0 z-50 bg-black/60 pt-28 backdrop-blur-sm" onClick={onClose} role="dialog" aria-modal="true">
      <div className="mx-auto w-full max-w-lg rounded-2xl border border-line bg-[#101320] shadow-2xl"
        onClick={(e) => e.stopPropagation()}>
        <input
          ref={inputRef}
          value={q}
          onChange={(e) => setQ(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter" && results[0]) { location.href = results[0].to; onClose(); }
          }}
          placeholder="Search docs…"
          className="w-full border-b border-linelt bg-transparent px-4 py-3.5 text-sm text-txt outline-none placeholder:text-faint"
        />
        <ul className="max-h-80 overflow-y-auto p-2">
          {results.map((r, i) => (
            <li key={r.to + r.title}>
              <a href={r.to} onClick={onClose}
                className={`flex items-center gap-3 rounded-lg px-3 py-2 text-[13px] ${i === 0 ? "bg-violet/15 text-white" : "text-txt2 hover:bg-white/5"}`}>
                <span className="font-mono text-[10px] text-faint">{r.glyph}</span>
                {r.title}
                <span className="ml-auto font-mono text-[10px] text-faint">{r.page}</span>
              </a>
            </li>
          ))}
          {!results.length && <li className="px-3 py-6 text-center text-[13px] text-faint">No results.</li>}
        </ul>
        <div className="border-t border-linelt px-4 py-2 font-mono text-[10px] text-faint">
          ↑↓ navigate · Enter open · Esc close
        </div>
      </div>
    </div>
  );
}
