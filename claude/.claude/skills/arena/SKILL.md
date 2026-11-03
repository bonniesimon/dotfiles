---
name: arena
description: "Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Use for /arena, 'arena this', 'throw it in the arena', or when one attempt at a non-trivial artifact would lock in the wrong shape."
disable-model-invocation: true
---

# Arena

Adapted from cursor/plugins pstack/skills/arena for Claude Code.

Track one todo per phase (Frame, Fan out, Cross-judge, Pick, Graft, Verify) before launching anything.

## Output rules

- Everything the arena writes lands as local files in `../misc` (the `misc` folder beside the repo root). Never publish through the Artifact tool or Claude Docs.
- The default candidate artifact is a **plan file** (`.md`). Candidates implement only when the plan cannot be verified without running code (a spike, a perf claim, a "does this compile/pass" question). The framer decides this in Phase A and states it in the prompt.
- Human-facing reports (comparison, synthesis note) are local `.html` files with a copy handler that rebuilds Markdown on copy, so pasted text keeps its formatting.

## Phase A: Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing: plan file, or implementation (with the reason a plan cannot be verified).
2. Derive the rubric, 3-6 concrete gradeable criteria for what success looks like on *this* task. It is the picker's tool in Phase D. Candidates only see the task.
3. Pick the runners with the Agent tool's `model` param. Default: two runners, one `opus` and one `fable`, for family-of-thought diversity. Spawn more runners when the arena covers multiple design directions; give each a named direction. Use the same model N times when the work is generation-bound rather than judgment-sensitive. If a model is rejected, run that seat on the parent model (omit `model`) and say so.
4. Give each candidate its own output location:
   - Plan: `../misc/arena-<slug>/candidate-<n>.md`.
   - Implementation: `isolation: "worktree"` on the Agent call, plus a rationale file at `../misc/arena-<slug>/candidate-<n>.md`.
   Separate locations before anything is serialized, so candidates never see or overwrite each other.

## Phase B: Fan out

Spawn all N subagents in one message with `run_in_background: true`, each with the task, the paths to the shared grounding (files, tickets, plans), its own output path, and instructions to produce the artifact and a short rationale naming the alternatives it considered and what it rejected.

If a candidate produces no output, proceed with N-1 and note the dropout.

## Phase C: Cross-judge

After all Phase B candidates complete, spawn one readonly judge subagent (`general-purpose`, told to write nothing) on a model different from the parent: `fable` when the parent is Opus, `opus` otherwise; fall back to `sonnet`. If no different model runs, skip the judge, pick the base alone in Phase D, and say so. The judge sees the rubric and the candidates by path label only (no model names), scores each criterion, and recommends a base with rationale. It runs in parallel with your reading in Phase D. Don't spawn it while candidates are still writing.

## Phase D: Pick a base

Read every candidate end to end before picking. Score each against the rubric criterion by criterion, not on holistic feel, and compare with the cross-judge when Phase C ran one. Agreement on the base confirms the pick. Disagreement means one of you is biased or the rubric was ambiguous. Read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking invariants. When two feel tied, prefer the cleaner boundary or smaller API.

## Phase E: Graft

Walk each losing candidate once more for what is worth porting into the base, usually one or two things per candidate, not most of it. Fold each graft in by hand, rewriting it to fit the base's model, so the result stays coherent under one mental model. Don't paste mechanically.

If the candidates converge on one shape, that is strong agreement. Note it and ship the consensus shape. No graft is needed. If they wildly diverge, Phase A was under-specified. Reframe and re-run rather than averaging the divergence.

## Phase F: Verify

Verify the synthesized artifact with evidence, not assertion: for a plan, check every file, symbol, and claim it names against the codebase; for an implementation, run the tests and show the output. If verification finds a problem the arena missed, either Phase A was wrong (re-frame and re-run) or a candidate caught it and you missed the graft (go back to Phase E). Don't paper over it.

## Outputs

All in `../misc/arena-<slug>/`:

- `final.md`: the synthesized plan (or a pointer to the base worktree branch when implemented).
- `synthesis.html`: rubric scores per candidate, the base and why, the cross-judge's verdict or that Phase C skipped the judge, each graft with its source candidate, what was rejected and why, any convergence or dropouts, and the verification result.

End by giving the user both paths.
