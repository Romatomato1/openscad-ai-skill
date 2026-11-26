#!/usr/bin/env bash
# build-bundles.sh: package the openscad skill for assistants other than Claude Code.
#
#   dist/openscad-skill.zip   upload to Claude Desktop / claude.ai
#                             (Settings > Capabilities > Skills > Upload skill)
#   dist/chat-knowledge/      files to attach to a ChatGPT Project / Custom GPT,
#                             a Gemini Gem, or a Claude.ai Project
#
# Usage: bash portable/build-bundles.sh
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$SKILL_DIR/portable/dist"
rm -rf "$DIST"
mkdir -p "$DIST/chat-knowledge"

# --- 1. Skill zip: a top-level openscad/ folder containing SKILL.md ----------
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/openscad/portable"
cp -r "$SKILL_DIR/SKILL.md" "$SKILL_DIR/README.md" "$SKILL_DIR/LICENSE" "$SKILL_DIR/SECURITY.md" "$SKILL_DIR/references" \
      "$SKILL_DIR/scripts" "$SKILL_DIR/templates" "$STAGE/openscad/"
cp "$SKILL_DIR/portable/CHAT-INSTRUCTIONS.md" "$SKILL_DIR/portable/README.md" "$STAGE/openscad/portable/"

if command -v zip >/dev/null 2>&1; then
    (cd "$STAGE" && zip -qr "$DIST/openscad-skill.zip" openscad)
elif command -v powershell.exe >/dev/null 2>&1; then
    # Not Compress-Archive: PowerShell 5.1 writes backslash entry names that Linux unzippers reject.
    SRC_W="$(cygpath -w "$STAGE")"; ZIP_W="$(cygpath -w "$DIST/openscad-skill.zip")"
    powershell.exe -NoProfile -Command "
        Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
        \$root = (Get-Item '$SRC_W').FullName; \$zip = [IO.Compression.ZipFile]::Open('$ZIP_W', 'Create')
        Get-ChildItem -Path (Join-Path \$root 'openscad') -Recurse -File | ForEach-Object {
            \$name = \$_.FullName.Substring(\$root.Length).TrimStart('\\').Replace('\\', '/')
            [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile(\$zip, \$_.FullName, \$name)
        }
        \$zip.Dispose()"
else
    python3 -c "import shutil,sys; shutil.make_archive(sys.argv[1], 'zip', sys.argv[2], 'openscad')" \
        "$DIST/openscad-skill" "$STAGE"
fi

# --- 2. Knowledge files for plain chat AIs ------------------------------------
cp "$SKILL_DIR/portable/CHAT-INSTRUCTIONS.md"           "$DIST/chat-knowledge/"
cp "$SKILL_DIR/references/language-reference.md"         "$DIST/chat-knowledge/openscad-language-reference.md"
cp "$SKILL_DIR/templates/printable-lib.scad"             "$DIST/chat-knowledge/printable-lib.scad.txt"
cp "$SKILL_DIR/templates/printer-profile.scad"           "$DIST/chat-knowledge/printer-profile.scad.txt"
cp "$SKILL_DIR/templates/calibration-comb.scad"          "$DIST/chat-knowledge/calibration-comb.scad.txt"
# .txt suffix: some chat uploaders reject unknown extensions like .scad

echo "Built:"
echo "  $DIST/openscad-skill.zip"
echo "  $DIST/chat-knowledge/ ($(ls "$DIST/chat-knowledge" | wc -l | tr -d ' ') files)"
