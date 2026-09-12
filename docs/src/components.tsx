/** Shared page building blocks: code copy, stat tiles, variable tables, docs shell. */
import { useEffect, useState, type ReactNode } from "react";
import { ArrowRight, Check, ChevronDown, Copy, User, Wrench } from "lucide-react";
import { type EggVariable, type PageId, varsByGroup, withBase } from "./catalog";
import { NumberTicker } from "./magicui";

/* ------------------------------------------------------------ CopyBlock */
export function CopyBlock({ code, lang = "text" }: { code: string; lang?: string }) {
  const [ok, setOk] = useState(false);
  const copy = async () => {
    try {
      await navigator.clipboard.writeText(code);
      setOk(true);
      setTimeout(() => setOk(false), 1400);
    } catch {
      /* clipboard unavailable */
    }
  };
  return (
    <div className="codeblock">
      <button type="button" onClick={copy} className={`copy-btn${ok ? " ok" : ""}`} aria-label="Copy to clipboard">
        {ok ? <Check className="h-3 w-3" /> : <Copy className="h-3 w-3" />}
        <span className="ml-1.5">{ok ? "Copied!" : "Copy"}</span>
      </button>
      <pre data-lang={lang}>
        <code>{code}</code>
      </pre>
    </div>
  );
}

export function InlineCode({ children }: { children: ReactNode }) {
  return <code className="inline">{children}</code>;
}

/* ------------------------------------------------------------- StatTile */
export function StatTile({
  value,
  label,
  icon,
}: {
  value: number;
  label: string;
  icon: ReactNode;
}) {
  const [shown, setShown] = useState(0);
  useEffect(() => {
    const t = setTimeout(() => setShown(value), 350);
    return () => clearTimeout(t);
  }, [value]);
  return (
    <div className="rounded-2xl border border-linelt bg-white/[0.02] p-4 text-center backdrop-blur-md transition-transform hover:-translate-y-0.5">
      <div className="mb-2 flex justify-center [&>svg]:h-5 [&>svg]:w-5 [&>svg]:text-emerald">{icon}</div>
      <div className="grad-text-mc font-mono text-3xl font-extrabold">
        <NumberTicker value={shown} />
      </div>
      <div className="mt-1 text-[11.5px] uppercase tracking-[1.4px] text-muted">{label}</div>
    </div>
  );
}

/* --------------------------------------------------------------- VarTable */
export function VarTable({ vars }: { vars: EggVariable[] }) {
  return (
    <div className="table-scroll my-4">
      <table className="doc-table">
        <thead>
          <tr>
            <th>Variable</th>
            <th>Default</th>
            <th>Access</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          {vars.map((v) => (
            <tr key={v.env}>
              <td className="whitespace-nowrap">
                <span className="tag">{v.env}</span>
                <div className="mt-1 text-[11.5px] text-faint">{v.name}</div>
              </td>
              <td className="max-w-[190px] whitespace-nowrap font-mono text-[0.78em] text-txt2">
                {v.default === "" ? <span className="text-faint">(empty)</span> : truncate(v.default, 44)}
              </td>
              <td>
                <span
                  className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[0.66em] font-bold uppercase tracking-[0.05em] ${
                    v.userViewable
                      ? "bg-emerald/[0.12] text-[#34d399] border border-emerald/30"
                      : "bg-orange/[0.12] text-orange border border-orange/30"
                  }`}
                >
                  {v.userViewable ? <User className="h-3 w-3" /> : <Wrench className="h-3 w-3" />}
                  {v.userViewable ? "User" : "Admin"}
                </span>
              </td>
              <td className="min-w-[280px] text-[0.86em] leading-relaxed">
                {v.description.split("\n").map((line, i) => (
                  <span key={i}>
                    {i > 0 && <br />}
                    {line}
                  </span>
                ))}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function truncate(s: string, n: number): string {
  return s.length > n ? `${s.slice(0, n - 1)}…` : s;
}

export function VarGroup({ group, intro }: { group: string; intro?: string }) {
  const vars = varsByGroup(group);
  return (
    <div>
      <h3 id={`var-${slug(group)}`}>{group}</h3>
      {intro && <p>{intro}</p>}
      <VarTable vars={vars} />
    </div>
  );
}

export function slug(s: string): string {
  return s
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/* ----------------------------------------------------------------- TOC */
export interface TocItem {
  id: string;
  text: string;
  level: 2 | 3;
}

export function Toc({ items }: { items: TocItem[] }) {
  const [active, setActive] = useState(items[0]?.id ?? "");
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const e of entries) if (e.isIntersecting) setActive(e.target.id);
      },
      { rootMargin: "-80px 0px -65% 0px" },
    );
    for (const i of items) {
      const el = document.getElementById(i.id);
      if (el) observer.observe(el);
    }
    return () => observer.disconnect();
  }, [items]);
  if (!items.length) return null;
  return (
    <nav aria-label="On this page" className="sticky top-[84px] max-h-[calc(100vh-112px)] overflow-y-auto pr-1">
      <div className="grad-text-mc mono-label mb-3">
        On this page <span className="text-faint">· {items.length}</span>
      </div>
      {items.map((i) => (
        <a key={i.id} href={`#${i.id}`} className={`toc-link${i.level === 3 ? " l3" : ""}${active === i.id ? " active" : ""}`}>
          {i.text}
        </a>
      ))}
    </nav>
  );
}

/* --------------------------------------------------------------- Pagination */
export function Pagination({ prev, next }: { prev?: { to: string; title: string }; next?: { to: string; title: string } }) {
  if (!prev && !next) return null;
  return (
    <div className="mt-14 grid gap-4 sm:grid-cols-2">
      {prev ? (
        <a href={withBase(prev.to)} className="rounded-xl border border-linelt bg-white/[0.02] p-4 transition hover:-translate-y-0.5 hover:border-violet/50">
          <div className="mono-label mb-1">← Previous</div>
          <div className="text-sm text-txt hover:text-link">{prev.title}</div>
        </a>
      ) : (
        <span />
      )}
      {next && (
        <a href={withBase(next.to)} className="rounded-xl border border-linelt bg-white/[0.02] p-4 text-right transition hover:-translate-y-0.5 hover:border-pink/50">
          <div className="mono-label mb-1">Next →</div>
          <div className="text-sm text-txt hover:text-linkh">{next.title}</div>
        </a>
      )}
    </div>
  );
}

/* -------------------------------------------------------------- DocsShell */
const SIDEBAR: { group: string; links: { id: PageId; to: string; title: string }[] }[] = [
  {
    group: "Get started",
    links: [
      { id: "docs", to: "/docs/", title: "Overview" },
      { id: "eggs", to: "/docs/eggs/", title: "Egg Catalog" },
      { id: "server-types", to: "/docs/server-types/", title: "Server Types" },
    ],
  },
  {
    group: "Project",
    links: [
      { id: "examples", to: "/examples/", title: "Examples" },
      { id: "about", to: "/about/", title: "About" },
      { id: "license", to: "/license/", title: "License" },
    ],
  },
];

/** One collapsible sidebar group (chevron toggle, open by default). */
function SidebarGroup({
  group, links, page,
}: {
  group: string;
  links: { id: PageId; to: string; title: string }[];
  page: PageId;
}) {
  const [open, setOpen] = useState(true);
  return (
    <div className="mb-6">
      <button type="button" onClick={() => setOpen((v) => !v)} aria-expanded={open}
        className="mono-label mb-2 flex w-full cursor-pointer items-center gap-1.5 text-left">
        <ChevronDown className={`h-3 w-3 transition-transform${open ? "" : " -rotate-90"}`} />
        {group}
      </button>
      {open && (
        <div>
          {links.map((l) => (
            <a key={l.id} href={withBase(l.to)} className={`sidebar-link${l.id === page ? " active" : ""}`}>
              {l.title}
            </a>
          ))}
        </div>
      )}
    </div>
  );
}

/** Breadcrumb trail: site root is prepended automatically; nested pages link parents. */
export interface Crumb {
  label: string;
  to?: string;
}

export function DocsShell({
  page,
  crumbs,
  toc,
  prev,
  next,
  children,
}: {
  page: PageId;
  crumbs: Crumb[];
  toc: TocItem[];
  prev?: { to: string; title: string };
  next?: { to: string; title: string };
  children: ReactNode;
}) {
  return (
    <div
      className="docs-grid mx-auto grid w-full max-w-[1720px] gap-10 px-7 pb-20 pt-9"
      style={{ gridTemplateColumns: "240px minmax(0,1fr) 220px" }}
    >
      <aside className="sidebar-rail sticky top-[84px] max-h-[calc(100vh-112px)] self-start overflow-y-auto border-r border-linelt/60 pr-4">
        {SIDEBAR.map((g) => (
          <SidebarGroup key={g.group} group={g.group} links={g.links} page={page} />
        ))}
      </aside>

      <main className="doc min-w-0 max-w-6xl">
        <nav className="section-eyebrow text-faint" aria-label="Breadcrumb">
          <a href={withBase("/")} className="no-underline hover:text-violet">Minecraft Eggs Docs</a>
          {crumbs.map((c) => (
            <span key={c.label}>
              {" / "}
              {c.to
                ? <a href={withBase(c.to)} className="no-underline hover:text-violet">{c.label}</a>
                : c.label}
            </span>
          ))}
        </nav>
        {children}
        <Pagination prev={prev} next={next} />
      </main>

      <aside className="toc-rail">
        <Toc items={toc} />
      </aside>
    </div>
  );
}

/* ------------------------------------------------------------ PageHeader */
export function PageHeader({ eyebrow, title, accent, lead }: { eyebrow: string; title: string; accent?: string; lead?: string }) {
  return (
    <header className="pt-10 md:pt-14">
      <div className="section-eyebrow text-emerald">{eyebrow}</div>
      <h1 className="page-h1 mt-3 text-white">
        {title}
        {accent && (
          <>
            <br />
            <span className="grad-text-mc">{accent}</span>
          </>
        )}
      </h1>
      {lead && <p className="mt-4 max-w-[720px] text-[1.04em] leading-relaxed text-muted">{lead}</p>}
    </header>
  );
}

/* ------------------------------------------------------------- ArrowCard */
export function ArrowCard({ to, title, desc, icon }: { to: string; title: string; desc: string; icon?: ReactNode }) {
  return (
    <a href={withBase(to)} className="glass-card">
      <div className="flex items-center gap-3">
        {icon && <div className="icon-tile">{icon}</div>}
        <div className="text-[0.98em] font-semibold text-white">{title}</div>
      </div>
      <div className="text-[0.83em] leading-relaxed text-muted">{desc}</div>
      <ArrowRight className="hover-arrow h-4 w-4" />
    </a>
  );
}
