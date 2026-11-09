#!/usr/bin/env bash
# Standalone Godot Web export from the authoritative Alchul repository.
# Installs only the official Godot toolchain; never fetches another user project.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT="$REPO_ROOT/godot"
OUT="$PROJECT/build/web"
VERSION="4.7.2-stable"
ENGINE_SHA256="cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

python3 "$PROJECT/tools/validate_worldbook.py"

if [ -n "${GODOT_BIN:-}" ]; then
  BIN="$GODOT_BIN"
else
  curl -fsSL --retry 3 "https://github.com/godotengine/godot/releases/download/$VERSION/Godot_v${VERSION}_linux.x86_64.zip" -o "$TEMP/engine.zip"
  printf '%s  %s\n' "$ENGINE_SHA256" "$TEMP/engine.zip" | sha256sum -c -
  unzip -q "$TEMP/engine.zip" -d "$TEMP/engine"
  BIN="$TEMP/engine/Godot_v${VERSION}_linux.x86_64"
  chmod +x "$BIN"
fi

if [ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/4.7.2.stable/web_nothreads_release.zip" ]; then
  curl -fsSL --retry 3 "https://github.com/godotengine/godot/releases/download/$VERSION/Godot_v${VERSION}_export_templates.tpz" -o "$TEMP/templates.tpz"
  unzip -q "$TEMP/templates.tpz" -d "$TEMP/export"
  test -d "$TEMP/export/templates"
  target="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/4.7.2.stable"
  mkdir -p "$target"
  cp -a "$TEMP/export/templates/." "$target/"
fi

"$BIN" --headless --path "$PROJECT" --editor --import --quit
mkdir -p "$OUT"
"$BIN" --headless --path "$PROJECT" --export-release Web "$OUT/index.html"

test -s "$OUT/index.html"
test -s "$OUT/index.js"
test -s "$OUT/index.pck"
test -s "$OUT/index.wasm"
printf 'ALCHUL_WEB_EXPORT_PASS\n'
ls -lh "$OUT"
