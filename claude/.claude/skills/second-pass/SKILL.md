---
name: second-pass
description: "Scrap the working first implementation and rebuild it elegantly, using what the first pass learned."
disable-model-invocation: true
---

The first pass learned the problem. The second pass writes the elegant solution.

Run only once the first pass is green. If its tests fail, stop and say so.

1. **Snapshot.** Preserve the first pass so the rewrite is reversible:
   `git add -A && git stash store -m second-pass-snapshot "$(git stash create)"` for uncommitted
   work (the add pulls new files into the snapshot), or note
   the HEAD sha if it is committed. Done when you can name the ref that restores it.

2. **Lessons.** Write to the user a short list: surprises, dead ends, and the edge cases that
   turned out real. Then walk every file, helper, layer, and branch the first pass added and tag
   each one _load-bearing_ (guards a real edge case: name it) or _exploration debris_ (temp
   helpers, duplicate logic, abandoned approaches, orphan imports). Done when every addition in the
   diff carries a tag.

3. **Rebuild.** Knowing everything you know now, scrap the first pass and implement the elegant
   solution: keep every load-bearing case, drop all debris, reuse existing functions over new
   ones. Keep the first pass's tests unchanged as the behaviour contract.

4. **Compare.** Run the same tests: they must be green. Show the user the diff stat of first vs
   second pass and one line per dropped piece of debris. Keep the second pass only if it is
   green and smaller or clearer; otherwise restore the snapshot and say why. The user decides.
