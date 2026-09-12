/**
 * Prebuild: derive the site catalog from the REAL egg JSON.
 * Every server type, docker image and variable on the docs site comes from
 * egg-minecraft-multi.json: nothing here is invented.
 */
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const eggPath = resolve(here, "../../egg-minecraft-multi.json");
const outPath = resolve(here, "../src/generated/catalog.json");

interface EggVar {
  name?: string;
  env_variable?: string;
  description?: string;
  default_value?: string;
  rules?: string;
  user_viewable?: boolean;
  user_editable?: boolean;
  field_type?: string;
}

interface Egg {
  name?: string;
  description?: string;
  author?: string;
  startup?: string;
  meta?: Record<string, string>;
  features?: string[];
  config?: Record<string, string>;
  docker_images?: Record<string, string>;
  variables?: EggVar[];
}

const egg: Egg = JSON.parse(readFileSync(eggPath, "utf8"));

/** Presentation-only grouping of variables (by env var, never inventing any). */
const GROUPS: Record<string, string> = {
  SERVER_TYPE: "Server Selection",
  MINECRAFT_VERSION: "Server Selection",
  BUILD_NUMBER: "Server Selection",
  LOADER_VERSION: "Server Selection",
  SERVER_JARFILE: "Server Selection",
  GITHUB_REPO: "GitHub Installs",
  GITHUB_TAG: "GitHub Installs",
  GITHUB_ASSET: "GitHub Installs",
  GITHUB_TOKEN: "GitHub Installs",
  JAVA_VERSION: "Java & Performance",
  JAVA_FLAGS: "Java & Performance",
  GC_TYPE: "Java & Performance",
  EXTRA_ARGS: "Java & Performance",
  MOTD: "server.properties",
  MAX_PLAYERS: "server.properties",
  ONLINE_MODE: "server.properties",
  VIEW_DISTANCE: "server.properties",
  DIFFICULTY: "server.properties",
  GAMEMODE: "server.properties",
  PVP: "server.properties",
  RCON_PASSWORD: "server.properties",
  AUTO_UPDATE: "Content & Maintenance",
  KEEP_BACKUP: "Content & Maintenance",
  EXTRA_URLS: "Content & Maintenance",
  WORLD_URL: "Content & Maintenance",
  SHOW_VERSIONS: "Content & Maintenance",
  DL_URL: "Content & Maintenance",
  DEBUG: "Content & Maintenance",
  EGG_UPDATE_URL: "Console & Panel",
  AUTO_UPDATE_EGG: "Console & Panel",
  PANEL_STOP_WATCHER: "Console & Panel",
  CLI_BANNER_GRADIENT: "Console & Panel",
  CLI_THEME: "Console & Panel",
  CUSTOM_COMMAND: "Custom Engine",
};

function rulesValues(rules: string | undefined, env: string): string[] {
  const m = rules?.match(new RegExp(`(?:^|\\|)in:([^|]+)`));
  if (!m) throw new Error(`prebuild: cannot derive ${env} from rules: ${rules}`);
  return m[1].split(",").map((s) => s.trim()).filter(Boolean);
}

const vars = egg.variables ?? [];
const serverTypeVar = vars.find((v) => v.env_variable === "SERVER_TYPE");
const javaVar = vars.find((v) => v.env_variable === "JAVA_VERSION");
if (!serverTypeVar || !javaVar) throw new Error("prebuild: egg is missing SERVER_TYPE / JAVA_VERSION");

const serverTypes = rulesValues(serverTypeVar.rules, "SERVER_TYPE");
const javaVersions = rulesValues(javaVar.rules, "JAVA_VERSION");

const catalog = {
  generatedFrom: "egg-minecraft-multi.json",
  egg: {
    name: egg.name ?? "",
    description: egg.description ?? "",
    author: egg.author ?? "",
    startup: egg.startup ?? "",
    stopCommand: egg.config?.stop ?? "stop",
    format: egg.meta?.version ?? "",
    updateUrl: egg.meta?.update_url ?? "",
    features: egg.features ?? [],
    configFiles: Object.keys(JSON.parse(egg.config?.files ?? "{}")) as string[],
    dockerImages: Object.entries(egg.docker_images ?? {}).map(([label, image]) => ({ label, image })),
  },
  serverTypes,
  javaVersions,
  variables: vars.map((v) => ({
    env: v.env_variable ?? "",
    name: v.name ?? "",
    description: v.description ?? "",
    default: v.default_value ?? "",
    rules: v.rules ?? "",
    userViewable: v.user_viewable === true,
    userEditable: v.user_editable === true,
    group: GROUPS[v.env_variable ?? ""] ?? "Other",
  })),
};

mkdirSync(dirname(outPath), { recursive: true });
writeFileSync(outPath, `${JSON.stringify(catalog, null, 2)}\n`);
console.log(
  `prebuild: catalog.json <- ${catalog.generatedFrom} (${serverTypes.length} server types, ` +
  `${catalog.variables.length} variables, ${catalog.egg.dockerImages.length} docker image(s), ` +
  `java ${javaVersions.join("/")})`,
);
