# Security

## What the scripts do
Everything in `scripts/` runs **locally** and makes **no network requests**. The scripts:
- run `openscad` (from `$OPENSCAD_BIN` or your PATH), optionally open a file in Bambu Studio /
  OrcaSlicer (`openscad-send-to-slicer.sh`, see below), and, for Reconstruct mode only,
  `python3` with `trimesh`, `numpy`, `scipy`, `shapely` and `rtree`
- read the `.scad` / `.stl` files you point them at
- write to `~/openscad-projects/`, the output folder you pass, and `mktemp` temp folders,
  which they delete on exit

Nothing reads credentials, environment secrets or files outside those paths. Nothing
downloads or installs anything by itself. In a sandbox the skill may *ask the agent* to
install OpenSCAD with the system package manager. Your agent's permission prompts still apply.

## Recommendations
- **Read before you run.** This is plain-text bash, Python and Markdown. Skim `SKILL.md` and
  `scripts/` before you give any agent shell access with it, as you would for any skill or
  prompt from the internet.
- **Keep agent permissions tight.** In Claude Code, approve commands as they come up rather
  than allowing all of `Bash(*)` globally.
- **Treat downloaded STLs as untrusted input.** OpenSCAD only parses them as geometry, but
  keep each download in its own folder.
- **Chat mode runs nothing on your machine.** You paste code into OpenSCAD yourself. OpenSCAD
  code can't run shell commands, but it can `import()` files by path, so glance at any
  `import`/`include` lines before rendering code an AI wrote.
- **Get the skill from this repo or its Releases** so you're not running a modified copy.

## Slicer integration
`openscad-send-to-slicer.sh` only **opens** a model in the slicer GUI:
- It accepts only regular files ending in `.stl`, `.3mf`, `.obj` or `.step` (no symlinks).
- It launches only a slicer found at a standard install path, or the executable you set in
  `$SLICER_BIN`. It passes arguments as an array, never through `eval` or a shell string.
- It never slices, never starts a print, and never contacts a printer, Bambu Cloud or the
  network. You still review and print from the slicer yourself.

## Permissions
`SKILL.md` pre-approves only the read-only tools `Read`, `Glob` and `Grep`. Shell commands,
including rendering and opening the slicer, still go through your agent's normal approval
prompt.

## Reporting a vulnerability
Use GitHub's **private vulnerability reporting** (Security tab → *Report a vulnerability*).
Please don't open a public issue for security problems.
