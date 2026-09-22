#!/usr/bin/env python3
"""Keep the egg JSON's embedded installer in sync with install.sh.

Pterodactyl/Pelican/Feather run the *installation script embedded in the egg
JSON*, not the copy baked into the image. Editing install.sh without mirroring
the change into egg-minecraft-multi.json ships a stale installer to every panel
(the Fabric/Quilt launcher-clobber fix was silently lost that way).

Usage:
  python3 tests/sync-egg-install.py            # check (exit 1 on drift)
  python3 tests/sync-egg-install.py --write    # rewrite the embedded script
"""

from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
INSTALL = ROOT / "install.sh"
EGG = ROOT / "egg-minecraft-multi.json"


def read_install() -> str:
    # The panel stores the script with LF newlines; normalize so a Windows
    # checkout does not report false drift.
    return INSTALL.read_text(encoding="utf-8").replace("\r\n", "\n")


def embedded(egg: dict) -> str:
    return egg["scripts"]["installation"]["script"]


def main() -> int:
    write = "--write" in sys.argv[1:]
    source = read_install()
    raw = EGG.read_text(encoding="utf-8")
    egg = json.loads(raw)
    current = embedded(egg)

    if current == source:
        print("egg-minecraft-multi.json installation script is in sync with install.sh")
        return 0

    if not write:
        print(
            "ERROR: egg-minecraft-multi.json embedded installer is out of sync "
            "with install.sh",
            file=sys.stderr,
        )
        print("Run: python3 tests/sync-egg-install.py --write", file=sys.stderr)
        return 1

    # Minimal-diff replacement: swap only the serialized script value so the
    # rest of the panel-generated JSON (keystrokes, ordering, spacing) is
    # preserved byte-for-byte.
    old_serialized = json.dumps(current, ensure_ascii=False)
    new_serialized = json.dumps(source, ensure_ascii=False)
    if raw.count(old_serialized) != 1:
        print(
            "ERROR: could not locate the embedded installer string uniquely; "
            "refusing to rewrite.",
            file=sys.stderr,
        )
        return 1
    EGG.write_text(
        raw.replace(old_serialized, new_serialized), encoding="utf-8", newline="\n"
    )
    print("Updated egg-minecraft-multi.json embedded installer from install.sh")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
