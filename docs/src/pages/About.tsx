/** /about: the project, the studio, licensing and links. */
import { Boxes, Container, Egg, Globe, LayoutGrid, MessageCircle } from "lucide-react";
import { catalog, DISCORD_URL, NEST_URL, ORG_URL, REPO_URL, SITE_URL } from "../catalog";
import { DocsShell, InlineCode, PageHeader, type TocItem } from "../components";

const TOC: TocItem[] = [
  { id: "project", text: "The project", level: 2 },
  { id: "studio", text: "PotenFYR Studios", level: 2 },
  { id: "links", text: "Links", level: 2 },
  { id: "license", text: "License", level: 2 },
];

export default function About() {
  return (
    <DocsShell page="about" crumbs={[{ label: "About" }]} toc={TOC}
      prev={{ to: "/examples/", title: "Examples" }}
      next={{ to: "/license/", title: "License" }}>
      <PageHeader eyebrow="About" title="One egg, maintained" accent="in the open."
        lead="Minecraft-Eggs is developed by PotenFYR Studios and published as free software for the Minecraft hosting community." />

      <h2 id="project">The project</h2>
      <p>
        <strong>{catalog.egg.name}</strong> is one egg for every Minecraft server: {catalog.serverTypes.length}{" "}
        engines (Vanilla, Paper, Purpur, Fabric, Forge, NeoForge, Velocity, Bedrock and more),
        every version from Alpha to 26.x, automatic Java selection, safe instance switching and a
        full diagnostics toolset. The repository ships the egg JSON ({catalog.generatedFrom}), the
        universal Docker image, and the launcher/installer scripts that power it, tested by a
        Docker-based panel behavior suite on every push.
      </p>

      <h2 id="studio">PotenFYR Studios</h2>
      <p>
        <a href={ORG_URL} target="_blank" rel="noopener">PotenFYR Studios</a> is a creative hub for
        game development, hosting infrastructure, automation tools and community-driven projects,
        from Minecraft plugins and Fabric frameworks to Pterodactyl/Pelican eggs and API security.
      </p>

      <h2 id="links">Links</h2>
      <div className="my-4 grid gap-3.5 sm:grid-cols-2">
        <a className="glass-card" href={ORG_URL} target="_blank" rel="noopener">
          <div className="flex items-center gap-3"><div className="icon-tile"><Globe className="h-5 w-5" /></div>
            <div className="text-[0.95em] font-semibold text-white">potenfyr.in</div></div>
          <div className="text-[0.83em] text-muted">The studio's home base.</div>
        </a>
        <a className="glass-card" href={NEST_URL} target="_blank" rel="noopener">
          <div className="flex items-center gap-3"><div className="icon-tile"><LayoutGrid className="h-5 w-5" /></div>
            <div className="text-[0.95em] font-semibold text-white">nest.potenfyr.in</div></div>
          <div className="text-[0.83em] text-muted">Unified catalog of every PotenFYR egg.</div>
        </a>
        <a className="glass-card" href={REPO_URL} target="_blank" rel="noopener">
          <div className="flex items-center gap-3"><div className="icon-tile"><Container className="h-5 w-5" /></div>
            <div className="text-[0.95em] font-semibold text-white">GitHub: Minecraft-Eggs</div></div>
          <div className="text-[0.83em] text-muted">Source, issues and releases for this egg.</div>
        </a>
        <a className="glass-card" href={DISCORD_URL} target="_blank" rel="noopener">
          <div className="flex items-center gap-3"><div className="icon-tile"><MessageCircle className="h-5 w-5" /></div>
            <div className="text-[0.95em] font-semibold text-white">Support Discord</div></div>
          <div className="text-[0.83em] text-muted">Help, feedback and release announcements.</div>
        </a>
        <a className="glass-card" href={SITE_URL} target="_blank" rel="noopener">
          <div className="flex items-center gap-3"><div className="icon-tile"><Boxes className="h-5 w-5" /></div>
            <div className="text-[0.95em] font-semibold text-white">These docs</div></div>
          <div className="text-[0.83em] text-muted">minecraft-eggs.docs.potenfyr.in</div>
        </a>
        <a className="glass-card" href="mailto:support@potenfyr.in">
          <div className="flex items-center gap-3"><div className="icon-tile"><Egg className="h-5 w-5" /></div>
            <div className="text-[0.95em] font-semibold text-white">support@potenfyr.in</div></div>
          <div className="text-[0.83em] text-muted">Egg author contact.</div>
        </a>
      </div>

      <h2 id="license">License</h2>
      <p>
        Minecraft-Eggs is licensed under the <strong>Apache License 2.0 with the Commons
        Clause</strong>: fork, modify and use it for free, including commercial use and building
        products or services around it, but do not sell the software itself as a product.
      </p>
      <p>
        The <a href={`${REPO_URL}/blob/master/LICENSE`} target="_blank" rel="noopener">LICENSE</a>{" "}
        file in the repository is the authoritative license text; this summary never overrides it.
      </p>
      <p className="text-[0.85em] text-faint">
        Made with ♥ by PotenFYR Studios · Docs generated from{" "}
        <InlineCode>{catalog.generatedFrom}</InlineCode>.
      </p>
    </DocsShell>
  );
}
