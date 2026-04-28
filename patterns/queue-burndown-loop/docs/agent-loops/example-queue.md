# Example Queue

## Ready

- [ ] make one unclear failure actionable
  Source: local triage note
  Why safe: one narrow code path and one focused regression test
  Validation hint: focused test plus `git diff --check`

- [ ] document one confusing setup step
  Source: maintainer note
  Why safe: docs-only clarification with no runtime behavior change
  Validation hint: `git diff --check`

## Blocked

- [~] redesign a whole subsystem
  Reason: too broad for unattended looping; needs design first

## Completed

Move finished items here or mark them `[x]` in place. The important part is that the next loop can identify the next safe ready item without rediscovering the backlog.
