# Multi Minecraft - the universal Minecraft egg for Pterodactyl & Pelican

```
█▄▀█▄ ▄█▄  ▄▄▄ █▄▀█▄   ▄▄▄▄  ▄▄▄▄ █▄▄▀▀▄   ▄▀▀▄   ▄▀▄▄ █▄▄▀▀▄▄      █▄▀█▄ ▄█▄  █▄▄  ▄▄█ ▄▄    █▄▄▀▀▄▄ ▄▄▄  ▄▄▄▄  ▄▄▄▄   ▄▄▄▄ 
▓█  █▄▌ █▄  ▀█ ▓█  █▄ ▄█ ▀▀ ▄█ ▀▀  ██  █▄ ▓█  █▄ ▄█      █▄         ▓█  █▄▌ █▄  ██  ██  ██      █▄     ▀█ ▄█ ▀▀ ▄█ ▀▀  ▄█ ▀▀ 
██  ██  ██ ▄█▄ ██  ██ ██    ██     ██  █▀ ██  ██ ██      ██         ██  ██  ██  ██  ██  ██      ██    ▄█▄ ██    ██     ██    
██  ██  ██  ██ ██  ██ ▓▓▄▄  ▓▓     ██▄▄▀  ██▀▀██ ████    ▒▒         ██  ██  ██  ██  ▒▒  ▓▓      ▒▒     ██ ▓▓▄▄  ▓▓▐▀██ ▓▓▐▀██
▓▓  ▓▓  ▓▓  ▓▓ ▓▓  ▓▓ ▓▓    ▓▓     ▓▓  ▄▄ ▓▓  ▓▓ ▓▓      ▓▓         ▓▓  ▓▓  ▓▓  ▓▓  ▓▓  ▓▓      ▓▓     ▓▓ ▓▓    ▓▓  ▄▄ ▓▓  ▄▄
██  ▀█  ██ ▄██ ██  ██ ▀█    ▀█     ██  ██ ██  ██ ██      ██▄        ██  ▀█  ██  ▀█  █▀  ▀█      ██▄   ▄██ ▀█    ▀█  ▓▓ ▀█  ▓▓
▀▀      █▀  ▀▀ ▀▀  ██  ▀▀▀   ▀▀▀  ▄▀▀  ▀▀ ▀▀  ██ ▀▀      ▀▀█        ▀▀      █▀   ▀▄▄▀    ▀▀▀    ▀▀█    ▀▀  ▀▀▀   ▀▀▀ ▀  ▀▀▀ ▀
                                                                                                           - By PotenFYR Studios
```

**One egg. One docker image. Every Minecraft server. Every version. Any panel.
Any architecture.**

Multi Minecraft installs and runs 19 families of Minecraft server software,
Java Edition and Bedrock, across every version ever released (Alpha to 26.x),
including snapshots, deprecated versions and future releases. You pick two
variables (`SERVER_TYPE` and `MINECRAFT_VERSION`); everything else is
automatic.

---

## Table of contents

**Getting started**

1. [Newbie quick start (5 minutes)](#newbie-quick-start-5-minutes)
2. [Requirements](#requirements)
3. [Supported server software](#supported-server-software)
4. [The console wizard](#the-console-wizard)

**Everyday use**

1. [Egg variable reference](#egg-variable-reference)
2. [Examples cookbook](#examples-cookbook)
3. [Updating servers safely](#updating-servers-safely)
   - [Safe type and version switching](#safe-type-and-version-switching)
4. [Java guide](#java-guide)
5. [Performance tuning](#performance-tuning)

**Reliability**

1. [Error logs and diagnostics](#error-logs-and-diagnostics)
2. [Troubleshooting matrix](#troubleshooting-matrix)

**Expert**

1. [How it works](#how-it-works)
2. [Architecture and host OS support](#architecture-and-host-os-support)
3. [Panel compatibility](#panel-compatibility)
4. [Administrator and production guide](#administrator-and-production-guide)
5. [Security model](#security-model)
6. [FAQ](#faq)
7. [Project layout](#project-layout)
8. [License and support](#license-and-support)

---

## Newbie quick start (5 minutes)

Never used Pterodactyl eggs before? Follow exactly these steps.

### Step 1: Download the egg

Download [`egg-minecraft-multi.json`](egg-minecraft-multi.json) to your computer.

### Step 2: Import it into your panel

1. Log in to your panel as an **administrator**.
2. Open **Admin Area -> Nests** (Pelican: **Admin -> Nests**).
3. If there is no Minecraft nest yet, create one named `Minecraft`.
4. Open the nest and click **Import Egg** (Pelican: **Upload Egg**).
5. Choose `egg-minecraft-multi.json` and save.

### Step 3: Create a server

1. Go to **Admin -> Servers -> Create New**.
2. Pick the owner user, the **Minecraft** nest and the **Multi Minecraft** egg.
3. For **Docker Image** select `Universal (Auto Java)` - this is the only image
   the egg needs.
4. Give the server **2048 MB memory** (4096+ for modpacks) and 5 GB+ disk.
5. Keep the default port allocation (`25565`).

### Step 4: Choose what to install

Open the server's **Startup** tab and set:

| Variable | Example |
|---|---|
| Server Type | `paper` |
| Minecraft Version | `latest` |

That is the entire configuration. Press **Install** and watch the console:
it downloads the server, writes safe default configs and prints a summary.

### Step 5: Start and play

Press **Start**, accept the Minecraft **EULA** checkbox when the panel offers
it, and players join on your node IP at port `25565`. Done!

> Stuck? The console tells you exactly what to do. If something is missing or
> misspelled, the server asks you right in the console, remembers your answer,
> and continues.

---

## Requirements

| Thing | Minimum | Recommended |
|---|---|---|
| Panel | Pterodactyl 1.x or Pelican 1.x | latest |
| Node (wings) OS | any Linux with Docker | any |
| CPU architecture | x86_64 or arm64 | x86_64 |
| Memory per server | 1024 MB | 2048-8192 MB |
| Disk per server | 2 GB | 10 GB+ |
| Network | outbound HTTPS to Mojang/PaperMC/vendor APIs | - |

---

## Supported server software

All of these install with their complete version history. Unknown versions
fall back to the latest release automatically, with a warning in console.

| `SERVER_TYPE` | Software | Versions | Source |
|---|---|---|---|
| `vanilla` | Official Mojang server | Alpha to 26.x + all snapshots | Mojang |
| `paper` | High performance server | 1.7 to 26.x, all builds | PaperMC |
| `spigot` | Classic plugin server | 1.8 to 26.x (BuildTools) | SpigotMC |
| `purpur` | Feature packed fork | 1.14 to 26.x, all builds | PurpurMC |
| `folia` | Multithreaded region fork | 1.19 to 26.x, all builds | PaperMC |
| `forge` | The original mod loader | 1.1 to 26.x, every loader | Forge maven |
| `neoforge` | Modern mod loader | 1.20.1+, every loader | NeoForge |
| `fabric` | Lightweight mod loader | 1.14+, every loader | FabricMC |
| `quilt` | Community mod loader | 1.14+, every loader | QuiltMC |
| `mohist` | Forge + Bukkit hybrid | 1.7.10 / 1.12.2 / 1.16.5 / 1.20.1 | MohistMC |
| `magma` | Forge + Bukkit hybrid | 1.12.2 / 1.16.5 / 1.20.1 | GitHub |
| `bungeecord` | Classic proxy | always latest | MD-5 Jenkins |
| `velocity` | Modern proxy | 1.x to 4.x, all builds | PaperMC |
| `waterfall` | Bungee fork by Paper team | 1.7+, all builds | PaperMC |
| `bedrock` | Bedrock Dedicated Server | every official release | Mojang |
| `nukkit` | Bedrock logic in Java | always latest | Cloudburst |
| `pocketmine` | Bedrock logic in PHP | always latest | PMMP |
| `github` | Any jar published on GitHub | any release/tag | GitHub API |
| `custom` | Bring your own files | anything | you |

On top of that: `DL_URL` accepts any direct download link, and a
`run.custom.sh` file lets you launch absolutely anything.

**Deprecated and legacy versions are first class citizens**: `1.7.10`,
`1.12.2`, `1.16.5` modpacks and old maps work out of the box and get the
correct Java runtime automatically.

---

## The console wizard

If the egg finds a required setting that is missing or invalid, it does not
fail silently. It asks you in the live console:

```
container@pterodactyl~ [warn] Server type 'banana' is not supported by this egg.
? Select a server type [default: vanilla, 120s timeout]: paper
container@pterodactyl~ Saved server type 'paper' in .multi-mc.conf (delete this file to reset)
```

How it behaves:

- Answers are saved to `.multi-mc.conf` inside the server directory, so future
  starts just work.
- Panel variables always win over saved answers.
- Prompts time out after 120 seconds and use the default: a broken config can
  never hang a startup forever.
- Delete `.multi-mc.conf` to run the wizard again from scratch.
- The file is plain `key=value`, parsed safely (never executed), `chmod 600`.

---

## Egg variable reference

28 variables total. `USER` = visible and editable by server owners in the
panel; `ADMIN` = hidden (set only by administrators).

### Choosing the software

| Variable | Default | Who | Description |
|---|---|---|---|
| `SERVER_TYPE` | `vanilla` | USER | Software to install (see supported table) |
| `MINECRAFT_VERSION` | `latest` | USER | Exact version or keyword: `latest`, `stable`, `release`, `ga`, `latest-snapshot`, `snapshot`, `alpha`, `beta`, `experimental`, `nightly`, `preview`, `dev` |
| `BUILD_NUMBER` | `latest` | USER | Pin a build for Paper/Folia/Purpur/Velocity/Waterfall/Mohist |
| `LOADER_VERSION` | `latest` | USER | Mod loader version for Forge/NeoForge/Fabric/Quilt |
| `GITHUB_REPO` | *(empty)* | USER | `owner/repo` when type is `github` |
| `GITHUB_TAG` | `latest` | USER | Release tag for GitHub installs |
| `GITHUB_ASSET` | *(empty)* | USER | Asset substring filter (empty = auto pick a jar) |
| `SERVER_JARFILE` | `server.jar` | USER | Jar filename (auto-handled for Forge/NeoForge 1.17+) |
| `CUSTOM_COMMAND` | `java -Xmx1024M -jar server.jar` | USER | Full command when type is `custom` |

### Java and performance

| Variable | Default | Who | Description |
|---|---|---|---|
| `JAVA_VERSION` | *(empty = auto)* | USER | Force a runtime: `8`, `11`, `17`, `21`, `25`, or anything installable on demand (`27`, `graalvm-21`, `corretto-21`, `semeru-21`, a tar.gz URL, `custom`). Auto mode picks per Minecraft version |
| `JAVA_FLAGS` | Aikar's tuned G1GC set | USER | Full JVM arguments override. Clear it to let `GC_TYPE` decide; a single space disables tuning |
| `GC_TYPE` | `auto` | USER | `auto` (Aikar G1GC), `zgc`, `parallel`, `g1gc` - used only when `JAVA_FLAGS` is empty |
| `EXTRA_ARGS` | *(empty)* | USER | Server arguments after the jar, e.g. `--nogui` |

### Fresh server.properties values

Applied only when the installer generates a brand new `server.properties`.
They never overwrite files you edited yourself.

| Variable | Default | Who |
|---|---|---|
| `MOTD` | `A Minecraft Server` | USER |
| `MAX_PLAYERS` | `20` | USER |
| `ONLINE_MODE` | `true` | USER |
| `VIEW_DISTANCE` | `10` | USER |
| `DIFFICULTY` | *(empty)* | USER |
| `GAMEMODE` | *(empty)* | USER |
| `PVP` | `true` | USER |
| `RCON_PASSWORD` | *(empty)* | USER (enables RCON when set) |

### Content, updates and maintenance

| Variable | Default | Who | Description |
|---|---|---|---|
| `AUTO_UPDATE` | `1` | USER | `1` = reinstall always refreshes software; `0` = skip if files exist |
| `KEEP_BACKUP` | `0` | USER | `1` = keep previous jar as `<name>.old` when updating |
| `WORLD_URL` | *(empty)* | ADMIN | World zip imported into `./world` during install |
| `EXTRA_URLS` | *(empty)* | ADMIN | Extra downloads at install, one `[subdir/]|url` per line |
| `SHOW_VERSIONS` | `0` | ADMIN | `1` + Reinstall lists all versions of the project, changes nothing |
| `DL_URL` | *(empty)* | ADMIN | Direct download URL that bypasses project logic |
| `DEBUG` | `0` | ADMIN | `1` = console-level tracing of installer and launcher |

### Stop behavior and console theme

| Variable | Default | Who | Description |
|---|---|---|---|
| `PANEL_STOP_WATCHER` | `auto` | USER | `auto`/`1` = the launcher watches console input for the panel stop command (`stop`, `^C`, `end`, ...), so Stop works on Wings-family daemons that deliver stop as console text (Feather Panel included). Non-stop console lines are forwarded to the server console, so in-game commands keep working. `0` = pass stdin straight to the server (yolk contract), signals still stop it |
| `CLI_THEME` | `prog` | USER | `prog` = PotenFYR agent theme (`</> multi-minecraft` prefixes, gradient banner, boot card); `classic` = yolk-style `[PotenFYR]` console |
| `CLI_BANNER_GRADIENT` | `auto` | USER | Banner gradient: `auto` (random per boot), `citrus`, `aurora`, `sunset`, `ocean`, `candy`, `spectrum`, `none` |

---

## Examples cookbook

### Vanilla 1.21.4
```
SERVER_TYPE       vanilla
MINECRAFT_VERSION 1.21.4
```
Snapshots: set `MINECRAFT_VERSION=latest-snapshot` (or `alpha`, `beta`).

### Paper with plugins and an imported world
```
SERVER_TYPE       paper
MINECRAFT_VERSION latest
EXTRA_URLS        plugins|https://example.com/ViaVersion.jar
                  plugins|https://example.com/Geyser.jar
WORLD_URL         https://maps.example.com/my-world.zip
```

### Legacy modpack (Forge 1.12.2)
```
SERVER_TYPE       forge
MINECRAFT_VERSION 1.12.2
LOADER_VERSION    latest
```
Java 8 is selected automatically. Modern Forge/NeoForge launch through their
generated `unix_args.txt` without any configuration.

### NeoForge 26.1.2 with pinned loader
```
SERVER_TYPE       neoforge
MINECRAFT_VERSION 26.1.2
LOADER_VERSION    latest
```

### Velocity proxy network
```
SERVER_TYPE       velocity
MINECRAFT_VERSION latest
```
`velocity.toml` is created and its bind line patched to your allocation.
Stopping works with the normal Stop button (`stop` is translated to `end`).

### BungeeCord
```
SERVER_TYPE       bungeecord
```
`config.yml` template included, port managed by the panel.

### Bedrock Dedicated Server
```
SERVER_TYPE       bedrock
MINECRAFT_VERSION latest
```
Port `19132`. x86_64 hosts only (Mojang ships no ARM binary; the installer
warns on ARM).

### PocketMine-MP / Nukkit
```
SERVER_TYPE       pocketmine     # or nukkit
```

### Any GitHub-published server (Arclight, Feather, forks, ...)
```
SERVER_TYPE       github
GITHUB_REPO       IzzelAliz/Arclight
GITHUB_TAG        latest
GITHUB_ASSET      server
```

### Crossplay in one line (Geyser + Floodgate + ViaVersion)
```
SERVER_TYPE       paper
MINECRAFT_VERSION latest
EXTRA_URLS        plugins|https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/geyser
                  plugins|https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/floodgate
```
Add port `19132` to the server for Bedrock players.

### Bring your own everything
```
SERVER_TYPE       custom
CUSTOM_COMMAND    java -Xmx2048M -jar myserver.jar
DL_URL           https://example.com/myserver.zip   # optional admin var
```
Ultimate escape hatch: put a `run.custom.sh` in the server files and it is
executed instead of the built-in launcher.

### List every available version
Set `SHOW_VERSIONS=1`, press **Reinstall**, read the list in console. Nothing
is changed.

---

## Updating servers safely

- Change `MINECRAFT_VERSION` / `BUILD_NUMBER` / `LOADER_VERSION`, press
  **Reinstall**. With `AUTO_UPDATE=1` the software refreshes in place:
  worlds, configs and plugins are untouched.
- Switching **server type** or jumping across major Minecraft lines triggers
  **instance archiving** (see below): nothing is lost.
- `KEEP_BACKUP=1` additionally keeps the previous jar as `<name>.old`.

### Safe type and version switching

The installer stores the installed state in `.mc-instance.conf`. On reinstall
it compares old vs new:

- **Same type + same major version line** (for example `1.21.x -> 1.21.y`):
  updated in place. Worlds/configs/plugins stay exactly as they are.
- **Breaking change** (type switch like `vanilla -> paper`, or a jump like
  `1.20.x -> 1.21.x`, or snapshot channel flips):
  the entire previous server is **moved** into
  `archive/<old-type>-<old-version>-<timestamp>/` and the new server is
  installed fresh next to it.

Nothing is ever deleted. The console tells you the archive folder name;
delete those folders manually from the File Manager whenever you want.

---

## Java guide

Auto-selection map used by the entrypoint:

| Minecraft | Java chosen |
|---|---|
| 26.x and newer | 25 (or newer if present) |
| 1.20.5 - 1.21.x | 21 |
| 1.17 - 1.20.4 | 17 |
| 1.16.5 and older | 8 |
| proxies / nukkit | 21 |
| bedrock / pocketmine | not needed |

Options in order of precedence:

1. `JAVA_URL`: direct URL to any Java runtime archive (admin variable).
2. `JAVA_VERSION`: exact major (`8`...`25`), future majors (`27`),
   vendors (`graalvm-21`, `corretto-21`, `semeru-21`), a direct tar.gz URL,
   or `custom` to use a JVM you uploaded into the server directory.
3. Empty: auto-selected from the table above.

Missing runtimes are downloaded on demand inside the container at start -
no image rebuild needed, so future Minecraft versions work even on old images.

---

## Performance tuning

- The default `JAVA_FLAGS` are **Aikar's tuned G1GC flags**, compatible with
  Java 8 through 25, giving low pause times and stable tick rates.
- Big servers (8 GB+): clear `JAVA_FLAGS` and set `GC_TYPE=zgc` (Java 21+).
- Tiny servers: keep defaults; disable tuning by setting `JAVA_FLAGS` to one
  space.
- `EXTRA_ARGS=--nogui` silences GUI warnings on some versions.
- The banner prints which flags source is active (`JAVA_FLAGS` or `GC_TYPE=x`).
- Memory tiers we recommend: 1024 MB vanilla/small proxy, 2048-4096 MB
  Paper/Purpur, 6144+ MB modpacks, plus `-Xms` equals `-Xmx` behavior via
  AlwaysPreTouch in the default flag set.
---

## Error logs and diagnostics

Persistent logs live inside the server directory. They survive restarts
and rotate automatically (old copy becomes `*.old`).

| File | What it contains |
|---|---|
| `install-error.log` | Full step-by-step trace of every install run: timestamps, function names and line numbers for each executed command |
| `.logs/launcher-errors.log` | Launcher journal: every launch/stop event, crashes with exit code, Java version, launch command, EULA state, orphan sweeps, last errors from `logs/latest.log` |
| `.logs/console.log` | Full console mirror of the current boot (rotated to `console.log.1` on the next boot) so crashes can be diagnosed even after the panel scrollback is gone |

When an installation fails you do not need to re-run anything: the console
prints a red failure report plus the **last 40 trace lines** immediately.
When the server process crashes, the launcher prints automated diagnostics
(EULA state, OOM detection at exit code 137, crash-report summaries,
recent log errors, the last 12 console lines before the crash) and appends
everything to `.logs/launcher-errors.log`.

For extra verbosity set `DEBUG=1` (admin variable) to mirror the resolved
environment on the console too.

### How panel Stop works (every panel)

The launcher guarantees the Stop/Restart button always works, verified by a
Docker test suite (`tests/panel-test.sh`, runs in CI before every publish):

1. **Console stop commands** - every panel daemon (Pterodactyl, Pelican,
   Feather, Jexactyl, Wisp) delivers the configured stop command as console
   text on the container's stdin. A background watcher scans console input,
   recognizes stop commands (`stop`, `^C`, `end`, `kill`, ...), including the
   Feather-style `^C` text on TTY containers, and triggers a graceful
   shutdown. All non-stop console lines are **forwarded to the server
   console**, so in-game commands typed in the panel keep working.
   `PANEL_STOP_WATCHER=0` disables the watcher and passes stdin straight to
   the server (legacy yolk behavior).
2. **Signals** - SIGTERM/SIGINT from panels or `docker stop` land on the
   launcher (PID 1) and trigger the same graceful shutdown (JVM shutdown
   hooks save the world first).
3. **Hung servers** - a server that ignores both the stop command and SIGTERM
   is force-killed (whole process tree) after the grace window, and a
   container-wide sweep removes orphaned children. The panel never hangs on
   "stopping".
4. **Proxy translation** - BungeeCord-family proxies get `stop` translated to
   `end` automatically.

---

## Troubleshooting matrix

| Symptom | Cause | Fix |
|---|---|---|
| `UnsupportedClassVersionError` | Wrong Java for that MC version | Leave `JAVA_VERSION` empty (auto) or pick matching value; use the Universal image |
| Install says "version not found" then installs latest | Typo in version | Set `SHOW_VERSIONS=1` + Reinstall to list valid versions |
| Server unreachable | Port mismatch | Reinstall once so config templates exist; panel patches ports on boot |
| Spigot build fails | Not enough memory during BuildTools | Temporarily raise allocation to 2048+ MB, reinstall |
| Bedrock will not start on ARM | Mojang ships x86_64 only | Use an x86_64 node |
| Forge 1.17+ "no main manifest" | Stale `unix_args.txt` | Delete it in File Manager and reinstall |
| Wizard prompts every start | Corrupted `.multi-mc.conf` | Delete the file, answer prompts once more |
| Want my own JVM flags | Custom tuning | Set `JAVA_FLAGS`; server args go to `EXTRA_ARGS` |
| Proxy ignores Stop | Proxies use `end` | Already handled: the launcher translates `stop` -> `end` |
| Changed type, old files gone? | They are archived | Look in `archive/<old-type>-<old-version>-<timestamp>/`, delete manually when ready |
| Panel Stop hangs on "stopping" | Daemon sends stop as console text | Fixed: the stdin stop-command watcher catches `stop`/`^C` text on pipes and TTYs (Feather Panel included) |
| Console theme looks different | New agent theme | Set `CLI_THEME=classic` for the yolk-style console, `CLI_BANNER_GRADIENT` to change the banner gradient |

---

## How it works

```
Panel (Pterodactyl / Pelican)
      |  imports egg, injects variables as environment
      v
Wings daemon on the game node
      |  creates container from ghcr.io/potenfyr-studios/minecraft-eggs
      v
entrypoint.sh
      1. loads .multi-mc.conf (persisted answers)
      2. detects the hosting panel (Pterodactyl / Pelican / Feather / ...)
      3. mirrors the console into .logs/console.log
      4. picks the right Java runtime (8/11/17/21/25/26 or on-demand)
      5. prints the themed gradient banner
      6. runs the STARTUP command -> run.sh
      v
run.sh
      5. validates settings, auto-fills sane defaults
      6. auto-installs if server files are missing (self-healing)
      7. prints the boot card (type, version, Java, memory, host, ...)
      8. dispatches:
            bedrock     -> ./bedrock_server
            pocketmine  -> php PocketMine-MP.phar --no-wizard
            proxies     -> java ... ("stop" translated to "end")
            java types  -> java [tuned flags] -jar server.jar
                          (+ @unix_args.txt for Forge/NeoForge 1.17+)
      v
Minecraft server process (crash diagnostics + .logs/launcher-errors.log on failure)
```

Installation runs in a one-shot container from the same image, as root, with
the server mounted at `/mnt/server`: it resolves versions against official
APIs, verifies them, downloads, writes default configs, records the instance
marker, prints a summary, exits. Wings then boots the runtime container with
your files at `/home/container`.

The panel patches ports into `server.properties`, BungeeCord/Waterfall
`config.yml` and Velocity's `velocity.toml` before every boot, and waits for
one of several "done" markers (`Done (`, `)! For help, type "help"`,
`Listening on`, `Server started.`) so any of the 19 types shows correct status.

If the server directory is ever empty at start (fresh disk, restored backup),
run.sh self-heals by invoking the installer inside the running container.

---

## Architecture and host OS support

Everything runs inside the container, so the node OS is irrelevant: Debian,
Ubuntu, Rocky, Alpine, Arch and NixOS hosts all work. The panel can live on a
different machine entirely.

| Architecture | CI image published | Notes |
|---|---|---|
| `linux/amd64` | yes | all runtimes |
| `linux/arm64` | yes | all runtimes |
| `ppc64le` | build natively | Adoptium publishes these JREs |
| `s390x` | build natively | Adoptium publishes these JREs |
| `riscv64` | build natively | newest runtimes only |
| other/exotic | build natively | distro OpenJDK fallback installed automatically |

Native build for any arch is a single command and takes minutes:
`docker build -t ghcr.io/potenfyr-studios/minecraft-eggs:latest .`
The Dockerfile never hard-fails on unknown architectures.

Known vendor limits: Bedrock Dedicated Server is x86_64 only, and BuildTools
needs an x64/aarch64 JDK.

---

## Panel compatibility

The egg is a standard `PTDL_v2` export:

- **Pterodactyl 1.x**: import under Nests, works with stock Wings.
- **Pelican 1.x**: upload the same file; Pelican understands PTDL_v2 eggs.
- **Feather Panel**: supported - detected via its `P_SERVER_UUID_SHORT`
  injection, and Stop works even though FeatherWings delivers the stop
  command as console text into a TTY container (handled by the launcher's
  stdin stop-command watcher).
- Both use Wings-compatible daemons, so variables, the console wizard,
  archiving behavior and logging are identical everywhere.
- The boot card shows the detected platform (Host Platform row) and panel
  family for support diagnostics.
- Any panel that speaks the wings HTTP API and supports docker images from
  GHCR works out of the box.

---

## Administrator and production guide

### Publishing the image

CI (`.github/workflows/docker-image.yml`) builds the single universal image
for `amd64` + `arm64` on every push to `main` and publishes it as
`ghcr.io/potenfyr-studios/minecraft-eggs:latest`. No secrets required beyond
the built-in `GITHUB_TOKEN`.

Manual native build for any architecture:

```
docker build -t ghcr.io/potenfyr-studios/minecraft-eggs:latest .
```

### Egg updates

The egg carries `meta.update_url` pointing at this repository, so panels can
pull newer egg revisions automatically.

### Multi-tenant hosting tips

- Hide admin variables (`DL_URL`, `EXTRA_URLS`, `WORLD_URL`, `DEBUG`,
  `SHOW_VERSIONS`) from customers - already configured that way.
- Let customers own the rest: software choice, versions, MOTD, players,
  difficulty, gamemode, performance flags.
- Use panel Schedules: a periodic Reinstall with `AUTO_UPDATE=1` keeps
  servers updated; combine with Backups for safety.
- `RCON_PASSWORD` lets trusted staff attach gamepads/RCON tools; it is stored
  plaintext inside `server.properties` like every RCON setup.
- Old data after switches lands in `archive/`; add a schedule or manual review
  policy so disks stay lean.

---

## Security model

- Runtime containers execute as the unprivileged panel user; only the one-shot
  install container runs as root (needed for package bootstrap), inside its
  own isolated filesystem namespace.
- The root filesystem is read-only at runtime (wings default); servers write
  only into their mounted directory.
- All shell scripts run with `set -uo pipefail` and fully quoted expansions.
- `.multi-mc.conf` and `.mc-instance.conf` are parsed, never sourced: values
  cannot execute code.
- Downloads are atomic (temp file then move) and removed on failure; archives
  are moved, never copied twice.
- `EXTRA_URLS` destinations are validated against path traversal; GitHub
  repositories are format-checked; file names are sanitized.
- No secrets, tokens or API keys exist anywhere in this project.
- Admin-only variables (`DL_URL`, `EXTRA_URLS`, `WORLD_URL`) intentionally
  allow arbitrary download locations: restrict them if you hand servers to
  untrusted users.

---

## FAQ

**Q: Does changing the server type delete my world?**
No. Breaking changes archive everything to `archive/...`. Same-line updates
never touch your files.

**Q: Can I run Fabric mods on Paper?**
No, but switch `SERVER_TYPE=fabric`, press Reinstall, and you get a fresh
Fabric server beside your archived Paper instance instantly.

**Q: Which Java will my server get?**
The entrypoint picks it per Minecraft version; see the table in the Java
guide. Override with `JAVA_VERSION` when needed.

**Q: Is Windows supported?**
Panels and nodes must be Linux (a Pterodactyl/Pelican requirement). Inside
the node, host distribution does not matter.

**Q: How do I see which versions exist?**
`SHOW_VERSIONS=1` + Reinstall prints them without touching the server.

**Q: A new Minecraft version just released - does this still work?**
Yes: keyword `latest` always resolves to it, and missing Java runtimes are
downloaded on demand inside the container.

---

## Project layout

```
Minecraft-Eggs/
|-- egg-minecraft-multi.json   the egg (import this)
|-- Dockerfile                 universal multi-Java image definition
|-- install-java.sh            Java runtime installer (Adoptium/GraalVM/...)
|-- install.sh                 universal installer (embedded in the egg too)
|-- run.sh                     universal launcher with wizard + diagnostics
|-- entrypoint.sh              container init: conf load, Java pick, banner
|-- .github/workflows/         CI: multi-arch build + publish to GHCR
`-- README.md                  this documentation
```

Every script also exists standalone here so you can review exactly what runs
inside your containers before importing the egg.

---

## License and support

MIT licensed - see [LICENSE](LICENSE). Fork it, host it, sell hosting with it;
keep the credits.

- Author: **PotenFYR Studios**
- Issues: <https://github.com/PotenFYR-Studios/Minecraft-Eggs/issues>
- Contact: support@potenfyr.in