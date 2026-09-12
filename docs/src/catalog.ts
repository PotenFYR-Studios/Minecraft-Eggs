/** Typed access to the build-time catalog generated from egg-minecraft-multi.json. */
import raw from "./generated/catalog.json";

export interface EggVariable {
  env: string;
  name: string;
  description: string;
  default: string;
  rules: string;
  userViewable: boolean;
  userEditable: boolean;
  group: string;
}

export interface Catalog {
  generatedFrom: string;
  egg: {
    name: string;
    description: string;
    author: string;
    startup: string;
    stopCommand: string;
    format: string;
    updateUrl: string;
    features: string[];
    configFiles: string[];
    dockerImages: { label: string; image: string }[];
  };
  serverTypes: string[];
  javaVersions: string[];
  variables: EggVariable[];
}

export const catalog = raw as unknown as Catalog;

export const EGG_JSON_URL =
  "https://github.com/PotenFYR-Studios/Minecraft-Eggs/raw/master/egg-minecraft-multi.json";
export const REPO_URL = "https://github.com/PotenFYR-Studios/Minecraft-Eggs";
export const NEST_URL = "https://nest.potenfyr.in";
export const SITE_URL = "https://minecraft-eggs.docs.potenfyr.in";
export const ORG_URL = "https://potenfyr.in";
export const DISCORD_URL = "https://discord.com/invite/zUaN2FPBec";

export const CANONICAL_PAGES = [
  { id: "home", path: "/", title: "Home" },
  { id: "docs", path: "/docs/", title: "Getting Started" },
  { id: "eggs", path: "/docs/eggs/", title: "Egg Catalog" },
  { id: "server-types", path: "/docs/server-types/", title: "Server Types" },
  { id: "examples", path: "/examples/", title: "Examples" },
  { id: "about", path: "/about/", title: "About" },
  { id: "license", path: "/license/", title: "License" },
] as const;

export type PageId = (typeof CANONICAL_PAGES)[number]["id"];

export function pageFromPath(pathname: string): PageId {
  // Accept the /docs/eggs.html twin form (same page as /docs/eggs/), then
  // drop trailing slashes so directory and extension URLs route identically.
  const p = (pathname.replace(/\/+$/, "") || "/").replace(/\.html$/, "");
  if (p === "/docs") return "docs";
  if (p === "/docs/eggs") return "eggs";
  if (p === "/docs/server-types") return "server-types";
  if (p === "/examples") return "examples";
  if (p === "/about") return "about";
  if (p === "/license") return "license";
  return "home";
}

/** Curated, real per-server-type facts (README engine matrix + egg variable docs). */
export interface ServerTypeInfo {
  id: string;
  label: string;
  category: "Plugins & Paper forks" | "Modded & Hybrid" | "Proxies" | "Bedrock & Mobile" | "Custom";
  versions: string;
  port: string;
  runtime: string;
  note: string;
  /** Variables to set for a minimal install (all real egg env var names). */
  minSettings: string[];
  extraVars?: string[];
}

export const SERVER_TYPES: ServerTypeInfo[] = [
  {
    id: "vanilla", label: "Vanilla", category: "Plugins & Paper forks",
    versions: "Alpha – 26.x + snapshots", port: "25565", runtime: "Auto Java 8 – 26",
    note: "Official Mojang server jar straight from the version manifest. Set MINECRAFT_VERSION to latest-snapshot for snapshots.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"],
  },
  {
    id: "paper", label: "Paper", category: "Plugins & Paper forks",
    versions: "1.7 – 26.x · all builds", port: "25565", runtime: "Auto Java 8 – 26",
    note: "High-performance server with the rich Paper plugin API. Pin an exact build with BUILD_NUMBER.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["BUILD_NUMBER"],
  },
  {
    id: "purpur", label: "Purpur", category: "Plugins & Paper forks",
    versions: "1.14 – 26.x · all builds", port: "25565", runtime: "Auto Java 8 – 26",
    note: "Feature-packed Paper fork with configurable gameplay mechanics. Build pinning via BUILD_NUMBER.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["BUILD_NUMBER"],
  },
  {
    id: "folia", label: "Folia", category: "Plugins & Paper forks",
    versions: "1.19 – 26.x · all builds", port: "25565", runtime: "Auto Java 17 – 26",
    note: "Regionised multi-threaded tick loop from PaperMC upstream, for very high player counts.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["BUILD_NUMBER"],
  },
  {
    id: "spigot", label: "Spigot", category: "Plugins & Paper forks",
    versions: "1.8 – 26.x", port: "25565", runtime: "Auto Java 8 – 26",
    note: "Classic Bukkit/Spigot runtime; BuildTools compilation runs inside the container automatically.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"],
  },
  {
    id: "fabric", label: "Fabric", category: "Modded & Hybrid",
    versions: "1.14 – 26.x · all loaders", port: "25565", runtime: "Auto Java 8 – 26",
    note: "Ultra-lightweight modular mod loader installed from Fabric meta. Loader version is pinnable.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["LOADER_VERSION"],
  },
  {
    id: "quilt", label: "Quilt", category: "Modded & Hybrid",
    versions: "1.14 – 26.x · all loaders", port: "25565", runtime: "Auto Java 8 – 26",
    note: "Community-driven open mod loader with backward compatibility for Fabric mods.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["LOADER_VERSION"],
  },
  {
    id: "forge", label: "Forge", category: "Modded & Hybrid",
    versions: "1.1 – 26.x · all loaders", port: "25565", runtime: "Auto Java 8 – 26",
    note: "Classic mod loader. Java 8 is selected automatically for 1.12.2 / 1.7.10; 1.17+ launches through a generated @unix_args.txt.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["LOADER_VERSION"],
  },
  {
    id: "neoforge", label: "NeoForge", category: "Modded & Hybrid",
    versions: "1.20.1 – 26.x · all loaders", port: "25565", runtime: "Auto Java 17 – 26",
    note: "Modern Forge fork. The installer runs the official installer and LOADER_VERSION accepts a full NeoForge build (e.g. 21.1.148).",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["LOADER_VERSION"],
  },
  {
    id: "mohist", label: "Mohist", category: "Modded & Hybrid",
    versions: "1.7.10 · 1.12.2 · 1.16.5 · 1.20.1", port: "25565", runtime: "Auto Java 8 – 17",
    note: "Forge + Bukkit hybrid: run Forge mods and Bukkit/Spigot plugins on the same server.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["BUILD_NUMBER"],
  },
  {
    id: "magma", label: "Magma", category: "Modded & Hybrid",
    versions: "1.12.2 · 1.16.5 · 1.20.1", port: "25565", runtime: "Auto Java 8 – 17",
    note: "Open-source Forge & Spigot hybrid server jar.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["BUILD_NUMBER"],
  },
  {
    id: "velocity", label: "Velocity", category: "Proxies",
    versions: "1.x – 4.x · all builds", port: "25577", runtime: "Java 21",
    note: "Next-generation proxy. velocity.toml is created automatically and its bind address is patched to the panel port; stop is translated to end.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["BUILD_NUMBER"],
  },
  {
    id: "bungeecord", label: "BungeeCord", category: "Proxies",
    versions: "Newest upstream", port: "25577", runtime: "Java 21",
    note: "Classic proxy connecting multiple backends. config.yml listeners are bound to the allocated port; stop is translated to end.",
    minSettings: ["SERVER_TYPE"],
  },
  {
    id: "waterfall", label: "Waterfall", category: "Proxies",
    versions: "1.7 – 1.20 · all builds", port: "25577", runtime: "Java 21",
    note: "PaperMC's upgraded BungeeCord fork with improved networking and stability.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"], extraVars: ["BUILD_NUMBER"],
  },
  {
    id: "bedrock", label: "Bedrock (BDS)", category: "Bedrock & Mobile",
    versions: "Every official release", port: "19132", runtime: "Native (no Java)",
    note: "Official Mojang Bedrock Dedicated Server: runs the native binary directly, no Java involved.",
    minSettings: ["SERVER_TYPE", "MINECRAFT_VERSION"],
  },
  {
    id: "nukkit", label: "Nukkit", category: "Bedrock & Mobile",
    versions: "Newest upstream", port: "19132", runtime: "Java 21",
    note: "High-throughput Java implementation of Minecraft: Bedrock Edition.",
    minSettings: ["SERVER_TYPE"],
  },
  {
    id: "pocketmine", label: "PocketMine-MP", category: "Bedrock & Mobile",
    versions: "Newest upstream", port: "19132", runtime: "PHP 8.x",
    note: "High-performance Bedrock server written in PHP with a rich plugin ecosystem.",
    minSettings: ["SERVER_TYPE"],
  },
  {
    id: "github", label: "GitHub Releases", category: "Custom",
    versions: "Any release or tag", port: "25565", runtime: "Auto",
    note: "Install a server jar straight from any GitHub repo. Release assets (.jar/.zip) are preferred; repos without releases are cloned as source.",
    minSettings: ["SERVER_TYPE", "GITHUB_REPO"], extraVars: ["GITHUB_TAG", "GITHUB_ASSET", "GITHUB_TOKEN"],
  },
  {
    id: "custom", label: "Custom Engine", category: "Custom",
    versions: "Bring your own jar / script", port: "Configurable", runtime: "Any",
    note: "Executes CUSTOM_COMMAND, or run.custom.sh if you provide one alongside your files.",
    minSettings: ["SERVER_TYPE", "CUSTOM_COMMAND"],
  },
];

/** Java auto-selection map (from JAVA_VERSION / README Java guide, real egg behavior). */
export const JAVA_MAP = [
  { mc: "26.x and newer", java: "Java 26", note: "Future-proofed for the newest releases" },
  { mc: "1.20.5 – 1.21.x", java: "Java 21", note: "Standard LTS runtime for modern Minecraft" },
  { mc: "1.17 – 1.20.4", java: "Java 17", note: "Caves & Cliffs through Trails & Tales" },
  { mc: "1.16.5 and older", java: "Java 8", note: "First-class legacy modpack support (1.12.2 / 1.7.10)" },
  { mc: "Proxies / Nukkit", java: "Java 21", note: "Velocity, BungeeCord, Waterfall, Nukkit" },
  { mc: "Bedrock / PocketMine", java: "Native / PHP", note: "BDS is a native binary; PocketMine runs on PHP 8.x" },
];

export const GROUP_ORDER = [
  "Server Selection",
  "GitHub Installs",
  "Java & Performance",
  "server.properties",
  "Content & Maintenance",
  "Console & Panel",
  "Custom Engine",
] as const;

export function varsByGroup(group: string): EggVariable[] {
  return catalog.variables.filter((v) => v.group === group);
}
