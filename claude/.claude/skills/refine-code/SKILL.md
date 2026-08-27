---
name: refine-code
description: Address inline review comments the user left in the code as `CLAUDE:` markers. Use when the user says "refine the code", "I left comments in the code", "address my comments", or invokes /refine-code.
argument-hint: "[paths] — comments are marked `CLAUDE:` in the code (also CLAUDE(fix|q|why|all):)"
---

User left review comments in code as `CLAUDE:` tags, in file's own comment syntax. Act on each, delete tag.

Find: `rg -n --hidden -g '!.git' 'CLAUDE(\([a-z]+\))?:'`. Scope to passed paths if any. Include untracked.

Marker applies to line below, or to same line if trailing. Continuation = plain comment lines under it.

Qualifiers:
- `CLAUDE:` / `CLAUDE(fix):` — change code
- `CLAUDE(q):` — answer in chat; change code only if answer implies it
- `CLAUDE(why):` — explain original reasoning in chat, no code change
- `CLAUDE(all):` — apply same fix to every occurrence of pattern, not just here

Then:
- Read surrounding context first. Ambiguous + readings differ materially -> ask, don't guess.
- Follow repo CLAUDE.md conventions. Lint + run relevant specs.
- Delete every marker handled. Never leave one, never turn one into permanent comment.
- Report `path:line: ask -> did`. List unactioned markers + why.

No commit unless asked. No scope creep — unrelated problem spotted: mention, don't fix.
Marker asks something wrong: say so with reasoning; user reaffirms -> do it.
