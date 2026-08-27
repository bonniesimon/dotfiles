---
name: make-plan
description: Explore the task, write an implementation plan to a markdown file, then STOP. Use when the user says "make a plan", "plan this", "write a plan", or invokes /make-plan. Pairs with refine-plan (user leaves Q: markers) and archive-plans.
---

Goal: produce reviewable plan in markdown. NO implementation. Stop after writing file.

## Steps

1. Get ticket id. Ask user if not given. Use `KAN-XXXX` in filename. No ticket = `<short-slug>-plan.md`.

2. Explore first. Delegate to `Explore` or `cavecrew-investigator` subagent for file-finding so raw file dumps stay out of main context. Only conclusion returns.

3. Write plan to `KAN-XXXX-<short-slug>-plan.md` in ~/dev/glomopay/misc. Structure:
   - `## Goal` — one line, what + why.
   - `## Context` — key files as `path:line`. No pasted code blocks. Cite, don't copy.
   - `## Approach` — ordered steps. Each step = file + change.
   - `## Open questions` — leave `Q: <question>` markers for user. refine-plan skill answers these.
   - `## Out of scope` — what this does NOT touch.

4. STOP. Do not edit/write app code. Tell user: plan at `<path>`, review + leave answers after `Q:` markers, then run `/refine-plan` or say go.

## Rules

- Plan tight. Reload cost = file size every turn. No filler, no restated code.
- Flag inference vs source. Mark guesses `QUESTION:`.
- Multi-file / schema / security change → always plan first.
- Never start coding in same turn as plan write. Wait for explicit go.
