# Modernization Campaign Ledger

## Current Handoff

- Current milestone: move read paths to the new boundary.
- Next item: MIG-001
- Next step: prove the read-only route still uses the old boundary, then migrate one route.
- Scope guard: do not touch write paths or shared auth.
- First validation: focused route test plus `git diff --check`.

## Entries

### Loop 0 — bootstrap

- status: initialized
- notes: campaign factory ready
