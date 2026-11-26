# Using the OpenSCAD skill with any AI

The skill has two forms:

- **Full skill** (`../SKILL.md`, scripts and templates). For assistants that can run commands.
  The AI renders, validates and exports by itself.
- **Chat prompt** (`CHAT-INSTRUCTIONS.md`, about 6.4k characters). For any chat AI. The AI writes
  the `.scad` file and you render it.

Build the upload bundles first:

```bash
bash ~/.claude/skills/openscad/portable/build-bundles.sh
```

This creates `portable/dist/openscad-skill.zip` and `portable/dist/chat-knowledge/`.

---

## Pick your setup

| Assistant | Form | Who renders |
|---|---|---|
| Claude Code (CLI, or the Code tab in Claude Desktop) | Full skill, already installed in `~/.claude/skills` | the AI |
| Claude Desktop / claude.ai chat | Full skill, uploaded as a zip | you, unless the sandbox can install OpenSCAD |
| Codex CLI, Gemini CLI, other agents that read `SKILL.md` | Full skill, copied into that agent's skills folder | the AI |
| ChatGPT (free or paid) | Chat prompt | you |
| Gemini, Copilot, DeepSeek, Le Chat, etc. | Chat prompt | you |

### Claude Desktop / claude.ai
1. Settings → Capabilities: turn on **Code execution and file creation**.
2. Settings → Capabilities → **Skills** → Upload skill → `dist/openscad-skill.zip`.
3. Ask for a part as usual. The skill checks whether its sandbox can install OpenSCAD. If it
   can't, it switches to chat mode and gives you a single `.scad` file to render.

For full local rendering in the Desktop app, use the **Code** tab instead. It is Claude Code,
so it already reads `~/.claude/skills/openscad`.

### ChatGPT
Pick one way:
- **Project** (available on the free plan): create a project, paste `CHAT-INSTRUCTIONS.md` into
  the project instructions, and attach the files in `dist/chat-knowledge/`.
- **Custom GPT** (creating one needs a paid plan): paste the prompt into *Instructions*
  (8,000-character limit) and upload `dist/chat-knowledge/` as *Knowledge*.
- **No setup**: paste the whole `CHAT-INSTRUCTIONS.md` as the first message of a chat, then
  describe the part.

### Gemini
Create a **Gem**, paste the prompt into its instructions, and add the knowledge files. You can
also paste the prompt at the start of a chat.

### Any other chat AI
Paste `CHAT-INSTRUCTIONS.md` as the first message. Attach the knowledge files if the chat
accepts uploads.

### Other agent CLIs
Copy the whole `openscad/` folder into that agent's skills folder (for example
`~/.codex/skills/openscad`). The scripts find their own directory, so no paths need editing.
The agent needs `openscad` on PATH or `OPENSCAD_BIN` set.

---

## Rendering when the AI can't (chat mode loop)

1. Copy the `.scad` code the AI gives you.
2. Open it in **OpenSCAD** (desktop) or **https://ochafik.com/openscad2** (browser, no install).
3. Render it (F6 on desktop). If there are errors, paste the console text back to the AI.
4. To check the shape, send a screenshot to an AI that can see images.
5. Export the STL (F7 on desktop, or the download button in the web version).

## Keep the printer block in sync
`CHAT-INSTRUCTIONS.md` has a **My printer** block with plain numbers. The full skill reads
`templates/printer-profile.scad`. After you print and measure `calibration-comb.scad`, update
**both**, then rebuild the bundles and re-upload them.
