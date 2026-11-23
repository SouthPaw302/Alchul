#!/usr/bin/env python3
"""T12: science-first stratigraphic timeline / provisional inhabitant registry.

This is a semantic validator, NOT an evolutionary simulator. It deliberately
prevents fictional post-KPg survival from appearing in real Earth evidence.
"""
from __future__ import annotations
import argparse
import copy
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "godot" / "data"
EARTH_PATH = DATA / "m11_t12_real_earth_timeline.json"
PEOPLE_PATH = DATA / "m11_t12_inhabitant_candidates.json"
EXPECTED_ERAS = (
    "late_cretaceous_appalachia", "maastrichtian", "kpg_boundary",
    "paleogene", "neogene", "pleistocene", "holocene",
    "new_madrid_1811_1812", "present_2026"
)
EXPECTED_PEOPLE = (
    "water_reader", "independent_colleague", "egg_bearing_adult",
    "juvenile_learner", "nursery_worker", "harvest_specialist"
)


class ContractError(ValueError):
    pass


def load(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ContractError(f"{path.name}: JSON root must be an object")
    return value


def insist(test: bool, message: str) -> None:
    if not test:
        raise ContractError(message)


def check_earth(timeline: dict) -> None:
    insist(timeline.get("version") == "t12_real_earth_v1", "Wrong geological atlas version")
    method = timeline.get("authority_policy", {})
    for flag in (
        "real_science_precedes_story", "correct_intraplate_tectonics",
        "fiction_canon_is_not_paleontology"
    ):
        insist(method.get(flag) is True, "Missing science-first gate: " + flag)
    for forbidden in (
        "fossil_continuity_claimed", "surviving_non_avian_dinosaurs_claimed",
        "hidden_civilization_evidence_claimed", "modern_alchul_body_reconstructed"
    ):
        insist(method.get(forbidden) is False, "Fiction as observation forbidden: " + forbidden)
    place_note = method.get("real_present_day", "").lower()
    insist("within the north american plate" in place_note
        and "intraplate" in place_note
        and "not a plate boundary" in place_note,
        "Modern New Madrid must be correctly represented as intraplate deformation")
    eras = timeline.get("eras", [])
    insist(isinstance(eras, list) and len(eras) == len(EXPECTED_ERAS),
           "Full nine-stage real Earth timeline to the present is required")
    insist(tuple(x.get("id") for x in eras) == EXPECTED_ERAS,
           "Chronological order or one of nine geological/historical eras changed")
    for era in eras:
        name = era["id"]
        science = era.get("real_world", {})
        story = era.get("fiction", {})
        insist(science.get("confidence") and science.get("summary") and science.get("evidence"),
               f"{name} has no bounded real-world evidence")
        insist(isinstance(science.get("limits"), list) and len(science["limits"]) >= 1,
               f"{name} has no uncertainty caveat")
        sources = science.get("source_urls", [])
        insist(isinstance(sources, list) and len(sources) >= 1
               and all(isinstance(s, str) and s.startswith("https://") for s in sources),
               f"{name} missing public science references")
        insist(story.get("status", "").startswith("fictional_")
               and story.get("summary") and story.get("body_reconstructed") is False,
               f"{name}: fictional anatomy or history presented as established")
    kpg = eras[2]
    insist(kpg["start_ma"] == 66 and kpg["end_ma"] == 66
           and "non-avian dinosaur" in kpg["real_world"]["summary"].lower(),
           "K-Pg constraint does not describe nonavian extinction at 66 Ma")
    insist(eras[3]["start_ma"] == 66 and eras[4]["start_ma"] == 23.03
           and eras[5]["start_ma"] == 2.58,
           "Current stratigraphic era boundaries changed without review")
    insist(eras[-1]["time"] == "2026 CE" and eras[-1]["kind"] == "modern_observation",
           "Present-day endpoint is missing")
    present = eras[-1]["real_world"]["summary"].lower()
    insist("intraplate" in present and "north american plate" in present,
           "Modern tectonic description was compromised")
    insist("no real-world alchul" in " ".join(eras[-1]["real_world"]["limits"]).lower(),
           "Real-world non-observation must remain explicit")
    insist(len(timeline.get("forbidden_real_history_claims", [])) >= 5,
           "No prohibited history-claim ledger")


def check_people(data: dict) -> None:
    insist(data.get("schema_version") == "m11_t12_people_v1", "Wrong T12 roster schema")
    insist(data.get("science_first") is True and data.get("biological_approval") == "not_approved",
           "Unapproved species promoted to scientific knowledge")
    insist(data.get("selected_era_scope") == "pre_kpg_peak_surface_undated",
           "Modern or exactly dated inhabitants were invented")
    insist(data.get("structural_hypotheses") == ["H-A", "H-B"],
           "Both unapproved T07 alternatives must remain")
    insist("not numerically fixed" in data.get("time_rule", ""),
           "T12 placed the surface peak at a made-up absolute date")
    people = data.get("roles", [])
    insist(isinstance(people, list) and len(people) == len(EXPECTED_PEOPLE),
           "Exactly six independent study individuals are required")
    insist(tuple(p.get("id") for p in people) == EXPECTED_PEOPLE,
           "Expected six role studies missing or reordered")
    titles, tasks = set(), set()
    for person in people:
        pid = person["id"]
        insist(person.get("title") and person.get("activity") and person.get("functional_variation")
               and person.get("testable_question") and person.get("risk"),
               pid + ": insufficient person-specific functional design")
        insist(person["title"] not in titles and person["activity"] not in tasks,
               pid + ": this is a duplicate/caste template, not independent study")
        titles.add(person["title"])
        tasks.add(person["activity"])
        insist(person.get("life_stage") in ("adult", "juvenile"), pid + ": age stage unknown")
        insist(len(person.get("environments", [])) >= 1 and len(person.get("required_models", [])) >= 1,
               pid + ": no testable task/environment")
        insist(person.get("individual_status") == "provisional"
               and person.get("body_plan_approved") is False
               and person.get("sex_or_gender_inferred") is False
               and person.get("specialist_is_caste") is False
               and person.get("post_kpg_body_claimed") is False
               and person.get("visual_anatomy_is_factual") is False,
               pid + ": fictional assumptions wrongly promoted")
    by_id = {p["id"]: p for p in people}
    insist(by_id["juvenile_learner"]["life_stage"] == "juvenile",
           "Juvenile study was turned into an adult")
    insist(by_id["egg_bearing_adult"]["life_stage"] == "adult",
           "Egg-bearing stage implied to be a juvenile")
    insist(by_id["egg_bearing_adult"]["id"] != by_id["nursery_worker"]["id"],
           "Egg-bearer and nursery worker must remain independent")
    insist("T11_reproductive_indices" in by_id["egg_bearing_adult"]["required_models"],
           "T11 oxygen and maternal constraints not carried forward")
    checklist = data.get("comparative_checklist", {})
    insist(checklist.get("original_individual_count") == 6, "Roster audit count changed")
    for key in (
        "separate_age_stages", "egg_bearing_not_caregiver_equivalence",
        "no_fixed_sex_roles", "no_fixed_height_mass_or_clutch",
        "no_invented_sensory_organs", "modern_biology_requires_separate_future_study",
        "evidence_before_visual_promotion"
    ):
        insist(checklist.get(key) is True, "Failed art/science safeguard: " + key)


def validate(timeline: dict, people: dict) -> dict:
    check_earth(timeline)
    check_people(people)
    return {
        "era_count": len(timeline["eras"]),
        "role_count": len(people["roles"]),
        "earliest_working_ma": timeline["eras"][0]["start_ma"],
        "boundary_ma": timeline["eras"][2]["start_ma"],
        "present_endpoint": timeline["eras"][-1]["time"],
        "real_nonavian_survival_observed": False,
        "modern_hidden_civilization_observed": False,
        "modern_species_anatomy_approved": False,
        "scientific_status": "science_history_grounded_fiction_layer_explicit"
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    summary = validate(load(EARTH_PATH), load(PEOPLE_PATH))
    print("ALCHUL T12 SCIENCE-FIRST TIMELINE / SIX INDIVIDUAL CONTRACT PASS")
    print(json.dumps(summary, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
