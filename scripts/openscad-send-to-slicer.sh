#!/usr/bin/env bash
# openscad-send-to-slicer.sh: open an exported model in Bambu Studio (or OrcaSlicer).
#
# Usage:
#   openscad-send-to-slicer.sh <model.stl|.3mf|.obj|.step> [--slicer bambu|orca] [--dry-run]
#
# Safety: this only OPENS the file in the slicer GUI on this computer, so you can check the
# plate, filament and settings before printing. It never talks to a printer or the
# network, never slices or prints on its own, and only launches a slicer found at a known
# install location (or the executable you set in $SLICER_BIN).
#
# Platforms: Windows (Git Bash / MSYS / Cygwin), WSL, macOS, Linux (native or Flatpak).
set -euo pipefail

usage() { sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

FILE="" ; WANT="bambu" ; DRY=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --slicer) WANT="${2:-}"; shift 2 ;;
        --slicer=*) WANT="${1#*=}"; shift ;;
        --dry-run) DRY=1; shift ;;
        -h|--help) usage 0 ;;
        -*) echo "ERROR: unknown option: $1" >&2; usage 1 ;;
        *) [[ -z "$FILE" ]] || { echo "ERROR: give exactly one file" >&2; exit 1; }; FILE="$1"; shift ;;
    esac
done
[[ -n "$FILE" ]] || usage 1
case "$WANT" in bambu|orca) ;; *) echo "ERROR: --slicer must be bambu or orca" >&2; exit 1 ;; esac

# --- Validate the model file ------------------------------------------------------
[[ -f "$FILE" && ! -L "$FILE" ]] || { echo "ERROR: not a regular file: $FILE" >&2; exit 1; }
ext="$(printf '%s' "${FILE##*.}" | tr '[:upper:]' '[:lower:]')"
case "$ext" in stl|3mf|obj|step|stp) ;; *)
    echo "ERROR: unsupported file type .$ext (use .stl, .3mf, .obj or .step)" >&2; exit 1 ;;
esac
FILE="$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")"

# --- Find the slicer -------------------------------------------------------------
os="$(uname -s)"
is_wsl=0; grep -qi microsoft /proc/version 2>/dev/null && is_wsl=1

if [[ "$WANT" == bambu ]]; then
    NAME="Bambu Studio"; WIN_REL="Bambu Studio/bambu-studio.exe"; MAC_APP="BambuStudio"
    LINUX_BIN="bambu-studio"; FLATPAK_ID="com.bambulab.BambuStudio"
else
    NAME="OrcaSlicer"; WIN_REL="OrcaSlicer/orca-slicer.exe"; MAC_APP="OrcaSlicer"
    LINUX_BIN="orca-slicer"; FLATPAK_ID="io.github.softfever.OrcaSlicer"
fi

MODE="" ; EXE=""
if [[ -n "${SLICER_BIN:-}" ]]; then
    [[ -f "$SLICER_BIN" && -x "$SLICER_BIN" ]] || { echo "ERROR: SLICER_BIN is not an executable file: $SLICER_BIN" >&2; exit 1; }
    EXE="$SLICER_BIN"
    case "$os" in MINGW*|MSYS*|CYGWIN*) MODE=win ;; *) [[ $is_wsl == 1 && "$EXE" == *.exe ]] && MODE=wsl || MODE=native ;; esac
else
    case "$os" in
        MINGW*|MSYS*|CYGWIN*)
            for root in "/c/Program Files" "/c/Program Files (x86)" "$(cygpath -u "${LOCALAPPDATA:-C:/nonexistent}")/Programs"; do
                [[ -x "$root/$WIN_REL" ]] && { EXE="$root/$WIN_REL"; MODE=win; break; }
            done ;;
        Darwin)
            for app in "/Applications/$MAC_APP.app" "$HOME/Applications/$MAC_APP.app"; do
                [[ -d "$app" ]] && { EXE="$app"; MODE=mac; break; }
            done ;;
        Linux)
            if [[ $is_wsl == 1 && -x "/mnt/c/Program Files/$WIN_REL" ]]; then
                EXE="/mnt/c/Program Files/$WIN_REL"; MODE=wsl
            elif command -v "$LINUX_BIN" >/dev/null 2>&1; then
                EXE="$(command -v "$LINUX_BIN")"; MODE=native
            elif command -v flatpak >/dev/null 2>&1 && flatpak info "$FLATPAK_ID" >/dev/null 2>&1; then
                EXE="$FLATPAK_ID"; MODE=flatpak
            fi ;;
    esac
fi

if [[ -z "$MODE" ]]; then
    cat >&2 <<EOF
ERROR: $NAME not found.
  Install it from https://bambulab.com/en/download/studio (Bambu Studio)
  or https://github.com/SoftFever/OrcaSlicer/releases (OrcaSlicer),
  or set SLICER_BIN to its executable. Or open the file by hand:
  $FILE
EOF
    exit 2
fi

# --- Launch (argument arrays only; nothing is passed through a shell string) ----
case "$MODE" in
    win)     ARG="$(cygpath -w "$FILE")"; CMD=("$EXE" "$ARG") ;;
    wsl)     ARG="$(wslpath -w "$FILE")"; CMD=("$EXE" "$ARG") ;;
    mac)     CMD=(open -a "$EXE" "$FILE") ;;
    native)  CMD=("$EXE" "$FILE") ;;
    flatpak) CMD=(flatpak run --file-forwarding "$EXE" @@ "$FILE" @@) ;;
esac

if [[ $DRY == 1 ]]; then
    printf 'Would run:'; printf ' %q' "${CMD[@]}"; echo
    exit 0
fi

if [[ "$MODE" == mac ]]; then
    "${CMD[@]}"
else
    nohup "${CMD[@]}" >/dev/null 2>&1 &
    disown 2>/dev/null || true
fi

echo "Opened in $NAME: $FILE"
echo "Check the plate, filament and print settings in the slicer, then slice and print from there."
