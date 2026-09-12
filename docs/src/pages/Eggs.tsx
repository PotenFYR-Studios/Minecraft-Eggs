/** /docs/eggs: catalog of the real egg: images, startup, features, all variables. */
import { Container } from "lucide-react";
import { catalog, EGG_JSON_URL, GROUP_ORDER, REPO_URL, withBase } from "../catalog";
import {
  CopyBlock, DocsShell, InlineCode, PageHeader, slug, VarGroup, type TocItem,
} from "../components";

const TOC: TocItem[] = [
  { id: "egg-facts", text: "Egg facts", level: 2 },
  { id: "docker", text: "Docker images", level: 2 },
  { id: "startup", text: "Startup & stop", level: 2 },
  { id: "features", text: "Panel features", level: 2 },
  { id: "egg-self-update", text: "Egg self-update", level: 2 },
  { id: "variables", text: "Variables", level: 2 },
  ...GROUP_ORDER.map((g) => ({ id: `var-${slug(g)}`, text: g, level: 3 })),
  { id: "raw", text: "Raw egg JSON", level: 2 },
];

export default function Eggs() {
  const egg = catalog.egg;
  const excerpt = JSON.stringify(
    {
      name: egg.name,
      docker_images: Object.fromEntries(egg.dockerImages.map((d) => [d.label, d.image])),
      startup: egg.startup,
      features: egg.features,
      sample_variable: {
        env_variable: "SERVER_TYPE",
        default_value: catalog.variables.find((v) => v.env === "SERVER_TYPE")?.default,
        rules: catalog.variables.find((v) => v.env === "SERVER_TYPE")?.rules,
      },
    },
    null,
    2,
  );

  return (
    <DocsShell page="eggs" crumbs={[{ label: "Getting Started", to: "/docs/" }, { label: "Egg Catalog" }]} toc={TOC}
      prev={{ to: "/docs/", title: "Getting Started" }} next={{ to: "/docs/server-types/", title: "Server Types" }}>
      <PageHeader eyebrow="Egg catalog" title="The Multi Minecraft egg," accent="end to end."
        lead={`Everything below is generated from the real ${catalog.generatedFrom}: ${catalog.serverTypes.length} server types, ${catalog.variables.length} variables, ${egg.dockerImages.length} docker image.`} />

      <h2 id="egg-facts">Egg facts</h2>
      <div className="table-scroll my-4">
        <table className="doc-table">
          <tbody>
            <tr><th>Egg name</th><td>{egg.name}</td></tr>
            <tr><th>Egg file</th><td><a href={EGG_JSON_URL} target="_blank" rel="noopener">egg-minecraft-multi.json</a> <span className="tag ml-2">{egg.format}</span></td></tr>
            <tr><th>Author</th><td>{egg.author}</td></tr>
            <tr><th>Server types</th><td>{catalog.serverTypes.map((t) => <span key={t} className="tag tag-mc mr-1.5">{t}</span>)}</td></tr>
            <tr><th>Repository</th><td><a href={REPO_URL} target="_blank" rel="noopener">PotenFYR-Studios/Minecraft-Eggs</a></td></tr>
          </tbody>
        </table>
      </div>

      <h2 id="docker">Docker images</h2>
      <p>
        One universal, multi-arch image (linux/amd64 + linux/arm64) serves every server type, and the
        launcher provisions the required JVM on demand, so no per-engine images exist.
      </p>
      <div className="my-4 grid gap-3.5 sm:grid-cols-2">
        {egg.dockerImages.map((d) => (
          <div key={d.label} className="glass-card">
            <div className="flex items-center gap-3">
              <div className="icon-tile"><Container className="h-5 w-5" /></div>
              <div className="text-[0.95em] font-semibold text-white">{d.label}</div>
            </div>
            <span className="tag mt-1 break-all">{d.image}</span>
          </div>
        ))}
      </div>

      <h2 id="startup">Startup &amp; stop</h2>
      <p>
        The startup command never changes; the launcher dispatches per <InlineCode>SERVER_TYPE</InlineCode>{" "}
        on boot. The panel stop command is <InlineCode>{egg.stopCommand}</InlineCode> and startup
        completion markers include <em>“Done (…)!”</em>, <em>“Listening on”</em> and{" "}
        <em>“Server started.”</em>.
      </p>
      <CopyBlock lang="bash" code={egg.startup} />
      <p className="text-[0.9em] text-muted">
        Config auto-patching on boot: {egg.configFiles.map((f) => <InlineCode key={f}>{f}</InlineCode>)}
        {" "}(ports and bind addresses are rewritten to the panel allocation).
      </p>

      <h2 id="features">Panel features</h2>
      <ul>
        {egg.features.map((f) => (
          <li key={f}><InlineCode>{f}</InlineCode>: {FEATURE_NOTES[f] ?? "declared by the egg"}</li>
        ))}
      </ul>

      <h2 id="egg-self-update">Egg self-update</h2>
      <p>
        <InlineCode>EGG_UPDATE_URL</InlineCode> (default: the upstream egg JSON in this repository)
        is checked on every startup when <InlineCode>AUTO_UPDATE_EGG=1</InlineCode>; when it
        changes, the launcher scripts refresh automatically, with no re-import needed. It can also
        point at a raw <InlineCode>.sh</InlineCode> URL to update the launcher directly.
      </p>

      <h2 id="variables">Variables</h2>
      <p>
        All {catalog.variables.length} variables, grouped. <span className="tag">User</span>{" "}
        variables are editable by server owners in the panel; <span className="tag">Admin</span>{" "}
        ones are reserved for node administrators.
      </p>
      {GROUP_ORDER.map((g) => <VarGroup key={g} group={g} />)}

      <h2 id="raw">Raw egg JSON</h2>
      <p>
        A real excerpt from <InlineCode>egg-minecraft-multi.json</InlineCode>. Get the full file{" "}
        <a href={EGG_JSON_URL} target="_blank" rel="noopener">here</a> or see it rendered on the{" "}
        <a href={withBase("/examples/")}>Examples page</a>.
      </p>
      <CopyBlock lang="json" code={excerpt} />
    </DocsShell>
  );
}

const FEATURE_NOTES: Record<string, string> = {
  eula: "the panel prompts to accept the Minecraft EULA on first start",
  java_version: "the panel exposes a Java version selector wired to the egg's auto-detection",
  pid_limit: "the panel raises the process limit for multi-process servers",
};
