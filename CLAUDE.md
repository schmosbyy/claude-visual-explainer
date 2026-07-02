# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

`visual-explainer` is a **Claude Code skill (plugin)**, not an application. There is no build system, package manager, test suite, or runtime dependency — the "code" is a skill definition plus an HTML template and widget snippets that Claude assembles per-request. The payload files ARE the product:

- `SKILL.md` — skill entry point. Its frontmatter (`name`, `model: sonnet`, `effort: high`, `allowed-tools`, `description`) controls when/how the skill fires and what it can do without permission prompts; the body is the workflow Claude follows. Note `model: sonnet` overrides the session model while the skill runs.
- `reference.md` — the widget library (heatmap, prob-bars, stepper, flow-diagram), the shared `heatColor` helper, and the "Robustness contract".
- `assets/template.html` — the base page. Has fill-in slots (`{{TITLE}}`, `{{SUBTITLE}}`, `{{TLDR}}`) plus `SECTIONS` and `WIDGET SCRIPTS` comment markers, a baked-in dependency-free scroll-spy ToC `<script>`, and CSS design tokens as `:root` custom properties.
- `scripts/open-explainer.sh` — copies the finished HTML into the fixed cache dir and opens it in the browser.
- `.claude-plugin/plugin.json` — the plugin manifest.

## CRITICAL: two locations, keep them in sync

The live skill is a **separate copy** at `~/.claude/skills/visual-explainer/`, not a symlink to this repo. Edits made here do NOT take effect until mirrored there (currently in sync). After changing any payload file, mirror it:

```bash
rsync -a --exclude=.git --exclude=.claude --exclude=.DS_Store ./ ~/.claude/skills/visual-explainer/
```

Then start a fresh Claude Code session to pick up the change.

## Hard invariants (the skill's whole point — don't break these)

1. **One self-contained HTML file, zero network dependencies.** No CDN `<script src>`/`<link>`. The page must work from `file://`. Vendor an inline snippet only if a library is truly required.
2. **Fixed output path:** `~/.cache/claude-explainers/<slug>.html`. Never use `$TMPDIR`/`/tmp` — the path must be stable so `SKILL.md`'s pre-approved `Write(~/.cache/claude-explainers/**)` permission glob keeps matching; a temp path re-triggers a permission prompt every run.
3. **Robustness contract** (see `reference.md`): every widget — snippet or hand-rolled — is its **own** top-level `<script>` with its body wrapped in `try{…}catch(e){console.error(e)}`. Never merge two widgets, or a widget and the template's ToC script, into one block, so one widget's bug can only blank its own section.
4. Before shipping, confirm every `getElementById`/`querySelector` target in the JS actually exists in the markup — a `null` lookup on the next line is the #1 way these pages break.

## How a request flows

Claude picks 1–3 widgets from `reference.md` → copies `assets/template.html` → fills the slots + `SECTIONS` marker → pastes each widget's `<script>` as its own try/catch block (including `heatColor` once if any heat widget is used) → writes to the cache path → runs `scripts/open-explainer.sh`. The `frontend-design` skill is consulted for palette/typography **if available**, else skipped — the bundled template must stand alone. An optional ELI5 follow-up (a second, simpler standalone file of the same topic) is a runtime behavior defined in `SKILL.md`.

## Commands

No build/test/lint commands exist. The only executable:

```bash
# Preview a generated explainer (this is the skill's step 5):
bash scripts/open-explainer.sh ~/.cache/claude-explainers/<slug>.html

# Override the browser opener (or relay from a headless/SSH host):
OPENER="firefox" bash scripts/open-explainer.sh <file>.html
```

To develop the skill itself: edit the files here → mirror to `~/.claude/skills/visual-explainer/` → trigger the skill from a new session → verify the generated HTML opens error-free.
