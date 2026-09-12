/** /examples: real egg JSON excerpt + panel variable cookbook. */
import { catalog, EGG_JSON_URL } from "../catalog";
import { CopyBlock, DocsShell, InlineCode, PageHeader, Pagination, slug, type TocItem } from "../components";

const TOC: TocItem[] = [
  { id: "how-to-apply", text: "Applying an example", level: 2 },
  { id: "cookbook", text: "Variable cookbook", level: 2 },
  { id: "raw-excerpt", text: "Real egg JSON excerpt", level: 2 },
];

const EXAMPLES: { id: string; title: string; note?: string; vars: [string, string][] }[] = [
  {
    id: "paper", title: "Modern high-performance Paper",
    vars: [["SERVER_TYPE", "paper"], ["MINECRAFT_VERSION", "1.21.4"], ["BUILD_NUMBER", "latest"]],
  },
  {
    id: "crossplay", title: "Crossplay in one click (Paper + Geyser + Floodgate + ViaVersion)",
    note: "Allocate an extra UDP 19132 port in the panel for Bedrock clients.",
    vars: [
      ["SERVER_TYPE", "paper"],
      ["MINECRAFT_VERSION", "latest"],
      ["EXTRA_URLS", "plugins|https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/geyser\nplugins|https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/floodgate\nplugins|https://github.com/ViaVersion/ViaVersion/releases/latest/download/ViaVersion.jar"],
    ],
  },
  {
    id: "forge-legacy", title: "Legacy modpack (Forge 1.12.2 / 1.7.10)",
    note: "Java 8 is selected automatically; modern Forge/NeoForge (1.17+) runs through @unix_args.txt instead.",
    vars: [["SERVER_TYPE", "forge"], ["MINECRAFT_VERSION", "1.12.2"], ["LOADER_VERSION", "latest"]],
  },
  {
    id: "neoforge", title: "Modern NeoForge 1.21.x server",
    vars: [["SERVER_TYPE", "neoforge"], ["MINECRAFT_VERSION", "1.21.1"], ["LOADER_VERSION", "latest"]],
  },
  {
    id: "velocity", title: "High-throughput proxy network (Velocity)",
    note: "velocity.toml is created automatically and its bind address is patched to the panel port; Stop safely sends end.",
    vars: [["SERVER_TYPE", "velocity"], ["MINECRAFT_VERSION", "latest"]],
  },
  {
    id: "bedrock", title: "Official Bedrock Dedicated Server (BDS)",
    note: "Runs the native BDS binary on UDP 19132 (x86_64 host node).",
    vars: [["SERVER_TYPE", "bedrock"], ["MINECRAFT_VERSION", "latest"]],
  },
  {
    id: "github", title: "Custom GitHub release server (Arclight, Purpur forks, …)",
    vars: [["SERVER_TYPE", "github"], ["GITHUB_REPO", "IzzelAliz/Arclight"], ["GITHUB_TAG", "latest"], ["GITHUB_ASSET", "1.20.4"]],
  },
  {
    id: "custom", title: "Custom engine with your own startup command",
    vars: [["SERVER_TYPE", "custom"], ["CUSTOM_COMMAND", "java -Xmx4096M -jar custom-server.jar nogui"]],
  },
];

export default function Examples() {
  const excerpt = JSON.stringify(
    {
      name: catalog.egg.name,
      description: `${catalog.egg.description.slice(0, 160)}…`,
      docker_images: Object.fromEntries(catalog.egg.dockerImages.map((d) => [d.label, d.image])),
      startup: catalog.egg.startup,
      features: catalog.egg.features,
      variables: catalog.variables.slice(0, 2).map((v) => ({
        name: v.name,
        env_variable: v.env,
        default_value: v.default,
        rules: v.rules,
        user_viewable: v.userViewable,
        user_editable: v.userEditable,
      })),
    },
    null,
    2,
  );

  return (
    <div className="doc mx-auto w-full max-w-6xl px-6 pb-20 pt-9">
      <PageHeader eyebrow="Examples" title="Copy-paste" accent="server configurations."
        lead="Real variable combinations for the most common Minecraft hosting setups; all values map 1:1 onto egg variables in your panel." />

      <h2 id="how-to-apply">Applying an example</h2>
      <p>
        Open your server in the panel → <strong>Startup</strong> tab → paste each value into the
        matching variable. Anything left at its default keeps the behavior described in the{" "}
        <a href="/docs/eggs/">Egg Catalog</a>.
      </p>

      <h2 id="cookbook">Variable cookbook</h2>
      {EXAMPLES.map((ex) => (
        <div key={ex.id} id={ex.id} className="scroll-mt-24">
          <h3 id={`ex-${slug(ex.id)}`}>{ex.title}</h3>
          {ex.note && <p className="text-[0.86em] text-muted">{ex.note}</p>}
          <CopyBlock lang="text" code={ex.vars.map(([k, v]) => `${k.padEnd(18)}${v}`).join("\n")} />
        </div>
      ))}

      <h2 id="raw-excerpt">Real egg JSON excerpt</h2>
      <p>
        Generated straight from <InlineCode>{catalog.generatedFrom}</InlineCode> at build time;
        grab the{" "}
        <a href={EGG_JSON_URL} target="_blank" rel="noopener">full egg file</a> to import it.
      </p>
      <CopyBlock lang="json" code={excerpt} />

      <Pagination prev={{ to: "/docs/server-types/", title: "Server Types" }} next={{ to: "/about/", title: "About" }} />
    </div>
  );
}
