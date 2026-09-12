/** /docs: panel import steps, memory/type selection, variable usage, first boot. */
import { DocsShell, CopyBlock, InlineCode, PageHeader, type TocItem } from "../components";
import { EGG_JSON_URL } from "../catalog";

const TOC: TocItem[] = [
  { id: "import", text: "Import the egg", level: 2 },
  { id: "create", text: "Create the server", level: 2 },
  { id: "variables", text: "Set the core variables", level: 2 },
  { id: "features", text: "Panel features & EULA", level: 2 },
  { id: "java", text: "Java & memory guidance", level: 2 },
  { id: "reinstall", text: "Reinstalls & safe switching", level: 2 },
  { id: "stop", text: "Stop behavior", level: 2 },
  { id: "troubleshooting", text: "Troubleshooting", level: 2 },
];

export default function Docs() {
  return (
    <DocsShell page="docs" crumbs={[{ label: "Getting Started" }]} toc={TOC}
      prev={undefined} next={{ to: "/docs/eggs/", title: "Egg Catalog" }}>
      <PageHeader eyebrow="Getting started" title="Deploy Multi Minecraft" accent="in three variables."
        lead="Import one egg file, create a server, set SERVER_TYPE and MINECRAFT_VERSION, and the launcher handles Java, flags, configs and installs on boot." />

      <h2 id="import">Import the egg</h2>
      <p>
        Download <a href={EGG_JSON_URL} target="_blank" rel="noopener">egg-minecraft-multi.json</a>{" "}
        and import it into your panel:
      </p>
      <ul>
        <li><strong>Pterodactyl / Jexactyl:</strong> Admin → Nests → select or create a <em>Minecraft</em> nest → Import Egg.</li>
        <li><strong>Pelican:</strong> Admin → Eggs → Upload Egg.</li>
        <li><strong>Feather / Wisp / plain Docker:</strong> fully compatible with Wings and Pterodactyl v2 egg specifications; use image <InlineCode>ghcr.io/potenfyr-studios/minecraft-eggs:latest</InlineCode>.</li>
      </ul>
      <p>
        The egg is format <InlineCode>PTDL_v2</InlineCode> and self-updates by default, so after the
        first import you rarely need to re-upload it (see{" "}
        <a href="/docs/eggs/#egg-self-update">Egg self-update</a>).
      </p>

      <h2 id="create">Create the server</h2>
      <p>Nest <em>Minecraft</em>, egg <em>Multi Minecraft</em>, then pick resources:</p>
      <div className="table-scroll my-4">
        <table className="doc-table">
          <thead>
            <tr><th>Setting</th><th>Minimum</th><th>Recommended</th></tr>
          </thead>
          <tbody>
            <tr><td>Memory</td><td>2048 MB</td><td>4096 MB+ for Paper / Purpur, 6144 MB+ for modpacks</td></tr>
            <tr><td>Port (Java engines)</td><td colSpan={2}>Allocate <InlineCode>25565</InlineCode> (or any free port; the egg patches configs to match)</td></tr>
            <tr><td>Port (Bedrock engines)</td><td colSpan={2}>Allocate <InlineCode>19132</InlineCode> UDP for <code className="inline">bedrock</code>, <code className="inline">nukkit</code>, <code className="inline">pocketmine</code></td></tr>
            <tr><td>Docker image</td><td colSpan={2}><InlineCode>ghcr.io/potenfyr-studios/minecraft-eggs:latest</InlineCode></td></tr>
          </tbody>
        </table>
      </div>

      <h2 id="variables">Set the core variables</h2>
      <p>
        Two variables drive almost every install. The full reference of all{" "}
        {34} variables lives in the <a href="/docs/eggs/">Egg Catalog</a>.
      </p>
      <CopyBlock lang="text" code={"SERVER_TYPE       paper      # engine (see Server Types page)\nMINECRAFT_VERSION 1.21.4     # or latest / latest-snapshot\nBUILD_NUMBER      latest     # optional pin (Paper, Purpur, Folia, Velocity…)"} />
      <p>
        If a value is missing or invalid the egg never fails silently: an{" "}
        <strong>interactive console wizard</strong> appears in the panel log, offers the valid
        choices (120&nbsp;s timeout) and saves the answer to{" "}
        <InlineCode>.multi-mc.conf</InlineCode>. Panel variables always take priority over saved
        wizard answers.
      </p>

      <h2 id="features">Panel features &amp; EULA</h2>
      <p>
        The egg declares three panel features: <InlineCode>eula</InlineCode>,{" "}
        <InlineCode>java_version</InlineCode> and <InlineCode>pid_limit</InlineCode>. Accept the
        Minecraft <strong>EULA</strong> when the panel prompts. On fresh or missing files the
        launcher self-heals by triggering the installer automatically, so you usually never need to
        press Reinstall by hand.
      </p>

      <h2 id="java">Java &amp; memory guidance</h2>
      <p>
        The container pairs each Minecraft release with the JVM it needs and provisions missing
        runtimes on demand (no Docker rebuild). Leave <InlineCode>JAVA_VERSION</InlineCode> empty
        for auto-selection, or override it with <InlineCode>8</InlineCode>,{" "}
        <InlineCode>11</InlineCode>, <InlineCode>17</InlineCode>, <InlineCode>21</InlineCode>,{" "}
        <InlineCode>25</InlineCode> or <InlineCode>26</InlineCode>. The default{" "}
        <InlineCode>JAVA_FLAGS</InlineCode> are Aikar's tuned G1GC set; for 8&nbsp;GB+ nodes clear
        them and set <InlineCode>GC_TYPE=zgc</InlineCode>.
      </p>
      <p>
        Memory sizing: <InlineCode>SERVER_MEMORY</InlineCode> drives the heap: 2048&nbsp;MB is the
        floor, 4096&nbsp;MB+ suits Paper/Purpur, 6144&nbsp;MB+ suits modpacks. AlwaysPreTouch and
        safe-heap calculation are applied automatically.
      </p>

      <h2 id="reinstall">Reinstalls &amp; safe switching</h2>
      <ul>
        <li><InlineCode>AUTO_UPDATE=1</InlineCode> (default) refreshes the selected software on reinstall; <InlineCode>0</InlineCode> skips installation when files already exist.</li>
        <li><InlineCode>KEEP_BACKUP=1</InlineCode> keeps the previous jar as <InlineCode>&lt;name&gt;.old</InlineCode> when updating.</li>
        <li>
          Changing engine or jumping major Minecraft lines never deletes data: the previous
          install is moved to <InlineCode>archive/&lt;type&gt;-&lt;version&gt;-&lt;timestamp&gt;/</InlineCode>{" "}
          and the new engine installs clean. Same-line updates (1.21.1 → 1.21.4) refresh in place,
          touching nothing.
        </li>
      </ul>

      <h2 id="stop">Stop behavior</h2>
      <p>
        Wings and Feather-style daemons often deliver <em>stop</em> as console text instead of an
        OS signal: the built-in <strong>panel stop watcher</strong> (<InlineCode>PANEL_STOP_WATCHER=auto</InlineCode>)
        intercepts <InlineCode>stop</InlineCode>, <InlineCode>end</InlineCode> and{" "}
        <InlineCode>^C</InlineCode>, forwards all other lines to the server, translates{" "}
        <InlineCode>stop</InlineCode> → <InlineCode>end</InlineCode> for Velocity/BungeeCord, and
        force-sweeps hung processes after the grace window. SIGTERM/SIGINT traps let the JVM save
        world chunks before exit.
      </p>

      <h2 id="troubleshooting">Troubleshooting</h2>
      <ul>
        <li><InlineCode>DEBUG=1</InlineCode>: installer runs with <InlineCode>bash -x</InlineCode> and prints a resolved-environment dump at start.</li>
        <li><InlineCode>SHOW_VERSIONS=1</InlineCode> + Reinstall: prints every upstream version available for the selected engine without changing files.</li>
        <li>Delete <InlineCode>.multi-mc.conf</InlineCode> to reset saved wizard answers.</li>
        <li>Still stuck? Bring the console log to the <a href="https://discord.com/invite/zUaN2FPBec" target="_blank" rel="noopener">support Discord</a>.</li>
      </ul>
    </DocsShell>
  );
}
