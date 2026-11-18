#!/usr/bin/env python3
"""Stage the archived Batch 06 GLB and 28 PBR PNGs for Godot import.

Run from the repository root:
  python3 godot/tools/stage_m6_assets.py --pack /path/to/ALC_M6_COMPLETE_VISUAL_PACK_v001.zip

This validates the original GLB hash and texture family coverage, then copies
bytes under godot/assets/m6/. No network required; do not run this in the live
publishing workflow until browser asset size and quality are approved.
"""
from __future__ import annotations
import argparse, hashlib, json, struct
from pathlib import Path
from zipfile import ZipFile

EXPECTED_GLB_SHA256 = "0f640fc0a5bc8dd385d272a7d4bde33af110931f26da785d5546150b7a42c606"
GLB_NAME = "ALC_M6_RIVERBANK_DETAIL_TEXTURED_v001.glb"
FAMILIES = ("silt", "limestone", "rootwood", "clay", "moss", "fern", "water")
MAPS = ("albedo", "normal", "roughness", "height")

def stage(pack: Path, destination: Path) -> dict:
    if not pack.is_file():
        raise FileNotFoundError(f"M6 archive not found: {pack}")
    destination.mkdir(parents=True, exist_ok=True)
    textures = destination / "textures"
    textures.mkdir(parents=True, exist_ok=True)
    verified = {}
    with ZipFile(pack) as archive:
        if archive.testzip() is not None:
            raise ValueError("M6 source archive failed ZIP CRC integrity")
        names = set(archive.namelist())
        glb_key = next((name for name in names if name.endswith("/" + GLB_NAME) or name == GLB_NAME), None)
        if glb_key is None:
            raise ValueError(f"Missing archived original GLB: {GLB_NAME}")
        glb = archive.read(glb_key)
        digest = hashlib.sha256(glb).hexdigest()
        if digest != EXPECTED_GLB_SHA256:
            raise ValueError(f"Original GLB does not match production manifest: {digest}")
        (destination / GLB_NAME).write_bytes(glb)
        verified[GLB_NAME] = digest
        for family in FAMILIES:
            for kind in MAPS:
                filename = f"ALC_M6_{family}_{kind}_768.png"
                key = next((name for name in names if name.endswith("/" + filename) or name == filename), None)
                if key is None:
                    raise ValueError(f"Missing texture: {filename}")
                data = archive.read(key)
                if data[:8] != b"\x89PNG\r\n\x1a\n":
                    raise ValueError(f"Not a PNG: {filename}")
                width, height = struct.unpack(">II", data[16:24])
                if (width,height) != (768,768):
                    raise ValueError(f"Unexpected dimensions: {filename}: {(width,height)}")
                (textures / filename).write_bytes(data)
                verified[filename] = hashlib.sha256(data).hexdigest()
    out = {
        "status": "CANDIDATE_ONLY",
        "glb": GLB_NAME,
        "original_glb_sha256": EXPECTED_GLB_SHA256,
        "textures": len(FAMILIES) * len(MAPS),
        "verified_files": verified,
        "source_zip": str(pack),
        "warning": "The full-size GLB is staged, but only explicit visual review should activate it in the playable scene."
    }
    (destination / "M6_IMPORT_MANIFEST.json").write_text(json.dumps(out,indent=2),encoding="utf-8")
    return out

if __name__ == "__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--pack",type=Path,required=True)
    parser.add_argument("--dest",type=Path,default=Path("godot/assets/m6"))
    args=parser.parse_args()
    result=stage(args.pack,args.dest)
    print(f"Verified and staged {len(result['verified_files'])} M6 source assets to {args.dest}")
