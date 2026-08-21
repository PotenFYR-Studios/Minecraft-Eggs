# Multi Minecraft - the universal Minecraft egg for Pterodactyl

> **One egg. Every Minecraft server. Every version.**
> Installs, updates and runs **18 different server software families** - Java
> and Bedrock - across **every version ever released** (1.0 → 26.x), including
> snapshots, deprecated versions and future releases.

```
.        :    ::: :::.    :::. .,::::::     .,-:::::   :::::::..      ::;.      .-:::::' ::::::::::::      .        :     ...    :::  :::      :::::::::::: :::      .,::::::     .,-:::::/     .,-:::::/  
;;,.    ;;;   ;;; `;;;;,  `;;; ;;;;''''   ,;;;'````'   ;;;;``;;;;     ;;`;;     ;;;''''  ;;;;;;;;''''      ;;,.    ;;;    ;;     ;;;  ;;;      ;;;;;;;;'''' ;;;      ;;;;''''   ,;;-'````'    ,;;-'````'   
[[[[, ,[[[[,  [[[   [[[[[. `[[  [[cccc    [[[           [[[,/[[['    '[[ '[[,   [[[,,==       [[           [[[[, ,[[[[,  [['     [[[  [[[           [[      [[[       [[cccc    [[[   [[[[[[/ [[[   [[[[[[/
$$$$$$$$"$$$  $$$   $$$ "Y$c$$  $$""""    $$$           $$$$$$c     c$$$cc$$$c  `$$$"``       $$           $$$$$$$$"$$$  $$      $$$  $$'           $$      $$$ cccc  $$""""    "$$c.    "$$  "$$c.    "$$ 
888 Y88" 888o 888   888    Y88  888oo,__  `88bo,__,o,   888b "88bo,  888   888,  888          88,          888 Y88" 888o 88    .d888 o88oo,.__      88,     888       888oo,__   `Y8bo,,,o88o  `Y8bo,,,o88o
MMM  M'  "MMM MMM   MMM     YM  """"YUMMM   "YUMMMMMP"  MMMM   "W"   YMM   ""`   "MM,         MMM          MMM  M'  "MMM  "YmmMMMM"" """"YUMMM      MMM     MMM       """"YUMMM    `'YMUP"YMM    `'YMUP"YMM
                                                                                                                                                                                   - By PotenFYR Studios
```

---

## Table of contents

1. [Features](#features)
2. [Supported server types](#supported-server-types)
3. [Repository layout](#repository-layout)
4. [Setup](#setup)
5. [Docker images (GHCR)](#docker-images-ghcr)
6. [How it works](#how-it-works)
7. [Egg variables](#egg-variables)
8. [Examples](#examples)
9. [User guide](#user-guide)
10. [Administrator guide](#administrator-guide)
11. [Security](#security)
12. [Performance & memory](#performance--memory)
13. [Storage efficiency](#storage-efficiency)
14. [Troubleshooting](#troubleshooting)
15. [License](#license)

---

## Features

| Feature | Details |
|---|---|
| **Universal** | One egg + one Docker image runs Vanilla, Paper, Spigot, Purpur, Folia, Forge, NeoForge, Fabric, Quilt, Mohist, Magma, BungeeCord, Velocity, Waterfall, Bedrock, Nukkit, PocketMine-MP, GitHub releases and custom jars |
| **Every version** | Full version history per project (Mojang manifest covers 1.0 → 26.x); `latest`, pinned versions, and vanilla `latest-snapshot` |
| **Auto-Java & Custom JVMs** | The image ships **Java 8, 11, 17, 21, 25 and 26** with dynamic on-demand installation for future (27+), snapshot/EA, beta, alpha, obsolete, and **custom Java runtimes** (GraalVM, Corretto, Zulu, Semeru/OpenJ9, or any direct URL / local `./java` folder) |
| **Interactive first run** | If a required setting is missing/invalid, the console **asks the user** and saves the answer in `.multi-mc.conf` for every later start |
| **Performance tuned** | Aikar's G1GC flags by default; `GC_TYPE` (auto/g1gc/zgc/parallel) and full `JAVA_FLAGS` override |
| **One stop command** | `stop` works for every type - proxies (BungeeCord/Waterfall/Velocity) get it translated to `end` automatically |
| **Panel-managed ports** | `server.properties`, BungeeCord/Waterfall `config.yml` and `velocity.toml` are patched with the allocation port automatically |
| **Customizable** | 28 egg variables (see [table](#egg-variables)); plus a `run.custom.sh` escape hatch for anything exotic |
| **GitHub installs** | Install any server jar published as a GitHub release (`owner/repo`, tag, asset filter) |
| **Version explorer** | `SHOW_VERSIONS=1` prints every available version of a project without touching the server |
| **Plugins & worlds** | `EXTRA_URLS` installs plugins/configs/mods at install; `WORLD_URL` imports an existing world |
| **Updates** | `AUTO_UPDATE` (reinstall policy) + `KEEP_BACKUP` (keep previous jar) |
| **Storage safe** | Atomic downloads, install artifacts cleaned, old jars removed by default |
| **Multi-arch** | Images published for `linux/amd64` and `linux/arm64` |
| **Future-proof** | Year-based versioning (26.1, 26.2, …) supported; new Java releases only require a new image tag |

---

## Supported server types

| `SERVER_TYPE` | What it runs | Versions | API used |
|---|---|---|---|
| `vanilla` | Official Mojang server | **1.0 → 26.x**, snapshots (`latest-snapshot`) | piston-meta.mojang.com |
| `paper` | High-performance Paper fork | **1.7 → 26.x** (all builds) | fill.papermc.io v3 |
| `spigot` | The classic Spigot (built with BuildTools) | **1.8 → 26.x** | hub.spigotmc.org |
| `purpur` | Feature-rich Purpur fork | **1.14.1 → 26.2** (all builds) | api.purpurmc.org |
| `folia` | Regionalized multi-threaded fork | **1.19 → 26.x** (all builds) | fill.papermc.io v3 |
| `forge` | The original mod loader | **1.1 → 26.2** (every loader) | files.minecraftforge.net + maven |
| `neoforge` | Forge's community successor | **1.20.1 → 26.1.2** (every loader) | maven.neoforged.net |
| `fabric` | Lightweight mod loader | **1.14 → 26.x** (every loader) | meta.fabricmc.net |
| `quilt` | Fabric fork with community focus | **1.14 → 26.x** (every loader) | meta.quiltmc.org |
| `mohist` | Forge + Bukkit hybrid | 1.7.10, 1.12.2, 1.16.5, 1.20.1 | mohistmc.com |
| `magma` | Forge + Bukkit hybrid | 1.12.2, 1.16.5, 1.20.1 | GitHub releases |
| `bungeecord` | Classic proxy | always latest | ci.md-5.net |
| `velocity` | Modern proxy | **1.0 → 4.0** (all builds) | fill.papermc.io v3 |
| `waterfall` | BungeeCord fork (Paper team) | **1.7 → latest** (all builds) | fill.papermc.io v3 |
| `bedrock` | Official Bedrock Dedicated Server | all official releases | minecraft.net |
| `nukkit` | Bedrock Java server | always latest | ci.opencollab.dev |
| `pocketmine` | Bedrock PHP server | always latest | GitHub releases |
| `github` | **Any** server software published as a GitHub release | any tag / latest | api.github.com |
| `custom` | Your own jar + command | anything | - |

**Deprecated / legacy versions** work too: e.g. `1.7.10`, `1.12.2`, `1.16.5`
modpacks are served by Vanilla/Forge/Fabric/Mohist/Magma and automatically
receive **Java 8**. Snapshots: set `MINECRAFT_VERSION=latest-snapshot`
(vanilla only - Paper & friends publish stable builds only).

---

## Repository layout

```
Minecraft-Eggs/
├── egg-minecraft-multi.json   ← the egg (import this into Pterodactyl)
├── Dockerfile                 ← universal runtime image (multi-JDK + tools)
├── entrypoint.sh              ← image entrypoint (conf load, Java auto-select, banner)
├── run.sh                     ← universal launcher (dispatch, prompts, GC tuning)
├── install.sh                 ← universal install script (embedded in the egg too)
├── install-java.sh            ← Docker build helper (Adoptium JRE downloader)
├── .github/workflows/docker-image.yml  ← CI: builds & publishes the GHCR image
└── README.md
```

---

## Setup

### 1. Import the egg

1. Download [`egg-minecraft-multi.json`](egg-minecraft-multi.json)
2. Go to **Admin → Nests → Minecraft** (create the nest first if needed)
3. Click **Import Egg**, upload the file, **Save**

### 2. Create a server

| Field | Value |
|---|---|
| **Egg** | `Multi Minecraft` |
| **Docker image** | `Universal (Auto Java)` (recommended) |
| **Ports** | `25565` (Java), `19132` (Bedrock / Nukkit / PocketMine), `25577` (proxies) |
| **Memory** | 1 GB minimum (2-4 GB recommended for Paper+ / modded) |

### 3. Configure variables

Set **Server Type** and **Minecraft Version** (see [examples](#examples)),
then press **Install**. Accept the **EULA** in the panel when starting.

### 4. Start

The console shows a banner, auto-selects Java, and runs the server. If
anything is missing, it **asks you in the console** and remembers the answer.

> **No image build required** - images are pre-built on GitHub Container
> Registry (see below). If you fork the repo, the CI workflow builds them
> for you automatically on every push to `main`.

---

## Docker images (GHCR)

The image is built and published by GitHub Actions from this repository:

| Tag | Contents |
|---|---|
| `ghcr.io/potenfyr-studios/minecraft-eggs:latest` | **Universal** - Java 8, 11, 17, 21, 25, 26 + dynamic on-demand installer + PHP 8.1 (PocketMine) + native libs (Bedrock) + jq/curl/unzip/git-ready tools |
| `...:java26` / `:java25` / `:java21` / `:java17` / `:java11` / `:java8` | **Slim** single-JVM variants (smallest footprint) |
| `...:java<X>-<sha>` | Per-commit builds (rolling) |

Architectures: `linux/amd64` and `linux/arm64`.

Build it yourself:

```bash
# universal
docker build -t minecraft-eggs:latest .

# slim variant
docker build --build-arg JAVA_VERSION=21 -t minecraft-eggs:java21 .
```

Image contents (deliberately minimal):

- **JREs only** - servers never need a JDK at runtime (Spigot's BuildTools
  downloads a temporary JDK at install time, so the image stays lean)
- **PHP 8.1** with the extensions PocketMine-MP requires
- **libcurl4 / libssl3** for the Bedrock native binary
- `curl wget jq unzip xz-utils ca-certificates tzdata iproute2 locales`
- **No** git, compilers or build tooling (added on demand at install time)

---

## How it works

```
Pterodactyl panel ──► Wings (node)
                          │
                          ▼
              ┌───────────────────────────┐
              │  ghcr.io/potenfyr-studios/ │
              │  minecraft-eggs:latest     │
              └───────────────────────────┘
                          │ 1. entrypoint.sh
                          │    • loads .multi-mc.conf (persisted settings)
                          │    • auto-selects / installs Java (8-26+, snapshots, future)
                          │    • prints banner + runs the STARTUP command
                          ▼
                       run.sh (the launcher)
                          │ 2. validates SERVER_TYPE (+ console wizard)
                          │ 3. dispatches:
                          │    bedrock    → ./bedrock_server
                          │    pocketmine → php PocketMine-MP.phar --no-wizard
                          │    proxies    → java … -jar …  ("stop"→"end")
                          │    java types → java [Aikar G1GC] -jar server.jar
                          │                 (+ @unix_args.txt for Forge/NeoForge)
                          ▼
                       Minecraft server process
```

**Installation** runs in a separate one-shot container (the same image, as
root) with the server directory mounted at `/mnt/server`. The script
resolves versions against the official APIs, downloads/installs the server,
writes sane default configs, and exits. Wings then boots the runtime
container with your files in `/home/container`.

**The panel→container contract:**

- Wings injects every egg variable as an **environment variable**
- The egg's `STARTUP` (`bash run.sh`) is executed by the image entrypoint
  (same contract as the official `yolks` images)
- `server.properties`, `config.yml` and `velocity.toml` are patched with the
  **allocation port** before every boot (panel config parsers)
- The panel waits for one of the `done` patterns (`Done (`, `)! For help,
  type "help"`, `Listening on`, `Server started.`, `Default game type`)
- `stop` is sent on shutdown - translated to `end` for proxies, so one stop
  command works for **every** server type

---

## Egg variables

All 21 variables. `🔒` = not user-editable (admin-only), `👤` = users can change it.

| Variable | Default | 🔒/👤 | Description |
|---|---|---|---|
| `SERVER_TYPE` | `vanilla` | 👤 | Software to install (see table above) |
| `MINECRAFT_VERSION` | `latest` | 👤 | Version (also `latest-snapshot`; for Velocity/Waterfall the software version; for Bedrock the bedrock version) |
| `BUILD_NUMBER` | `latest` | 👤 | Build for Paper/Folia/Purpur/Velocity/Waterfall/Mohist |
| `LOADER_VERSION` | `latest` | 👤 | Loader for Forge/NeoForge/Fabric/Quilt (NeoForge accepts full versions like `21.1.148`) |
| `GITHUB_REPO` | *(empty)* | 👤 | `owner/repo` when `SERVER_TYPE=github` |
| `GITHUB_TAG` | `latest` | 👤 | Release tag for GitHub installs |
| `GITHUB_ASSET` | *(empty)* | 👤 | Asset substring filter (empty = auto-pick a `.jar`) |
| `SERVER_JARFILE` | `server.jar` | 👤 | Jar name (ignored for Forge/NeoForge 1.17+) |
| `JAVA_VERSION` | *(empty)* | 👤 | Force a JVM (`8/11/17/21/25/26`, `graalvm-21`, `corretto-21`, `zulu-17`, `semeru-21`, `custom`, `local`, or direct URL `https://...`); empty = auto |
| `JAVA_URL` | *(empty)* | 👤 | Direct URL to a custom Java archive (`.tar.gz` or `.zip`) to download and use automatically |
| `JAVA_FLAGS` | Aikar's tuned G1GC flags | 👤 | JVM arguments - default is the performance-optimized set; clear it to let `GC_TYPE` choose, or set a single space to disable |
| `GC_TYPE` | `auto` | 👤 | `auto` (Aikar G1GC) / `zgc` / `parallel` - used only when `JAVA_FLAGS` is empty |
| `EXTRA_ARGS` | *(empty)* | 👤 | Arguments appended **after** the jar, e.g. `--nogui` |
| `MOTD` | `A Minecraft Server` | 👤 | Written to a fresh `server.properties` |
| `MAX_PLAYERS` | `20` | 👤 | Written to a fresh `server.properties` |
| `ONLINE_MODE` | `true` | 👤 | Written to a fresh `server.properties` |
| `VIEW_DISTANCE` | `10` | 👤 | Written to a fresh `server.properties` |
| `DIFFICULTY` | *(empty)* | 👤 | `peaceful/easy/normal/hard` - written to a fresh `server.properties` |
| `GAMEMODE` | *(empty)* | 👤 | `survival/creative/adventure/spectator` - written to a fresh `server.properties` |
| `PVP` | `true` | 👤 | Written to a fresh `server.properties` |
| `RCON_PASSWORD` | *(empty)* | 👤 | Enables RCON with this password in a fresh `server.properties` (plain text) |
| `EXTRA_URLS` | *(empty)* | 🔒 | Extra files downloaded at install - one `[subdir/]|url` per line (plugins, configs, mods) |
| `WORLD_URL` | *(empty)* | 🔒 | World zip imported into `./world` during install |
| `DEBUG` | `0` | 🔒 | `1` = `bash -x` install + environment dump at start |
| `AUTO_UPDATE` | `1` | 👤 | `1` = always (re)install on reinstall; `0` = skip if files exist |
| `KEEP_BACKUP` | `0` | 👤 | `1` = keep previous jar as `<name>.old` |
| `SHOW_VERSIONS` | `0` | 🔒 | `1` + Reinstall prints all available versions, changes nothing |
| `DL_URL` | *(empty)* | 🔒 | Direct URL override (bypasses project logic) |
| `CUSTOM_COMMAND` | `java -Xmx1024M -jar server.jar` | 👤 | Exact command when `SERVER_TYPE=custom` |

**Persisted settings (`.multi-mc.conf`):** answers given in the console wizard
are saved in a `KEY=VALUE` file in the server directory. The file is
`chmod 600`, parsed safely (never evaluated), and only fills variables the
panel did **not** provide - panel settings always win. Delete the file to
reset to a fresh first-run wizard.

---

## Examples

### Vanilla 1.21.4
```
SERVER_TYPE      = vanilla
MINECRAFT_VERSION= 1.21.4
```
Java 21 is auto-selected. Snapshots: `MINECRAFT_VERSION=latest-snapshot`.

### Paper + plugins + a prebuilt world
```
SERVER_TYPE      = vanilla|paper
MINECRAFT_VERSION= latest        # resolves to 26.2
BUILD_NUMBER     = latest
EXTRA_URLS       = plugins|https://download.example.com/ViaVersion.jar
                   plugins|https://download.example.com/Geyser.jar
WORLD_URL        = https://www.planetminecraft.com/.../world.zip
```
`EXTRA_URLS` places each file into `plugins/` (or any subdirectory), and
`WORLD_URL` unpacks the world into `./world` - a fully preconfigured server
in one install.

### Install software that only exists on GitHub (e.g. Arclight, Feather, …)
```
SERVER_TYPE      = github
GITHUB_REPO      = IzzelAliz/Arclight
GITHUB_TAG       = latest        # or a tag like 1.21.4
GITHUB_ASSET     = server        # optional substring filter
```
Picks the first `.jar` asset (or the first asset) of the release.

### Bring your own jar
```
SERVER_TYPE      = custom
CUSTOM_COMMAND   = java -Xmx2048M -jar server.jar
```
Upload your jar (or set `DL_URL`) and run whatever you want.

### Use a Custom Java Runtime (GraalVM, Corretto, Zulu, or direct URL)
You can run your server with any JVM vendor or custom build:

1. **Vendor runtime**:
   ```
   JAVA_VERSION = graalvm-21   # or corretto-21, zulu-17, semeru-21, etc.
   ```
2. **Direct archive URL** (tar.gz or zip):
   ```
   JAVA_URL = https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
   ```
3. **Local custom runtime**:
   Place a Java runtime into a `./java` or `./jre` folder in your server files, or set `JAVA_VERSION=custom`.

### Anything not covered? (ultimate escape hatch)
Drop a `run.custom.sh` into the server directory - it is executed instead of
the built-in launcher (all variables remain available).

---

## Crossplay & plugin guide (Geyser, ViaVersion, …)

Java and Bedrock players can play together on one server with **Geyser**,
and clients of any Minecraft version can join with **ViaVersion**:

```
SERVER_TYPE      = paper
MINECRAFT_VERSION= 1.21.4
EXTRA_URLS       = plugins|https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/geyser
                   plugins|https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/floodgate
                   plugins|https://hangar.papermc.io/api/v1/projects/ViaVersion/versions/latest/PAPI-Download
```
- **Geyser** = Bedrock players join your Java server on the Bedrock port
  (allocate `19132` as a second port)
- **Floodgate** = lets Bedrock players join without a paid Java account
- **ViaVersion / ViaBackwards** = older/newer Java clients connect to any
  version - pick the right version for your server version from the
  project's download page and use `EXTRA_URLS` to install it
- Any other plugin/mod/resource-pack hosted at a direct URL works the same
  way; software only published as GitHub releases can be installed as the
  server itself via `SERVER_TYPE=github`

> **Pufferfish / Sponge / Arclight / Feather / NanoLimbo & friends:** these
> projects have no stable public download API - install their jars with
> `SERVER_TYPE=github` (GitHub releases) or `DL_URL` (direct link).

---

## User guide

### First start
1. **Install** the server (watch the console for a summary showing the
   resolved type, version, Java and jar)
2. **Start** it - if the panel asks you to accept the **EULA**, accept it
3. If a variable is missing/invalid, the console **asks you** - answer and
   it is remembered (`.multi-mc.conf`). Prompts time out after 120 seconds
   and fall back to the default, so a broken config never hangs a start.

### Updating the server
Change `MINECRAFT_VERSION` / `BUILD_NUMBER` / `LOADER_VERSION` and press
**Reinstall**. With `AUTO_UPDATE=1` the software is replaced (old jar kept
only if `KEEP_BACKUP=1`). World data is **never** touched.

### Finding versions
Set `SHOW_VERSIONS=1` and press **Reinstall** - the console lists every
available version of the project, then stops without changing anything.

### Importing a world
Set `WORLD_URL` to a world zip (Planet Minecraft, a previous host, a backup)
and press **Reinstall** - it lands in `./world` automatically (single-folder
archives are unwrapped). Worlds are only imported on **fresh** installs; a
`Reinstall` with an existing `world/` folder does not touch it.

### Installing plugins, mods and resource packs
`EXTRA_URLS` downloads files during installation - one `[subdir/]|url` per
line. Examples: `plugins|https://…/plugin.jar`, `mods|https://…/mod.jar`,
`config|https://…/config.yml`. Zip files are extracted in place.

### Debugging
Set `DEBUG=1` (admin-only variable) to run the install with `bash -x` and to
print a full resolved-environment dump at server start.

### Ports
- Java servers: allocate `25565` (or any port - `server.properties` is patched)
- Bedrock/Nukkit/PocketMine: `19132`
- BungeeCord/Waterfall/Velocity: `25577`

### Stopping
Just press Stop - `stop` is sent and translated to `end` for proxies.

### Performance
- **Default `JAVA_FLAGS` = Aikar's tuned G1GC flags** - the well-known
  performance set (bounded pause targets, fast young-gen, pre-touched heap)
- Every flag in the default set is compatible with **Java 8 → 26+**, so old
  and new servers get the same tuning without risk
- 8 GB+ RAM: clear `JAVA_FLAGS` and set `GC_TYPE=zgc` (Java 21+) for the
  lowest-latency pauses
- Small servers: keep the defaults; you can disable tuning by setting
  `JAVA_FLAGS` to a single space
- Server arguments (not JVM flags) go in `EXTRA_ARGS`, e.g. `--nogui`
- The console prints which flags are active and where they came from
  (`JVM flags source: JAVA_FLAGS` or `GC_TYPE=…`)

---

## Administrator guide

### Building & hosting the image on GHCR
The workflow [`.github/workflows/docker-image.yml`](.github/workflows/docker-image.yml):
- builds a **matrix** (`java8 … java26` + `all`) for `amd64` + `arm64`
- pushes `latest`, `java<X>`, and per-commit tags to
  `ghcr.io/potenfyr-studios/minecraft-eggs`
- runs on push to `main`, on `v*` tags, on PRs (build-only) and manually

No extra secrets are needed (`GITHUB_TOKEN` is enough for GHCR).

### Egg updates
The egg's `meta.update_url` points at this repository - the panel can fetch
new egg versions automatically.

### Auto-updating server software
`AUTO_UPDATE=1` (default) means every **Reinstall** refreshes the software.
Combined with a panel **Schedule** that reinstalls periodically, servers can
self-update. For stability pin exact versions instead.

### Offering it to customers
- Lock `JAVA_FLAGS`, `DL_URL`, `EXTRA_URLS`, `WORLD_URL`, `DEBUG`,
  `SHOW_VERSIONS` (already admin-only or hidden)
- Let users edit `SERVER_TYPE`, version, MOTD/players/difficulty etc.
- RCON for gamepads: set `RCON_PASSWORD` on a fresh install (enables
  `enable-rcon` + password in `server.properties`)
- `PROPS` note: `MOTD`/`MAX_PLAYERS`/`ONLINE_MODE`/`VIEW_DISTANCE`/`DIFFICULTY`/
  `GAMEMODE`/`PVP`/`RCON_PASSWORD` are applied only to a **freshly generated**
  `server.properties` (they never clobber user edits)

---

## Security

- Scripts run with `set -uo pipefail`; every external value is quoted
- `.multi-mc.conf` is **parsed, never sourced** - values cannot execute code
- The runtime container runs as the panel's unprivileged user (Wings handles
  UID/GID); only the **install** container runs as root (required for apt/git)
- Install downloads are **atomic** (temp file → move) and cleaned on failure
- `DL_URL`, `GITHUB_*` and `CUSTOM_COMMAND` are documented as powerful -
  restrict them on shared hosting
- No secrets, tokens or API keys are used anywhere in this project

---

## Performance & memory

| Concern | Answer |
|---|---|
| GC | Aikar G1GC by default; `GC_TYPE=zgc` for 8 GB+; `JAVA_FLAGS` to override |
| Java auto-selection | The correct JVM for the version is chosen automatically |
| Image weight | JREs only (no JDK); slim single-Java tags for minimal footprint |
| RAM | `-Xmx` = allocated memory; Aikar flags include `-XX:+AlwaysPreTouch` for consistent latency |
| Old versions | Legacy servers get Java 8 - no more "unsupported class file version" |

---

## Storage efficiency

- Old jars are **deleted** on update unless `KEEP_BACKUP=1`
- Install artifacts (installers, zips, BuildTools, temp JDKs) are removed
- Templates are generated with `printf` - no bulky config blobs
- Failed downloads never leave partial files behind

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `UnsupportedClassVersionError` / wrong Java | Leave `JAVA_VERSION` empty (auto) or set it explicitly; pick `Universal (Auto Java)` image |
| Version not found | The install falls back to `latest` with a warning - set `SHOW_VERSIONS=1` to list valid versions |
| Server binds wrong port | Reinstall once so the config template exists, then start (the panel patches the port on every boot) |
| Spigot build fails | BuildTools needs memory - raise the server's allocation to 2 GB+ during install |
| Bedrock won't start on ARM | Mojang ships x86_64 only - use an x86_64 node |
| Forge 1.17+ "no main manifest" | Should not happen - the egg launches via `@unix_args.txt`; delete `unix_args.txt` and reinstall if it's stale |
| Console prompts on every start | Delete `.multi-mc.conf` in the server files and answer correctly |
| Want my own flags | Set `JAVA_FLAGS` (wins over `GC_TYPE`); add server args to `EXTRA_ARGS` |
| Proxy won't stop | It does - `stop` is translated to `end`; make sure you wait a few seconds |

---

## License

MIT - see [LICENSE](LICENSE). Fork it, host it, sell it - just keep the
credits. Made with ❤️ by **PotenFYR Studios**.