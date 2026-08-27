---
name: bonnie-preferred-codestyle
description: >
  Apply Bonnie's preferred style to the diff being prepared for a PR: delete
  restating comments, inline single-use step methods, and collapse mock-only
  specs into behavioural ones. Manual invocation only.
disable-model-invocation: true
allowed-tools: Read, Edit, Grep, Glob, Bash
---

# bonnie-preferred-codestyle

A pre-PR pass over the diff you are about to raise. Ruby only.

This skill supersedes parts of `CLAUDE.md`, `CLAUDE.local.md`, and
`.claude/skills/clean-design/SKILL.md`. Where it contradicts them, this skill
wins, and the run reports the override. Read
[`references/overrides.md`](references/overrides.md) only when a rule was
actually exercised, to write the `OVERRIDES` block.

## Procedure

1. **Resolve the range.**

   ```bash
   base=$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null || echo main)
   git diff "$(git merge-base "origin/$base" HEAD)"   # committed + uncommitted
   ```

   `origin/main` is the fallback when `gh` is absent, unauthenticated, or the
   branch has no PR. Say which base you resolved before touching anything.
   Never diff against `origin/main` when the branch targets a parent PR: on a
   stacked branch that pulls in the parent's code, which is not yours to grade.

   Empty range, or no Ruby files in it: print `NOTHING IN SCOPE` and stop.

2. **List the in-scope hunks and methods** (see [Scope](#scope)) before editing.

3. **Edit app files directly** against [What to change](#what-to-change).
   Comments and inlining are mechanical and `git diff` is the undo.

4. **Never edit a spec without approval.** One question per proposed change,
   wait for the answer, then move to the next. Do not batch them. Each item
   gives: file, line range, what the examples currently assert, and the
   behavioural example you would put there.

5. **Verify.**

   ```bash
   bundle exec rubocop -A <changed app files>
   rtk proxy bundle exec rspec <touched spec files>
   ```

   Use `rtk proxy`. Plain `rtk` serves a cached rspec log, and a stale log looks
   exactly like a real failure. If `rtk` is not on PATH, run plain
   `bundle exec rspec` and say so in the report.

6. **Report** using the [output shape](#output-shape), exactly.

## Scope

**Reach.** A changed hunk puts its *enclosing method* in scope, whole, including
lines you did not write. Nothing else in the file is in scope. If you touched
line 22 inside `#call`, all of `#call` is fair game and `#initialize` is not.

**Specs.** Only spec files added or changed in this diff. Do not open a spec file
you did not touch, however bad it is. CI time improves as PRs land, not by
sweeping. If a neighbouring spec file is egregious, say so in one line at the end
and leave it alone.

**Out of scope.** TypeScript and the merchant dashboard. Verification here is
rubocop and rspec.

## What to change

### Comments

Delete a comment that restates the code or the method name. No banner comments,
no step narration, no "note that".

Keep two kinds:

**Why.** A business or regulatory constraint, a workaround, a surprising edge
case, non-obvious cross-component intent. Lead with the constraint, not the
narration.

```ruby
# Digio returns the DOB as DD-MM-YYYY
```

**In and out.** Only where the shape is not inferable from the name and
signature: a nested return, a parsed external payload, an input with a
surprising format. Real values, no prose, one or two lines.

```ruby
# in:  "12-05-1980" (Digio, DD-MM-YYYY)
# out: { day: 12, month: 5, year: 1980 }
def parsed_dob
```

Not this. The name and the `?` already said it:

```ruby
# in:  none
# out: Boolean
def resides_in_india?
```

### Methods

Inline a single-use private method that is only a step of its caller. A caller
should read straight down. Ten lines you read once beats ten one-line methods
you hop between.

```ruby
# before
def call
  normalised = normalise_pan
  ...
end

def normalise_pan
  pan.to_s.strip.upcase
end

# after
def call
  normalised = pan.to_s.strip.upcase
  ...
end
```

Keep a single-use private that names a domain concept. The test: **does the name
appear in compliance or product language, or is it just a label for the next
three lines?**

```ruby
# keep all three. This is the vocabulary, not indirection.
def non_resident_indian?
  indian_national? && !resides_in_india?
end

def indian_national?
  nationality_country == 'IND'
end

def resides_in_india?
  residence_country == 'IND'
end
```

Do not extract to satisfy a line count. Do not propose a new extraction unless
the extracted thing earns a domain name.

### Specs

A spec that stubs its collaborators and asserts they were called is decoration.
It tests the wiring you just wrote, fails when you refactor, and passes when the
feature is broken. Stub only true externals: HTTP, S3, the clock, a provider SDK.

Replace with behavioural examples over real scenarios. One example that drives a
real case through the entry point covers the units underneath it for free.

```ruby
# delete
it 'calls the normaliser' do
  expect(normaliser).to receive(:call).with(pan)
  service.call
end

# keep
it 'flags the record when the CKYC name does not match the passport' do
  record = create(:kyc_record, :with_ckyc_mismatch)
  described_class.new(record).call
  expect(record.reload.flags).to include('name_mismatch')
end
```

A deletion must ship with the behavioural example that replaces it. If you cannot
name the real-world scenario the deleted examples were protecting, do not propose
the deletion.

## Output shape

Print exactly this shape. Report example count and wall time, before and after,
for the specs touched. Omit a section that has no entries; print `OVERRIDES` only
when a rule was actually exercised, never as a standing disclaimer.

```
BASE  origin/main (no PR found)

APPLIED (app/services/kyc/foo.rb)
  - removed 4 restating comments
  - inlined 3 single-use step methods into #call

NEEDS YOUR CALL (spec/services/kyc/foo_spec.rb)
  - :12-48, 6 examples asserting stubbed collaborators
    propose: 1 behavioural example, "flags a CKYC name mismatch"

VERIFIED
  rubocop: no offenses
  rspec:   18 examples 12.4s -> 3 examples 2.1s, 0 failures

OVERRIDES (2)
  app/services/kyc/foo.rb:31  inlined #normalise_pan into #call
    overrides clean-design "one abstraction level per method"
  app/services/kyc/foo.rb:8   kept in/out example comment
    overrides CLAUDE.md "never what, only why"
```
