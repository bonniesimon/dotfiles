# Overrides

Which team rules this skill supersedes, and what it says instead. Read this only
when a rule was actually exercised during a run, to write the `OVERRIDES` block.

| Superseded | Says | This skill says |
| --- | --- | --- |
| `CLAUDE.md` comment policy | "Only add a comment to explain why, never what" | Also allow an in/out example where the shape is not inferable |
| `CLAUDE.local.md` | "One thought per line, one abstraction level per method. If a method mixes normalisation with a decision, extract the normalisation" | A method may carry a whole procedure. Extract only when the extracted thing earns a domain name |
| `clean-design/SKILL.md` | "one abstraction level per method", deep modules, extract-method | Same. Inline single-use steps |
| `spec/CLAUDE.md` coverage targets | coverage-driven | Behavioural coverage of real scenarios. A dropped mock-only example is not lost coverage |

`clean-design` is team-owned and stays as it is. Its rules still govern while
code is being written. This skill only applies when invoked.

The override is scoped to the invoked run. It does not persist into later turns.

## Never relaxed

Everything `CLAUDE.md` marks always-on still holds: Redis lock and
`Model.uncached` TOCTOU rules, Zeitwerk file layout, credentials and
service-config required-key lists, PII and logging rules, migration rules.
