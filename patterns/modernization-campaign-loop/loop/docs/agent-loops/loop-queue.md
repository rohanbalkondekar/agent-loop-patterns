# Modernization Campaign Queue

## Ready Queue

- [ ] MIG-001 — move one read-only route to the new boundary
  Why safe: one route, one adapter, compatibility check available
  Validation hint: focused route test plus `git diff --check`

- [ ] MIG-002 — remove one dead legacy adapter after proving no callers remain
  Why safe: deletion gated by search proof and tests
  Validation hint: caller search, focused test, `git diff --check`

## Blocked / Deferred

- [~] BROAD-001 — modernize the whole subsystem
  Reason: split into one live surface per item
