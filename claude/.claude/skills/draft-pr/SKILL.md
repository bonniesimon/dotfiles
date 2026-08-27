---
name: draft-pr
description: Create a GitHub draft PR for the current branch. Use when the user says "draft a PR", "draft a pull request", "open a draft PR", "create a PR", or wants to raise/open a pull request for the current branch.
---

This skill owns the mechanics only. **The `pr-description` skill is the authority
on the title and body. Read it before writing a single line of the description,
and follow it over any wording in the repo's PR template.**

1. Read the `pr-description` skill.
2. Run `git log main..HEAD --oneline` and `git remote get-url origin` in
   parallel to understand the commits and the repo.
3. Check for `.github/pull_request_template.md`. If present, take its structure
   (and its checkboxes verbatim) but strip its comments and placeholders per the
   `pr-description` rules.
4. Write the body to a scratch file, not inline into the `gh` command.
5. Run the "Required check before creating the PR" list from `pr-description`
   against that file and cut what fails. Do not skip this step.
6. Create the PR: `gh pr create --draft --body-file <path>`.
7. Do not push. Assume the commits are already pushed; pre-push hooks are slow.
   If the branch has no upstream, stop and tell the user to push.
8. Open it: `gh pr view --web`.
