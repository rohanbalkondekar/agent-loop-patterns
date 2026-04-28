# Queue Burn-Down Queue

## Ready Queue

- [ ] ITEM-001 — make one unclear failure actionable
  Why safe: one narrow behavior, one focused regression check
  Validation hint: focused test or repro plus `git diff --check`

- [ ] ITEM-002 — add regression coverage for one known gap
  Why safe: test-only or narrowly scoped implementation follow-up
  Validation hint: focused test plus `git diff --check`

## Blocked / Deferred

- [~] BROAD-001 — clean up the whole subsystem
  Reason: too broad; split into one behavior per queue item

## Done

Keep completed items marked `[x]` with an outcome note.
