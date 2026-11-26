# OpenSCAD AI Skill: 3D-printable parts from a description

Describe a part ("a 30 mm spacer for an M4 bolt", "a wall hook for a 25 mm broom handle") and
an AI writes parametric [OpenSCAD](https://openscad.org/) code for it. It lists every dimension
it had to guess, checks the part is printable, and helps you export an STL.

It works with **any AI**:

| You use | Setup | Time |
|---|---|---|
| **ChatGPT, Gemini, Copilot, any chat AI** (free tiers work) | Paste [`portable/CHAT-INSTRUCTIONS.md`](portable/CHAT-INSTRUCTIONS.md) as your first message | 30 seconds |
| **Claude Desktop / claude.ai** | Download `openscad-skill.zip` from [Releases](../../releases/latest), then Settings → Capabilities → Skills → Upload | 1 minute |
| **Claude Code** | `git clone https://github.com/Romatomato1/openscad-ai-skill ~/.claude/skills/openscad` | 1 minute |
| **Codex CLI, Gemini CLI, other agents that read SKILL.md** | Clone into that agent's skills folder | 1 minute |

Full per-platform steps: [`portable/README.md`](portable/README.md).

## How you get the STL
- **Agents with a shell** (Claude Code, Codex, etc., with OpenSCAD installed) render, validate
  and export by themselves.
- **Chat AIs** give you one self-contained `.scad` file. Paste it into
  [OpenSCAD Playground](https://ochafik.com/openscad2) (in the browser, no install) or desktop
  OpenSCAD, render it, and export the STL. If something looks wrong, send the AI the console
  errors or a screenshot.

## Open it in Bambu Studio
Ask an agent to "open it in Bambu Studio" (or OrcaSlicer). It runs
`scripts/openscad-send-to-slicer.sh`, which opens the STL/3MF in the slicer installed on your
computer (Windows, WSL, macOS, Linux and Flatpak). It **only opens** the file. It never slices,
prints or talks to your printer, so you still review and press print yourself. In chat mode,
double-click the downloaded STL or drag it onto Bambu Studio.

## Before your first print
Edit the **My printer** block at the top of `CHAT-INSTRUCTIONS.md`, or
`templates/printer-profile.scad` for agents: bed size, nozzle, material. The default hole
clearances are guesses until you print `templates/calibration-comb.scad` once and measure it.
The header of that file explains how.

## What's inside
- `SKILL.md`: the full skill for agents. It has nine modes (Quick, Modify, Design, Replicate,
  Reconstruct, Refine, Export, Analyze, Send to Slicer) and adapts to what the AI can actually run.
- `portable/`: the chat-only prompt, setup guide and bundle builder.
- `scripts/`: render, validate, compare and STL-analysis helpers (bash; Python for reconstruction).
- `templates/`: a printable-parts library, the printer profile, a calibration comb and starter parts.
- `references/`: an OpenSCAD language cheat sheet and an STL reconstruction guide.

## Security
Read [SECURITY.md](SECURITY.md) before you let an agent run the scripts. In short, they run
only locally, make no network calls, and write only to `~/openscad-projects/` and temp folders.

## Credits
Adapted from [andreahaku/openscad_claude_skill](https://github.com/andreahaku/openscad_claude_skill)
(MIT). This fork adds the multi-AI support and chat mode. Its original README is in
[`docs/original-README.md`](docs/original-README.md). License: [MIT](LICENSE).
