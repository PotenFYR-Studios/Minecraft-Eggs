/** /docs/server-types: all real SERVER_TYPE values with min settings and notes. */
import { useState } from "react";
import {
  Blocks, Container, Gamepad2, GitBranch, Globe, Layers, Network,
  Server as ServerIcon, Smartphone, Terminal, Zap,
} from "lucide-react";
import { JAVA_MAP, SERVER_TYPES, type ServerTypeInfo } from "../catalog";
import { CopyBlock, DocsShell, InlineCode, PageHeader, type TocItem } from "../components";

const ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  vanilla: Gamepad2, paper: Zap, purpur: Zap, folia: Layers, spigot: Blocks,
  fabric: Blocks, quilt: Layers, forge: Container, neoforge: Zap, mohist: Container,
  magma: Container, velocity: Network, bungeecord: Network, waterfall: Globe,
  bedrock: Smartphone, nukkit: Smartphone, pocketmine: Smartphone,
  github: GitBranch, custom: Terminal,
};

const FILTERS = ["All", "Plugins & Paper forks", "Modded & Hybrid", "Proxies", "Bedrock & Mobile", "Custom"] as const;

const TOC: TocItem[] = [
  { id: "catalog", text: "Engine catalog", level: 2 },
  { id: "java-map", text: "Java auto-selection", level: 2 },
  { id: "version-fallback", text: "Version fallback", level: 2 },
];

export default function ServerTypes() {
  const [filter, setFilter] = useState<(typeof FILTERS)[number]>("All");
  const shown = SERVER_TYPES.filter((t) => filter === "All" || t.category === filter);

  return (
    <DocsShell page="server-types" crumbs={[{ label: "Getting Started", to: "/docs/" }, { label: "Server Types" }]} toc={TOC}
      prev={{ to: "/docs/eggs/", title: "Egg Catalog" }} next={{ to: "/examples/", title: "Examples" }}>
      <PageHeader eyebrow="Server types" title="Every engine the egg can run," accent="with real minimums."
        lead={`All ${SERVER_TYPES.length} SERVER_TYPE values with supported versions, default ports, runtime requirements and the variables needed for a minimal install.`} />

      <h2 id="catalog">Engine catalog</h2>
      <div className="mt-4 flex flex-wrap gap-2">
        {FILTERS.map((f) => (
          <button key={f} type="button" onClick={() => setFilter(f)}
            className={`chip cursor-pointer transition-colors${filter === f ? " border-violet/50 text-white" : ""}`}>
            {f}
          </button>
        ))}
      </div>

      <div className="mt-6 grid gap-3.5 sm:grid-cols-2">
        {shown.map((t) => <TypeCard key={t.id} t={t} />)}
      </div>

      <h2 id="java-map">Java auto-selection</h2>
      <p>
        Leave <InlineCode>JAVA_VERSION</InlineCode> empty and the launcher picks the right JVM:
        downloading it on demand into <InlineCode>.java/</InlineCode> when the image doesn't ship
        it. Override with any of: {JAVA_MAP.filter((m) => m.java.startsWith("Java")).map((m) => m.java.replace("Java ", "")).filter((v, i, a) => a.indexOf(v) === i).sort((a, b) => Number(a) - Number(b)).map((v) => <InlineCode key={v}>{v}</InlineCode>)}
      </p>
      <div className="table-scroll my-4">
        <table className="doc-table">
          <thead><tr><th>Minecraft version</th><th>Runtime</th><th>Notes</th></tr></thead>
          <tbody>
            {JAVA_MAP.map((m) => (
              <tr key={m.mc}>
                <td className="whitespace-nowrap font-medium text-txt">{m.mc}</td>
                <td><span className="tag tag-mc">{m.java}</span></td>
                <td>{m.note}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <h2 id="version-fallback">Version fallback</h2>
      <p>
        <InlineCode>MINECRAFT_VERSION</InlineCode> accepts <InlineCode>latest</InlineCode>,{" "}
        <InlineCode>latest-snapshot</InlineCode> (vanilla snapshots) or an exact version. For
        Velocity/Waterfall it is the software version (e.g. <InlineCode>4.0.0</InlineCode>), for
        Bedrock the BDS version (e.g. <InlineCode>1.26.44.3</InlineCode>). Invalid versions fall
        back to <InlineCode>latest</InlineCode> instead of failing the install.
      </p>
      <CopyBlock lang="text" code={"SERVER_TYPE       velocity   # proxy: version = Velocity release\nMINECRAFT_VERSION 3.4.0-SNAPSHOT\n\nSERVER_TYPE       bedrock    # engine: version = BDS release\nMINECRAFT_VERSION latest"} />
    </DocsShell>
  );
}

function TypeCard({ t }: { t: ServerTypeInfo }) {
  const Icon = ICONS[t.id] ?? ServerIcon;
  return (
    <article id={t.id} className="glass-card scroll-mt-24">
      <div className="flex items-center gap-3">
        <div className="icon-tile"><Icon className="h-5 w-5" /></div>
        <div>
          <div className="text-[0.98em] font-semibold text-white">{t.label}</div>
          <div className="font-mono text-[0.72em] text-faint">SERVER_TYPE=<span className="text-[#a7f3d0]">{t.id}</span></div>
        </div>
      </div>
      <div className="text-[0.83em] leading-relaxed text-muted">{t.note}</div>
      <div className="table-scroll">
        <table className="doc-table" style={{ fontSize: "0.8em" }}>
          <tbody>
            <tr><th>Versions</th><td>{t.versions}</td></tr>
            <tr><th>Default port</th><td><span className="tag">:{t.port}</span></td></tr>
            <tr><th>Runtime</th><td>{t.runtime}</td></tr>
            <tr>
              <th>Min settings</th>
              <td>
                {[...t.minSettings, ...(t.extraVars ?? [])].map((v) => (
                  <span key={v} className="tag mr-1.5">{v}</span>
                ))}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </article>
  );
}
