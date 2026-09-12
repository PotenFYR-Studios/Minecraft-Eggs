# Security Policy

## Supported versions

Only the latest `master` and the latest published Docker image
(`ghcr.io/potenfyr-studios/minecraft-eggs:latest`) receive security fixes. The egg self-updates
its launcher scripts from the upstream egg JSON on startup (`AUTO_UPDATE_EGG=1`), so servers
using the default configuration track fixes automatically.

## Reporting a vulnerability

**Do not open a public GitHub issue for security reports.**

Use GitHub **private vulnerability reporting** on this repository
(*Security → Report a vulnerability*), or email **[support@potenfyr.in](mailto:support@potenfyr.in)**
with:

- Affected component (egg JSON / `run.sh` / `install.sh` / `install-java.sh` / `entrypoint.sh` / Docker image / docs site)
- Panel and daemon version (Pterodactyl + Wings, Pelican, Feather, …)
- `SERVER_TYPE` and `MINECRAFT_VERSION` involved
- Steps or logs reproducing the issue (sanitize secrets; the egg never needs your tokens in logs)

You will get an acknowledgement within a few days. Please allow up to 90 days for a fix before
public disclosure; we credit reporters in release notes unless you prefer otherwise.

## Security model notes

- Containers run **rootless** as the Pterodactyl `container` user (UID 988); core scripts live in
  root-owned `/opt/potenfyr/` outside the panel file-manager jail.
- Downloads are staged atomically; path traversals in `EXTRA_URLS` are blocked; startup variables
  are strictly validated (`rules` in the egg JSON).
- The egg ships no hardcoded credentials. `GITHUB_TOKEN` and `RCON_PASSWORD` are optional and
  stored only in panel/environment scope.
- If you find a vulnerability **upstream** (Mojang BDS, Paper, Velocity, PHP, …), please report it
  to the respective project; we track their advisories for the image's runtime matrix.
