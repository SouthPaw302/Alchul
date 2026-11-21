#!/usr/bin/env bash
# Build genuine standalone ALCHUL desktop apps from this exact Godot project.
# GitHub Actions exports Windows x64, Linux x64, and unsigned macOS universal.
# No dependency on the website or any separately-installed Godot editor.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT="$REPO_ROOT/godot"
OUT="$PROJECT/build/desktop"
VERSION="4.7.2-stable"
ENGINE_SHA256="cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4"
TEMPLATES_VERSION="4.7.2.stable"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

python3 "$PROJECT/tools/validate_worldbook.py"

if [ -n "${GODOT_BIN:-}" ]; then
  BIN="$GODOT_BIN"
else
  curl -fL --retry 3 \
    "https://github.com/godotengine/godot/releases/download/$VERSION/Godot_v${VERSION}_linux.x86_64.zip" \
    -o "$TEMP/engine.zip"
  echo "$ENGINE_SHA256  $TEMP/engine.zip" | sha256sum -c -
  unzip -q "$TEMP/engine.zip" -d "$TEMP/engine"
  BIN="$TEMP/engine/Godot_v${VERSION}_linux.x86_64"
  chmod +x "$BIN"
fi

TEMPLATES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$TEMPLATES_VERSION"
if [ ! -f "$TEMPLATES_DIR/windows_release_x86_64.exe" ] || \
   [ ! -f "$TEMPLATES_DIR/linux_release.x86_64" ] || \
   [ ! -f "$TEMPLATES_DIR/macos.zip" ]; then
  curl -fL --retry 3 \
    "https://github.com/godotengine/godot/releases/download/$VERSION/Godot_v${VERSION}_export_templates.tpz" \
    -o "$TEMP/templates.tpz"
  sha256sum "$TEMP/templates.tpz" > "$TEMP/templates_download.sha256"
  unzip -q "$TEMP/templates.tpz" -d "$TEMP/unpacked"
  test -d "$TEMP/unpacked/templates"
  mkdir -p "$TEMPLATES_DIR"
  cp -a "$TEMP/unpacked/templates/." "$TEMPLATES_DIR/"
fi

mkdir -p "$OUT/windows" "$OUT/linux" "$OUT/macos" "$OUT/packages"
"$BIN" --headless --path "$PROJECT" --editor --import --quit

# Godot's release exporter combines the official Godot executable with this
# project's resource pack. The Windows/Linux preset embeds the PCK.
"$BIN" --headless --path "$PROJECT" --export-release "Windows Desktop" "$OUT/windows/Alchul.exe"
"$BIN" --headless --path "$PROJECT" --export-release "Linux" "$OUT/linux/Alchul.x86_64"
"$BIN" --headless --path "$PROJECT" --export-release "macOS" "$OUT/macos/Alchul-macOS.zip"

test -s "$OUT/windows/Alchul.exe"
test -s "$OUT/linux/Alchul.x86_64"
test -s "$OUT/macos/Alchul-macOS.zip"
chmod +x "$OUT/linux/Alchul.x86_64"
file "$OUT/windows/Alchul.exe" | grep -E 'PE32|MS Windows'
file "$OUT/linux/Alchul.x86_64" | grep -q 'ELF 64-bit'
unzip -tq "$OUT/macos/Alchul-macOS.zip"
unzip -Z1 "$OUT/macos/Alchul-macOS.zip" | grep -q '\.app/Contents/MacOS/'
unzip -Z1 "$OUT/macos/Alchul-macOS.zip" | grep -q 'Info.plist'

cat > "$OUT/packages/README_START_HERE.txt" <<'DOC'
ALCHUL — THE BRAIDED REACH
Chapter I: Complete Exploratory Game · Release 1.0
==================================================
A finite, offline Godot desktop game using our current first-party
ALCHUL world assets. This is a complete four-site field expedition,
not a finished reconstruction of ALCHUL's entire 66-million-year history.
Biological and historical proposals remain provisional.

WINDOWS (x64):
  Extract ALCHUL_Windows_x64.zip, then double-click Alchul.exe.
LINUX (x64):
  Extract ALCHUL_Linux_x64.zip and launch ./Alchul.x86_64.
  If necessary run: chmod +x Alchul.x86_64
MACOS (universal Intel + Apple Silicon):
  Extract ALCHUL_macOS_Universal.zip and open the Alchul.app bundle.
  This is an UN-SIGNED, UN-NOTARIZED developer export.
  Gatekeeper may block it; production distribution needs code signing.

THE GAME:
  1. Select "Begin expedition" or "Continue saved journey".
  2. Find four orange map pins: bank, nursery, Harvest, witnesses.
  3. Press E by a marker to add its evidence to the field journal.
  4. Read differing Outside, Resident and Contact interpretations.
  5. After all four, revisit the river-reading station and press E
     to complete the expedition. Replay or keep exploring afterward.

CONTROLS:
  WASD / arrows walk         Right mouse drag look
  Shift faster travel       E inspect site
  TAB journal               H help
  ESC pause / resume        1 / 2 / 3 switch interpretive lens

Your progress is stored OFFLINE on the local computer in Godot's
user data directory. No accounts, web connection or Godot editor.
These early artifacts are first-party preview materials and
should not be mistaken for fossil evidence or finished canon.
DOC

# Package runnable payloads, README, provenance, and SHA256 manifests.
GIT_REV="${GITHUB_SHA:-$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)}"
python3 - "$OUT" "$GIT_REV" <<'PY'
import hashlib
import json
import pathlib
import sys
import zipfile

out = pathlib.Path(sys.argv[1])
sha = sys.argv[2]
builds = {
    "Windows_x64": out / "windows" / "Alchul.exe",
    "Linux_x64": out / "linux" / "Alchul.x86_64",
    "macOS_Universal": out / "macos" / "Alchul-macOS.zip",
}
description = {
    "app_name": "ALCHUL — The Braided Reach",
    "version": "Chapter I / 1.0.0",
    "godot_engine_version": "4.7.2-stable",
    "git_commit": sha,
    "status": "COMPLETE_CHAPTER_NONCANONICAL_RECONSTRUCTION",
    "unsigned_unnotarized": True,
    "platforms": {},
}
for name, file in builds.items():
    raw = file.read_bytes()
    description["platforms"][name] = {
        "payload": file.name,
        "bytes": len(raw),
        "sha256": hashlib.sha256(raw).hexdigest(),
    }
(out / "packages" / "DESKTOP_BUILD_PROVENANCE.json").write_text(
    json.dumps(description, indent=2) + "\n", encoding="utf8"
)
for label in ("Windows_x64", "Linux_x64"):
    payload = builds[label]
    archive = out / "packages" / ("ALCHUL_" + label + ".zip")
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        z.write(payload, payload.name)
        z.write(out / "packages" / "README_START_HERE.txt", "README_START_HERE.txt")
        z.write(out / "packages" / "DESKTOP_BUILD_PROVENANCE.json", "DESKTOP_BUILD_PROVENANCE.json")
# Native Godot macOS export is already an app ZIP, not a PCK-only export.
mac_src = builds["macOS_Universal"]
mac_dest = out / "packages" / "ALCHUL_macOS_Universal.zip"
mac_dest.write_bytes(mac_src.read_bytes())
for path in sorted((out / "packages").glob("ALCHUL_*.zip")):
    with zipfile.ZipFile(path) as check:
        if check.testzip() is not None:
            raise RuntimeError("Packaging failed ZIP CRC validation: " + str(path))
    print("ALCHUL_DESKTOP_PACKAGE:", path.name, path.stat().st_size)
for path in sorted((out / "packages").glob("ALCHUL_*.zip")):
    (out / "packages" / (path.name + ".sha256")).write_text(
        hashlib.sha256(path.read_bytes()).hexdigest() + "  " + path.name + "\n", encoding="ascii"
    )
PY
echo "ALCHUL_DESKTOP_EXPORT_PASS"
ls -lh "$OUT/packages/"
