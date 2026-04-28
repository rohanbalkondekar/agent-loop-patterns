# Review Gate Queue

## Ready Queue

- [ ] REV-001 — implement one bounded change and put it through independent review
  Why safe: one small change with clear validation
  Validation hint: focused test, review findings, `git diff --check`

## Blocked / Deferred

- [~] BROAD-001 — review the whole repository
  Reason: too broad; review one diff or one recent batch
