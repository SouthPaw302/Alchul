#!/usr/bin/env python3
"""T14: decision-safety contract for *unapproved* dinosaur-descendant bodies.

No geological units, human morphology, or real K-Pg survival claim may be
silently injected into a comparative *tool-derived* record.
"""
from __future__ import annotations
import json
from pathlib import Path
import sys

PROJECT = Path(__file__).resolve().parents[1]
REVIEW_PATH = PROJECT / "data" / "m11_t14_anatomy_review.json"


def load_review(path: Path = REVIEW_PATH) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def validate(review: dict) -> list[str]:
    errors: list[str] = []
    if review.get("schema") != "alchul.m11.t14.creator-anatomy-review.v1":
        errors.append("schema_version")
    if review.get("status") != "DECISION_PENDING_NOT_CANON":
        errors.append("approval_not_pending")
    if review.get("current_decision") is not None:
        errors.append("invented_creator_decision")
    if review.get("prohibited_unapproved_promotion") is not True:
        errors.append("canon_gate_off")
    if review.get("present_day_body_specified") is not False:
        errors.append("ancient_shape_promoted_to_modern")
    if "pre-KPg" not in str(review.get("era_scope", "")):
        errors.append("missing_era_scope")
    if set(review.get("evidence_classes", [])) != {
        "published_comparative", "project_assumption_model",
        "fictional_canon", "unresolved"
    }:
        errors.append("evidence_types_mixed")
    rows = review.get("comparisons", [])
    if not isinstance(rows, list) or [r.get("id") for r in rows] != ["H-A", "H-B", "H-C"]:
        errors.append("missing_competing_hypotheses")
    else:
        a, b, hybrid = rows
        if (a.get("first_sampled_clear_corridor_width_normalized") != 4.6 or
            b.get("first_sampled_clear_corridor_width_normalized") != 2.8 or
            a.get("violations_at_2p8_of_101") != 55 or
            b.get("violations_at_2p8_of_101") != 0):
            errors.append("T10_model_inconsistent")
        if (a.get("nominal_lateral_com_shift_normalized") != 0.205 or
            b.get("nominal_lateral_com_shift_normalized") != 0.265):
            errors.append("T10_COM_model_inconsistent")
        if (a.get("sampled_tail_contribution_percent") != 14 or
            b.get("sampled_tail_contribution_percent") != 7):
            errors.append("T08_tail_model_inconsistent")
        if any(row.get("scientific_approval") is not False or
               row.get("creator_approved") is not False for row in rows):
            errors.append("species_approval_invented")
        if any(hybrid.get(key) is not None for key in (
            "nominal_lateral_com_shift_normalized",
            "first_sampled_clear_corridor_width_normalized",
            "sampled_tail_contribution_percent", "violations_at_2p8_of_101"
        )):
            errors.append("invented_hybrid_results")
        if any("unmeasured" not in str(row.get("length_claim","")).lower()
               for row in [a,b]):
            errors.append("physical_meters_claim")
    gates = review.get("gates", [])
    if not isinstance(gates, list) or {g.get("id") for g in gates} != {
        "bone_soft_tissue", "grip", "locomotion", "settlement",
        "reproduction", "creator"
    }:
        errors.append("missing_open_gates")
    elif any(g.get("status") not in ["open", "awaiting_explicit_creator_decision"] for g in gates):
        errors.append("unearned_gate_pass")
    source_links = review.get("source_links", [])
    if len(source_links) < 6 or not any(
        x.get("url", "").startswith("https://www.nature.com/articles/") for x in source_links):
        errors.append("missing_external_provenance")
    if "defer_all" not in review.get("review_options", []):
        errors.append("undue_forced_selection")
    return errors


def main() -> int:
    issues = validate(load_review())
    if issues:
        print("T14 EVIDENCE CONTRACT FAIL:", ", ".join(issues), file=sys.stderr)
        return 1
    print("T14 EVIDENCE CONTRACT PASS — 3 hypotheses, 6 open gates, 0 approvals, source-classified")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
