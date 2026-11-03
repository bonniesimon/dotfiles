---
name: ship-it
description: End-to-end ship a change - optionally implement a given plan, then create a branch (named from the Jira ticket if given), make incremental commits, push, and open a draft PR. Use when the user says "ship it", "ship this", "ship this plan", "implement and ship", "branch commit push and PR", "take this to a PR", or wants a plan or the whole working tree turned into a draft pull request in one go.
---

Run the full pipeline: [implement] -> branch -> commits -> push -> draft PR. Each stage
after implement delegates to an existing skill. Do not reimplement their logic; read and
follow them.

Argument (optional): a Jira ticket key (e.g. `KAN-8323`), a short description, and/or a
plan (path to a plan `.md`, or plan text pasted inline).

## 0. Implement (only when a plan is given)

Skip this stage if no plan is given. Then the working tree is the change.

1. Read the whole plan. Pull the ticket key from it if the argument did not give one.
2. Do stage 1 (Branch) first, so the implementation never lands on `main`.
3. Implement the plan as written. Passing the plan to ship-it is the go-ahead: do not stop
   to ask for confirmation before writing code.
4. Stop and ask only when the plan has an open question (`Q:` marker, TBD, or two
   options with no pick) or it conflicts with the code as it is now. Do not guess
   business logic to fill a gap.
5. Follow repo rules while implementing (CLAUDE.md, `clean-design` for application code).
6. Verify before moving on:
   - `bundle exec rubocop --autocorrect <changed .rb files>`, then fix any offenses left.
   - Run the specs for changed/added files (`bundle exec rspec <spec files>`).
   - Fail = fix and re-run. If still failing after a real attempt, stop the pipeline and
     report. Do not commit red specs.
7. Summarize what was built vs the plan (anything skipped or changed, and why), then
   continue to stage 2 without waiting.

## 1. Branch

1. `git branch --show-current` and `git status`.
2. If already on a non-main feature branch, keep it. Say so and move on: back to stage 0
   step 3 if a plan was given, else to stage 2.
3. If on `main`/`master`, create a branch:
   - Ticket given: `KAN-XXXX-<short-kebab-summary>` (match recent branch names via
     `git branch -a --sort=-committerdate | head -20`).
   - Derive the kebab summary from the plan if one was given, else from the working-tree
     diff.
   - No ticket: prefix `KAN-000-`.
   - `git checkout -b <name>` — do NOT `git pull`/rebase unless the user asks.
4. If the ticket key is unknown and the change is non-trivial, ask once for the ticket
   before branching. Do not invent a ticket number other than `KAN-000`.

## 2. Commits

Follow the `incremental-commits` skill. Small logical commits, no Co-Authored-By.

If the working tree is clean and commits already exist on the branch, skip this stage.

## 3. Push

Follow the `push-branch` skill (`OVERCOMMIT_DISABLE=1`, never push main).

## 4. Draft PR

Follow the `draft-pr` skill, which itself defers to `pr-description` for title and body.

If a PR already exists for the branch (`gh pr view`), do not create a second one —
report the existing URL.

## Rules

- Stop the pipeline on the first failure and report which stage failed. Do not push
  broken commits or open a PR on top of a failed stage.
- Never run this on `main` without creating a branch first.
- One PR per run.
- With a plan, the ship-it call itself counts as approval to implement, commit, push and
  open the draft PR. That overrides the "wait for confirm before implementing" default for
  this run only.
