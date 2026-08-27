---
name: bonnie-preferred-codestyle
description: >
  Apply Bonnie's preferred style to the diff being prepared for a PR: delete
  restating comments, inline single-use step methods, and collapse mock-only
  specs into behavioural ones. Manual invocation only.
disable-model-invocation: true
---

# bonnie-preferred-codestyle

A pre-PR pass over the diff you are about to raise. Ruby only.

This skill supersedes parts of `CLAUDE.md`, `CLAUDE.local.md`, and
`.claude/skills/clean-design/SKILL.md`. Where it contradicts them, this skill
wins, and the run reports the override. See [Overrides](#overrides).

## Scope

Resolve the range before reading anything:

```bash
base=$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null || echo main)
git diff "$(git merge-base "origin/$base" HEAD)"        # committed + uncommitted
```

`origin/main` is the fallback. Never diff against `origin/main` when the branch
targets a parent PR: on a stacked branch that pulls in the parent's code, which
is not yours to grade.

**Reach.** A changed hunk puts its *enclosing method* in scope, whole, including
lines you did not write. Nothing else in the file is in scope. If you touched
line 22 inside `#call`, all of `#call` is fair game and `#initialize` is not.

**Specs.** Only spec files added or changed in this diff. Do not open a spec file
you did not touch, however bad it is. CI time improves as PRs land, not by
sweeping. If a neighbouring spec file is egregious, say so in one line at the end
and leave it alone.

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

## How to run it

1. Resolve the range and list the in-scope hunks and methods.
2. **Edit app files directly.** Comments and inlining are mechanical and `git
   diff` is the undo.
3. **Never edit a spec without approval.** List each proposed spec change as its
   own item: file, line range, what the examples currently assert, and the
   behavioural example you would put there. Ask per item.
4. Verify:

```bash
bundle exec rubocop -A <changed app files>
rtk proxy bundle exec rspec <touched spec files>
```

Use `rtk proxy`. Plain `rtk` serves a cached rspec log, and a stale log looks
exactly like a real failure.

5. Report example count and wall time, before and after, for the specs touched.

### Output shape

```
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

## Overrides

Print the `OVERRIDES` block only when a rule was actually exercised. Silent
otherwise. No standing disclaimer.

| Superseded | Says | This skill says |
| --- | --- | --- |
| `CLAUDE.md` comment policy | "Only add a comment to explain why, never what" | Also allow an in/out example where the shape is not inferable |
| `CLAUDE.local.md` | "One thought per line, one abstraction level per method. If a method mixes normalisation with a decision, extract the normalisation" | A method may carry a whole procedure. Extract only when the extracted thing earns a domain name |
| `clean-design/SKILL.md` | "one abstraction level per method", deep modules, extract-method | Same. Inline single-use steps |
| `spec/CLAUDE.md` coverage targets | coverage-driven | Behavioural coverage of real scenarios. A dropped mock-only example is not lost coverage |

`clean-design` is team-owned and stays as it is. Its rules still govern while
code is being written. This skill only applies when invoked.

## Out of scope

Everything `CLAUDE.md` marks always-on still holds and is never relaxed here:
Redis lock and `Model.uncached` TOCTOU rules, Zeitwerk file layout, credentials
and service-config required-key lists, PII and logging rules, migration rules.

TypeScript and the merchant dashboard. Verification here is rubocop and rspec.
