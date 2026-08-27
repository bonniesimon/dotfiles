---
name: pr-description
description: The authoritative rules and shape for a GitHub PR body in this account. Use whenever composing, editing, or reviewing a pull request description, including from draft-pr, gh-stack, or a direct "write the PR body" request.
---

This skill is the single source of truth for PR body content. Any skill that
creates or edits a PR body defers to it. Skills that create PRs own only the
mechanics (branch, push, `gh` invocation), never the wording.

## The shape

A body is short. Target 3 to 8 lines of prose total, before any checkboxes.

```
- Jira: <url, or "no ticket" if genuinely none>

## Change Description
<1-3 sentences: what changed, and why it was worth changing. Intent, not mechanism.>

<optional, only if a genuine open decision exists:>
**Confirm before merge:** <the one question a reviewer must answer.>
```

Nothing else. No "Testing" narration, no "Files changed", no summary of the
commits.

## Rules

- Never fabricate intent. Intent comes from the session, the ticket, or the
  user. If none of the three has it, ask.
- Never list changed files. The diff already does.
- Never narrate code changes. "Extracted X into Y, renamed Z" is diff
  restatement, not a description.
- Never speculate on risk. A risk you actually verified is a fact and may be
  stated in one line; a risk you imagined is noise.
- No `Co-Authored-By`, no "Generated with Claude Code" footer.
- Title follows the repo's existing convention. Check `git log --oneline`.
- If the diff is self-explanatory, fewer lines is better. One sentence is a
  legitimate, complete PR body.

Goal: a reviewer reads it in 10 seconds and knows what to look at.

## Handling a repo PR template

A `.github/pull_request_template.md` supplies *structure*, never *voice*. Its
placeholders are prompts aimed at a human, and following them literally is the
main way these rules get broken.

Before filling a template:

1. Delete every `<!-- ... -->` comment.
2. Delete every `[bracketed placeholder]`.
3. Keep checkboxes verbatim, including unchecked ones. Tick what applies.
4. Delete whole sections the change does not touch, when the template says they
   are conditional (e.g. a migration checklist on a no-migration PR).

A section header is not permission to write more. If a section would only
restate the diff, leave it to one line or drop it.

## Required check before creating the PR

Compose the body into a file, then re-read it once against this list and cut
what fails:

- Does any line name a file, class, or method purely to say it changed? Cut.
- Does any line restate what the diff shows? Cut.
- Does any line speculate about a risk you did not verify? Cut.
- Is the intent traceable to the session, ticket, or user? If not, ask instead
  of guessing.
- Is there a Claude footer or co-author trailer? Remove.

Only then create the PR.

See `references/examples.md` for worked before/after bodies.
