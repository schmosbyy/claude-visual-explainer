# visual-explainer

> A [Claude Code](https://docs.claude.com/en/docs/claude-code) skill that turns an explanation into a single self-contained, interactive HTML page — and opens it in your browser.

This is a **skill (plugin)**, not an application. There's no build step, runtime, or dependency. The "code" is a skill definition plus an HTML template and reusable widget snippets that Claude assembles per request.

## What it produces

When you ask Claude to *"explain X visually"*, *"visualize how X works"*, or *"make this visual"*, the skill generates **one standalone `.html` file** with everything inlined — CSS, JS, and data — and opens it in your default browser. No screenshots dumped in chat; a real page you can click through.

Key properties of every page it makes:

- **One file, zero network dependencies.** No CDN `<script src>` / `<link>`. Works straight from `file://`.
- **Plain-language TL;DR first**, before any concept or widget.
- **Robust by construction** — each widget is its own `try/catch`-wrapped `<script>`, so one widget's bug can only blank its own section, not the whole page.
- **Written to a stable path** (`~/.cache/claude-explainers/<slug>.html`) so the write stays pre-approved and doesn't re-prompt for permission.

## Widgets

Bundled in [`reference.md`](./reference.md):

| Widget | Use for |
| --- | --- |
| **heatmap** | relationship / correlation matrices |
| **prob-bars** | probabilities & distributions (with a temperature slider) |
| **stepper** | revealing a process one stage at a time |
| **flow-diagram** | labelled stages with arrows (CSS only, no JS) |

Anything else can be hand-rolled as inline SVG/CSS. A shared `heatColor` helper drives the heat-based widgets.

## Install

As a personal Claude Code skill, clone it into your skills directory:

```bash
git clone https://github.com/schmosbyy/claude-visual-explainer.git \
  ~/.claude/skills/visual-explainer
```

Then start a fresh Claude Code session and ask it to visualize something. A `.claude-plugin/plugin.json` manifest is included for plugin-style installs.

## Project layout

```
SKILL.md                 # skill entry point (frontmatter + workflow)
reference.md             # widget library + the "Robustness contract"
assets/template.html     # base page: slots, scroll-spy ToC, CSS design tokens
scripts/open-explainer.sh  # copies the finished HTML to the cache dir and opens it
.claude-plugin/plugin.json  # plugin manifest
CLAUDE.md                # notes for Claude when working on this repo itself
```

## License

None specified yet — all rights reserved by default. Open an issue if you'd like to use it under a specific license.
