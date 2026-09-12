<!--
Thanks for contributing to Minecraft-Eggs! Keep PRs focused: one logical change per PR.
Egg changes must keep egg-minecraft-multi.json as the single source of truth.
-->

## Summary

<!-- What does this PR change and why? -->

## Type of change

- [ ] Egg JSON (`egg-minecraft-multi.json`)
- [ ] Runtime scripts (`run.sh` / `install.sh` / `install-java.sh` / `entrypoint.sh`)
- [ ] Docker image (`Dockerfile`)
- [ ] Docs site (`docs/`)
- [ ] CI / workflows
- [ ] Community files / other

## Checklist

- [ ] `egg-minecraft-multi.json` parses: `python3 -m json.tool egg-minecraft-multi.json > /dev/null`
- [ ] If `SERVER_TYPE` values changed: `install.sh`/`run.sh` handle them and the docs catalog notes in `docs/src/catalog.ts` were updated
- [ ] Docs rebuilt from the real egg data: `cd docs && bun install && bun run build`
- [ ] `docker build -t mc-eggs-test -f tests/Dockerfile.test . && bash tests/panel-test.sh` passes locally (behavior changes)
- [ ] No secrets or tokens committed

## Testing

<!-- Which panel/engines did you verify? Paste the relevant test output. -->

- Panel:
- SERVER_TYPE / MINECRAFT_VERSION tested:
- Behavior test suite: pass / fail / not applicable
