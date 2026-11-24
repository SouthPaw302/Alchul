#!/usr/bin/env python3
"""Verify T21.2 scope and inherited T21.1 causality; not scientific validation."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
GAME = ROOT / "godot"


def check() -> None:
    data = json.loads((GAME / "data/t21_living_systems.json").read_text(encoding="utf-8"))
    assert data["schema"] == "alchul.t21.living_systems.v1"
    assert data["era"] == "mature_surface_before_long_descent"
    assert data["status"].startswith("PROVISIONAL_FICTIONAL")
    file = (GAME / "scripts/t21_p2_living_terrace.gd").read_text(encoding="utf-8")
    assert file.startswith('extends "res://scripts/t21_living_systems_scene.gd"')
    assert "T21.2" in file
    for name in ("_bank", "_culture_ground", "_nursery", "_workshop",
                 "_transit", "_exchange_reeds", "_refresh_processes",
                 "_animate_material_flows", "living_process_report"):
        assert "func " + name + "(" in file, name
    for phrase in (
        "FICTIONAL_MATURE_SURFACE_PROCESS_VISUALIZATION_NOT_CALIBRATED",
        "original_mesh_count", "relief_water", "screen_filter", "brace_support",
        "heat_stones", "gas_bubbles", "route_posts", "labor_frame",
        '"anatomically_approved_characters":false',
        '"true_hydraulic_solver":false',
        '"influence_is_an_engineering_cause":false',
        '"public_chapter_modified":false',
    ):
        assert phrase in file, phrase
    for path in (
        "godot/scenes/t21_p2_living_terrace.tscn",
        "godot/tests/t21_p2_living_terrace_smoke.gd",
        "godot/tests/render_t21_p2_living_terrace.gd",
        "MEDIA/T21_P2_PROCESS_TERRACE_DELIVERY.md",
        "WRITING/CHRONICLE_04_THE_WORK_BETWEEN_WARNINGS.md",
    ):
        assert (ROOT / path).is_file(), path
    original = (GAME / "scripts/t21_living_systems_scene.gd").read_text(encoding="utf-8")
    assert "func _all_systems_safe()" in original
    assert "_all_systems_safe" not in file
    assert "func take_action(" not in file
    assert "func _end_watch(" not in file
    assert "func _process(" in file
    assert "func _ready()" in file and "super._ready()" in file
    print("ALCHUL T21.2 CONTRACT PASS — retains T21.1 causality, adds 6 independent visible process groups, no anatomy/physics claims")


if __name__ == "__main__":
    check()
