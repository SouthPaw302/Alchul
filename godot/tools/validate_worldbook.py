#!/usr/bin/env python3
"""Verify Alchul's independent scene contract using Python's standard library only."""
from __future__ import annotations

import json
import pathlib
import sys

GODOT_ROOT = pathlib.Path(__file__).resolve().parents[1]
REPO_ROOT = GODOT_ROOT.parent
EXPECTED_LENSES = {"outside", "resident", "contact"}
EXPECTED_SITES = {"bank", "nursery", "harvest", "witness"}
EXPECTED_FILES = [
    "project.godot",
    "scenes/main.tscn",
    "scripts/world.gd",
    "scripts/observer.gd",
    "data/worldbook.json",
    "tests/smoke.gd",
    "README.md",
    "PROVENANCE.md",
]


def check(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def main() -> int:
    for p in EXPECTED_FILES:
        check((GODOT_ROOT / p).is_file(), f"Missing independent runtime file: godot/{p}")

    data = json.loads((GODOT_ROOT / "data/worldbook.json").read_text("utf-8"))
    check(data.get("schema") == "alchul.native-worldbook.v1", "Invalid worldbook version")
    check(data.get("status") == "working_reconstruction", "Worldbook must be marked noncanon")
    check(set(data.get("lenses", {})) == EXPECTED_LENSES, "Three interpretation lenses required")
    check(set(data.get("sites", [{}])[i].get("id") for i in range(len(data.get("sites", [])))) == EXPECTED_SITES,
          "Required unique site identifiers missing")

    for lens, info in data["lenses"].items():
        check(bool(info.get("title")) and bool(info.get("explanation")),
              f"Missing lens description: {lens}")

    for site in data["sites"]:
        coords = site.get("position", [])
        check(len(coords) == 2 and all(isinstance(x, (int, float)) for x in coords),
              f"Site coordinates invalid: {site.get('id')}")
        check(set(site.get("lenses", {})) == EXPECTED_LENSES,
              f"Site {site.get('id')} needs all three interpretations")
        check(all(len(str(x)) > 10 for x in site["lenses"].values()),
              f"Site {site.get('id')} needs substantial descriptions")

    for source in data.get("sources", []):
        check(source.endswith(".md") and (REPO_ROOT / source).is_file(),
              f"Unresolved first-party source: {source}")

    config = (GODOT_ROOT / "project.godot").read_text("utf-8")
    check('run/main_scene="res://scenes/main.tscn"' in config,
          "Main scene not defined in native project")
    check('renderer/rendering_method="gl_compatibility"' in config,
          "Compatibility renderer requirement missing")

    scene = (GODOT_ROOT / "scenes/main.tscn").read_text("utf-8")
    check('res://scripts/world.gd' in scene, "Main scene has no local world script")

    for f in (GODOT_ROOT / "scripts").glob("*.gd"):
        body = f.read_text("utf-8").lower()
        for forbidden in ("godrender", "alchul-gemini", "github.com", "http://", "https://"):
            check(forbidden not in body, f"External source/network reference in active scene {f.name}: {forbidden}")

    print("ALCHUL OFFLINE CONTRACT PASS — 4 sites, 3 lenses, 8 local runtime files, no cross-repo calls")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, json.JSONDecodeError) as exc:
        print(f"ALCHUL OFFLINE CONTRACT FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
