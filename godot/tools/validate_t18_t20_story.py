#!/usr/bin/env python3
"""Small integrity check for a fictional scene; NOT a scientific-history validator."""
import json
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
ROOT = PROJECT.parent
FILE = PROJECT / "data/t18_t20_the_river_answered_twice.json"

def check() -> None:
    story = json.loads(FILE.read_text(encoding="utf-8"))
    assert story["status"] == "PROVISIONAL_FICTIONAL_CULTURE_NOT_ANATOMY_CANON"
    assert story["schema"] == "alchul.t18_t20.living_scene.v1"
    assert story["primary_source_scene"] == "res://assets/m2/ALC_M2_RIVER_STATION_v001.glb"
    assert story["physical_source_model"] == "res://scenes/m11_t17_physical_sensing_lab.tscn"
    assert len(story["narrative_lenses"]) == 3
    assert {r["id"] for r in story["narrative_lenses"]} == {"trace", "reading", "unclosed"}
    assert len(story["actors"]) == 4 and {r["id"] for r in story["actors"]} == {"listener", "turner", "keeper", "witness"}
    assert len(story["lexicon"]) >= 7
    assert len(story["opening"]) == 4
    assert len(story["trials"]) == 3 and {r["id"] for r in story["trials"]} == {"water", "support", "ambiguous"}
    assert {"river_pulse", "bank_vibration"} == set(story["trials"][2]["stimulus"])
    assert story["choices"] == {"next":"SPACE","lens":"L","trial_water":"1","trial_support":"2","trial_ambiguous":"3","repeat":"R","test":"T"}
    for section in ("contact_scope", "biological_scope", "evidence_scope"):
        assert story[section].strip()
    for path in (
        "LORE/T18_THE_UNCLOSED_ACCOUNT.md", "LORE/T19_THE_LANGUAGE_OF_WEIGHTS.md",
        "LORE/T20_THE_TWO_READINGS.md",
        "godot/scripts/t18_t20_living_world_scene.gd",
        "godot/scenes/t18_t20_living_world_scene.tscn",
    ):
        assert (ROOT / path).is_file(), path
    assert all(len(s["cue"]) > 8 and s["ambiguous_context"] for s in story["lexicon"])
    print("ALCHUL T18–T20 WORLD-BUILDING PASS — 3 lenses, 4 roles, 7 gestures, 3 replay endings, Alchul remains unresolved")

if __name__ == "__main__":
    check()
