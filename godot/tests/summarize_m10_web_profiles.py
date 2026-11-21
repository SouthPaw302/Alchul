#!/usr/bin/env python3
"""M10 exploratory browser A/B: distinguish rendering bottlenecks.

Treat single-run SwiftShader requestAnimationFrame deltas as diagnostic only.
They are not desktop GPU FPS, and these data do not approve the public site.
"""
from __future__ import annotations

import json
import pathlib
import statistics
import sys

PROFILES = ("reference", "no_shadows", "simple_m6", "static_water", "all_light")


def main(folder: pathlib.Path) -> int:
    items = []
    for variant in PROFILES:
        path = folder / variant / "M8_BROWSER_METRICS.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        actual = data.get("active_m10_profile")
        if actual != variant:
            raise ValueError(f"Expected {variant} to be applied in Godot, got {actual!r}")
        if data.get("fatal_errors"):
            raise ValueError(f"Fatal browser errors for {variant}: {data['fatal_errors']}")
        median = float(data["raf_median_ms"])
        p95 = float(data["raf_p95_ms"])
        frames = int(data["sampled_raf_frames"])
        if frames < 8 or not (0 < median < 20000 and 0 < p95 < 20000):
            raise ValueError(f"Insufficient or invalid frames for {variant}")
        items.append({
            "mode": variant,
            "sampled_raf_frames": frames,
            "raf_median_ms": round(median, 1),
            "raf_p95_ms": round(p95, 1),
            "software_renderer_budget_met": p95 <= 250,
        })
    baseline = items[0]
    for row in items:
        row["p95_change_from_reference_ms"] = round(row["raf_p95_ms"] - baseline["raf_p95_ms"], 1)
        row["median_change_from_reference_ms"] = round(row["raf_median_ms"] - baseline["raf_median_ms"], 1)
    result = {
        "schema": "alchul.browser-profile.m10.v1",
        "status": "comparative_software_renderer_study_not_release_approval",
        "profile_order": PROFILES,
        "runs": items,
        "software_renderer_p95_budget_ms": 250,
        "warnings": [
            "Each variant has one 20-second SwiftShader RAF sample, not statistically controlled hardware FPS.",
            "No-shadows and simpler-shader modes are isolated experiments, not accepted production visuals.",
            "Interpret large differences as leads for controlled follow-up; no live site changes.",
        ],
    }
    path = folder / "M10_WEB_PROFILE_COMPARISON.json"
    path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    report = folder / "M10_WEB_PROFILE_REPORT.md"
    rows = [
        "# M10 browser shading diagnostics — candidate only",
        "",
        "Single-run Chromium headless SwiftShader/WebGL2 measurements; not desktop hardware FPS.",
        "The baseline full-quality scene is not modified on the live website.",
        "",
        "| Mode | RAF median (ms) | RAF p95 (ms) | Samples | p95 improvement vs reference |",
        "| --- | ---: | ---: | ---: | ---: |",
    ]
    rows.extend(
        f"| {r['mode']} | {r['raf_median_ms']} | {r['raf_p95_ms']} | {r['sampled_raf_frames']} | "
        f"{-r['p95_change_from_reference_ms']:+.1f} ms |"
        for r in items
    )
    rows += [
        "",
        "Profiles: reference (full materials/shadows), no_shadows, simple_m6",
        "(flat-colored riverbank material in place of per-fragment noise),",
        "static_water (constant water shader), all_light (all three).",
        "",
        "The 250 ms p95 software renderer gate is still independent. Performance",
        "numbers alone cannot approve any fidelity-reduced variant for production.",
    ]
    report.write_text("\n".join(rows) + "\n", encoding="utf-8")
    print("\n".join(rows))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(pathlib.Path(sys.argv[1])))
    except (IndexError, KeyError, ValueError, OSError, json.JSONDecodeError) as exc:
        print(f"ALCHUL M10 WEB PROFILE FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
