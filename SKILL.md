---
name: visual-explainer
model: sonnet
effort: high
allowed-tools:
  - Write(~/.cache/claude-explainers/**)
  - Edit(~/.cache/claude-explainers/**)
  # Step 5's body command uses ${CLAUDE_SKILL_DIR} so the script resolves at any install
  # location; this literal entry pre-approves the common ~/.claude personal install
  # (${CLAUDE_SKILL_DIR} is not expanded inside allowed-tools matchers, so other install
  # locations simply prompt once on open).
  - Bash(bash ~/.claude/skills/visual-explainer/scripts/open-explainer.sh:*)
description: >-
  Use when the user asks to explain something visually, "show me visually",
  "visualize how X works", wants an interactive diagram / animation / explainer,
  or says "make it visual" / "draw this out". The output is a single self-contained
  interactive HTML file that opens in the user's browser.
---

# Visual Explainer

Produce a single self-contained interactive HTML page that explains a topic, and open it in
the user's browser. Encode the plumbing; spend effort on *what to visualize*.

## When to fire
- **Explicit** visual-request phrasing → build now.
- **Borderline** (a genuinely complex concept explained without a visual ask) → end your reply
  with ONE offer: "Want this as an interactive visual you can click through?" Build only on yes.
  Never auto-build on borderline.

## Hard rules
- ONE file. Inline CSS + JS. ZERO network dependencies (no CDN `<script src>`/`<link>`). A
  network asset breaks `file://`. Vendor a minimal inline snippet if a lib is truly needed.
- Save to `~/.cache/claude-explainers/<slug>.html` — a FIXED home path. Do NOT use `$TMPDIR`
  or `/tmp`; their real location varies per OS/session, which makes the pre-approved write rule
  miss and re-triggers a permission prompt. The helper opens this path in place.
- Open in the browser only. Do NOT post a screenshot into chat.
- Lead with a 1–3 sentence plain-language TL;DR in the `{{TLDR}}` slot: state the main
  point before any concept or widget; avoid undefined jargon (define unavoidable terms inline).

## Workflow
1. Settle topic + audience (default: technical reader new to it). One quick question only if
   genuinely ambiguous.
2. Plan 4–8 sections. Pick 1–3 widgets from `reference.md` that fit (heatmap / prob-bars /
   stepper / flow-diagram), or hand-roll SVG/CSS for anything else.
3. Copy `assets/template.html`. Replace `{{TITLE}}`/`{{SUBTITLE}}`/`{{TLDR}}`, add one `<section>` per
   concept in the SECTIONS slot, paste chosen widgets + their scripts (include the shared
   `heatColor` helper once if any heat widget is used). Adapt each widget's DATA block. Paste
   each widget's `<script>` as its own `try/catch`-wrapped block — never merged with another
   widget or the ToC script — so one widget's bug can't blank the rest of the page (see
   `reference.md` → "Robustness contract").
4. If the `frontend-design` skill is available, invoke it for palette/typography direction.
   Skip silently if not. The bundled template must work on its own.
5. Verify before you ship: re-read your JS and confirm every `getElementById`/`querySelector`
   target exists in the markup, and that each widget is its own `try/catch`-wrapped `<script>`
   (a missing target is the #1 way these pages break — see `reference.md` → "Robustness contract").
   Then write the file to `~/.cache/claude-explainers/<slug>.html` and run:
   `bash ${CLAUDE_SKILL_DIR}/scripts/open-explainer.sh ~/.cache/claude-explainers/<slug>.html`
   If you have a tool that can render local HTML, open it and confirm the console is error-free
   before reporting done; otherwise rely on the audit above.
6. Tell the user the file path and one line on what's interactive. If the open command failed
   (headless/SSH), relay the helper's fallback instead of claiming it opened. End that same
   message with the ELI5 offer from step 7.
7. **Optional follow-up — ELI5.** End the open reply with one short offer, e.g. "Want a
   plain-language ELI5 version too — same idea, no jargon (handy if any of that didn't land)?"
   **On yes:** build a *standalone* simpler explainer of the SAME topic (lead with an everyday
   analogy, define or drop every term, fewer/lighter widgets), write it to
   `~/.cache/claude-explainers/<slug>-eli5.html` (covered by the same pre-approved write glob),
   and open it with the step-5 helper. Leave the original file untouched — a second file, not a
   rewrite.
