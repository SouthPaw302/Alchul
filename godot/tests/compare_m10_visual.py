#!/usr/bin/env python3
"""M10 native visual A/B regression against opt-out source geometry.

Uses identical ten camera shots from the existing M7 test script under
the same pinned Godot renderer. Pixel equality is *not* guaranteed due
to animated water and timing; report both total MAE and fraction of
pixels changing materially. Never treat passing as canon approval.
"""
from __future__ import annotations

import json
import pathlib
import sys

from PIL import Image, ImageChops, ImageStat


def compare(original: pathlib.Path, optimized: pathlib.Path, out: pathlib.Path) -> int:
    baseline = sorted(original.glob("*.png"))
    modified = sorted(optimized.glob("*.png"))
    expected = {p.name for p in baseline}
    if len(baseline) != 10 or expected != {p.name for p in modified}:
        raise RuntimeError(f"Expected ten matched PNG captures, got {len(baseline)} / {len(modified)}")
    report: list[dict] = []
    flagged: list[str] = []
    for first in baseline:
        second = optimized / first.name
        with Image.open(first) as src, Image.open(second) as dst:
            src_rgb, dst_rgb = src.convert("RGB"), dst.convert("RGB")
            if src_rgb.size != dst_rgb.size:
                raise RuntimeError(f"Image dimensions differ: {first.name}")
            diff = ImageChops.difference(src_rgb, dst_rgb)
            mean_channels = ImageStat.Stat(diff).mean
            mae = sum(mean_channels) / len(mean_channels)
            pixel_count = src_rgb.size[0] * src_rgb.size[1]
            changed = sum(1 for pixel in diff.getdata() if max(pixel) > 32)
            changed_fraction = changed / pixel_count
            report.append({
                "name": first.name,
                "width": src_rgb.size[0],
                "height": src_rgb.size[1],
                "mae_0_to_255": round(mae, 4),
                "pixels_differing_over_32_ratio": round(changed_fraction, 5),
            })
            if changed_fraction > 0.35 or mae > 42.0:
                flagged.append(first.name)
    out.parent.mkdir(parents=True, exist_ok=True)
    before_metrics = json.loads((original / "capture_metrics.json").read_text("utf-8"))
    after_metrics = json.loads((optimized / "capture_metrics.json").read_text("utf-8"))
    before_draw_calls = before_metrics.get("draw_calls_per_view", [])
    after_draw_calls = after_metrics.get("draw_calls_per_view", [])
    if len(before_draw_calls) != 10 or len(after_draw_calls) != 10:
        raise RuntimeError("Expected real draw-call counters for all ten native views")
    draw_reductions = [a - b for a, b in zip(before_draw_calls, after_draw_calls)]
    result = {
        "native_draw_calls": {
            "before": before_draw_calls,
            "after": after_draw_calls,
            "per_view_reduction": draw_reductions,
            "median_before": sorted(before_draw_calls)[5],
            "median_after": sorted(after_draw_calls)[5],
            "metric_note": "Godot RenderingServer draw calls, not web RAF or desktop FPS",
        },
        "status": "candidate_visual_regression_data_not_canon",
        "reference": "unbatched station from same Git SHA",
        "variant": "M10 SurfaceTool static bake, full local transforms, alpha excluded",
        "per_view": report,
        "flagged_views": flagged,
        "thresholds": {"max_material_pixel_change_ratio": 0.35, "max_mae": 42.0},
        "warnings": [
            "No guarantee that changed pixels are structural changes; water is animated.",
            "Review arched roof in native screenshots before approval.",
            "Neither screenshot latency nor RAF scheduling equals desktop hardware FPS.",
        ],
    }
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    for r in report:
        print(f"{r['name']}: pixel_change={r['pixels_differing_over_32_ratio']:.3%}, MAE={r['mae_0_to_255']:.2f}")
    print("M10 DRAW CALLS BEFORE:", before_draw_calls)
    print("M10 DRAW CALLS AFTER:", after_draw_calls)
    print("M10 VISUAL QA:", "FLAGGED " + ", ".join(flagged) if flagged else "THRESHOLD PASS")
    return 1 if flagged else 0


if __name__ == "__main__":
    try:
        sys.exit(compare(pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])))
    except (IndexError, OSError, ValueError, RuntimeError) as exc:
        print(f"M10 VISUAL QA FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
