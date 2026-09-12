/** Landing: hero, real stats, supported server types, docker facts, nest CTA. */
import {
  Blocks, Boxes, Coffee, Container, Cpu, Gamepad2, GitBranch, Globe, Layers,
  MemoryStick, Network, Package, Puzzle, Server, ShieldCheck, Smartphone,
  Terminal, Wrench, Zap,
} from "lucide-react";
import {
  catalog, DISCORD_URL, EGG_JSON_URL, NEST_URL, REPO_URL, SERVER_TYPES,
} from "../catalog";
import { ArrowCard, CopyBlock, InlineCode, StatTile } from "../components";
import { withBase } from "../catalog";
import { DotPattern, GlowOrb, Marquee, Meteors } from "../magicui";

const TYPE_ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  vanilla: Gamepad2, paper: Zap, purpur: Puzzle, folia: Layers, spigot: Blocks,
  fabric: Puzzle, quilt: Layers, forge: Wrench, neoforge: Zap, mohist: Package,
  magma: Container, velocity: Network, bungeecord: Network, waterfall: Globe,
  bedrock: Smartphone, nukkit: Smartphone, pocketmine: Smartphone,
  github: GitBranch, custom: Terminal,
};

const CATEGORY_ORDER = [
  "Plugins & Paper forks",
  "Modded & Hybrid",
  "Proxies",
  "Bedrock & Mobile",
  "Custom",
] as const;

export default function Home() {
  const nTypes = catalog.serverTypes.length;
  const nVars = catalog.variables.length;
  const nJava = catalog.javaVersions.length;
  const nArch = 2; // linux/amd64 + linux/arm64 (docker-image.yml platforms)

  return (
    <div>
      {/* ------------------------------------------------------------ hero */}
      <section className="relative overflow-hidden">
        <DotPattern className="opacity-60" />
        <GlowOrb className="-top-48 left-[8%]" color="rgba(16,185,129,0.14)" size={520} />
        <GlowOrb className="-top-40 right-[4%]" color="rgba(139,92,246,0.16)" size={480} />
        <GlowOrb className="left-[38%] top-24" color="rgba(236,72,153,0.10)" size={420} />
        <Meteors number={14} />
        <div className="relative mx-auto max-w-5xl px-6 pb-16 pt-[72px] text-center">
          <div className="status-pill mx-auto">
            <span className="pulse-dot" />
            PTDL_v2 egg · Pterodactyl · Pelican · Feather
          </div>
          <h1 className="hero-h1 mt-6 text-white">
            One egg.
            <br />
            <span className="grad-text-mc">Every Minecraft server.</span>
          </h1>
          <p className="mx-auto mt-6 max-w-[720px] text-[1.04em] leading-relaxed text-muted">
            {catalog.egg.name} is one universal egg for Pterodactyl, Pelican and Feather Panel:
            Vanilla, Paper, Purpur, Fabric, Forge, NeoForge, Velocity, Bedrock and every engine in
            between, every version from Alpha to 26.x, with automatic Java selection and safe
            instance switching.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <a href={withBase("/docs/")} className="btn btn-primary">Get Started</a>
            <a href="#server-types" className="btn btn-ghost">Browse Server Types</a>
            <a href={EGG_JSON_URL} target="_blank" rel="noopener" className="btn btn-ghost">
              <Package className="h-4 w-4" /> Download Egg JSON
            </a>
          </div>
        </div>
      </section>

      {/* ----------------------------------------------------------- stats */}
      <section className="mx-auto max-w-3xl px-6 pb-6">
        <div className="grid grid-cols-2 gap-3.5 sm:grid-cols-4">
          <StatTile value={nTypes} label="Server types" icon={<Server />} />
          <StatTile value={nVars} label="Egg variables" icon={<Wrench />} />
          <StatTile value={nJava} label="Java runtimes" icon={<Coffee />} />
          <StatTile value={nArch} label="Architectures" icon={<Cpu />} />
        </div>
      </section>

      {/* -------------------------------------------------- engine marquee */}
      <section className="mx-auto max-w-7xl px-6 py-10">
        <Marquee>
          {SERVER_TYPES.map((t) => {
            const Icon = TYPE_ICONS[t.id] ?? Server;
            return (
              <span key={t.id} className="marquee-item">
                <Icon className="h-3.5 w-3.5 text-violet" /> {t.label}
              </span>
            );
          })}
        </Marquee>
      </section>

      {/* ------------------------------------------- supported server types */}
      <section id="server-types" className="mx-auto max-w-7xl scroll-mt-24 px-6 py-14">
        <div className="section-eyebrow text-emerald">Supported server types</div>
        <h2 className="mt-3 text-3xl font-bold text-white">
          {nTypes} engines, one container image
        </h2>
        <p className="mt-3 max-w-[720px] text-muted">
          Every <InlineCode>SERVER_TYPE</InlineCode> value below ships in the same universal image
          (<InlineCode>ghcr.io/potenfyr-studios/minecraft-eggs:latest</InlineCode>): switch any
          server between engines without swapping eggs or rebuilding Docker images.
        </p>
        {CATEGORY_ORDER.map((cat) => (
          <div key={cat} className="mt-8">
            <div className="mono-label mb-3">{cat}</div>
            <div className="grid gap-3.5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {SERVER_TYPES.filter((t) => t.category === cat).map((t) => {
                const Icon = TYPE_ICONS[t.id] ?? Server;
                return (
                  <a key={t.id} href={withBase(`/docs/server-types/#${t.id}`)} className="glass-card">
                    <div className="flex items-center gap-3">
                      <div className="icon-tile"><Icon className="h-5 w-5" /></div>
                      <div>
                        <div className="text-[0.95em] font-semibold text-white">{t.label}</div>
                        <div className="font-mono text-[0.68em] text-faint">{t.id}</div>
                      </div>
                    </div>
                    <div className="flex flex-wrap gap-1.5">
                      <span className="tag">:{t.port}</span>
                      <span className="tag tag-mc">{t.versions.split(" ·")[0]}</span>
                    </div>
                  </a>
                );
              })}
            </div>
          </div>
        ))}
        <div className="mt-8">
          <a href={withBase("/docs/server-types/")} className="btn btn-ghost btn-sm">
            Full server type reference →
          </a>
        </div>
      </section>

      {/* ------------------------------------------------- what's inside */}
      <section className="mx-auto max-w-7xl px-6 py-14">
        <div className="section-eyebrow text-emerald">What's inside</div>
        <h2 className="mt-3 text-3xl font-bold text-white">Built for real hosting workloads</h2>
        <div className="mt-8 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          <ArrowCard to="/docs/#java" title="Automatic Java selection"
            desc="Java 8 through 26 is paired to the Minecraft version and downloaded on demand inside the container, with no image rebuilds."
            icon={<Coffee className="h-5 w-5" />} />
          <ArrowCard to="/docs/#reinstall" title="Safe instance switching"
            desc="Changing engine or major version archives the old install to archive/, so worlds, plugins and configs are never deleted."
            icon={<ShieldCheck className="h-5 w-5" />} />
          <ArrowCard to="/docs/#stop" title="Panel stop watcher"
            desc="Intercepts stop / end / ^C console text from Wings and Feather-style daemons, with SIGTERM traps and hung-process sweeping."
            icon={<Terminal className="h-5 w-5" />} />
          <ArrowCard to="/docs/#variables" title="Aikar G1GC & ZGC tuning"
            desc="Industry-tuned GC flags by default; clear JAVA_FLAGS and set GC_TYPE=zgc for sub-millisecond pauses on 8 GB+ nodes."
            icon={<MemoryStick className="h-5 w-5" />} />
          <ArrowCard to="/docs/#variables" title="Console wizard"
            desc="A typo in SERVER_TYPE never fails silently: an interactive wizard in the panel log fixes it and saves the answer."
            icon={<Boxes className="h-5 w-5" />} />
          <ArrowCard to="/docs/#features" title="Self-updating egg"
            desc="The launcher checks the upstream egg JSON on boot and refreshes itself, so installs stay current without re-importing."
            icon={<Zap className="h-5 w-5" />} />
        </div>
      </section>

      {/* ---------------------------------------------------- docker facts */}
      <section className="mx-auto max-w-7xl px-6 py-14">
        <div className="glass-card p-6 md:p-8">
          <div className="section-eyebrow text-emerald mb-4">One universal image</div>
          <div className="grid items-start gap-6 md:grid-cols-2">
            <div>
              <h2 className="text-2xl font-bold text-white">Ship the same container everywhere</h2>
              <p className="mt-3 text-muted">
                The egg references a single multi-arch image (linux/amd64 + linux/arm64) with every
                runtime preinstalled. Startup is just <InlineCode>bash run.sh</InlineCode>; the
                launcher resolves engine, version and JVM on boot.
              </p>
              <ul className="mt-4 space-y-2 text-[0.9em] text-txt2">
                <li>• Rootless execution as container user (UID 988)</li>
                <li>• Java 8–26 provisioned on demand into <InlineCode>.java/</InlineCode></li>
                <li>• Fresh server.properties defaults via egg variables</li>
                <li>• Panel stop command: <InlineCode>{catalog.egg.stopCommand}</InlineCode></li>
              </ul>
            </div>
            <div>
              <CopyBlock lang="json" code={JSON.stringify(Object.fromEntries(catalog.egg.dockerImages.map((d) => [d.label, d.image])), null, 2)} />
              <CopyBlock lang="bash" code={catalog.egg.startup} />
            </div>
          </div>
        </div>
      </section>

      {/* ------------------------------------------------------------ nest */}
      <section className="mx-auto max-w-7xl px-6 pb-24 pt-6">
        <div className="flex flex-col items-start justify-between gap-6 rounded-2xl border border-linelt bg-white/[0.02] p-8 backdrop-blur-md md:flex-row md:items-center">
          <div>
            <h2 className="text-2xl font-bold text-white">Browse the whole PotenFYR egg nest</h2>
            <p className="mt-2 max-w-[560px] text-muted">
              Minecraft Eggs is part of the unified PotenFYR Studios catalog, one place for every
              egg collection, including databases and programming languages.
            </p>
          </div>
          <div className="flex flex-wrap gap-4">
            <a href={NEST_URL} target="_blank" rel="noopener" className="btn btn-primary">Open Egg Nest</a>
            <a href={REPO_URL} target="_blank" rel="noopener" className="btn btn-ghost">GitHub</a>
            <a href={DISCORD_URL} target="_blank" rel="noopener" className="btn btn-ghost">Discord</a>
          </div>
        </div>
      </section>
    </div>
  );
}
