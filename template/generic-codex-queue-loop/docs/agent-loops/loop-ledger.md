# Agent Loop Ledger

Append one entry per loop. Keep the latest handoff concrete enough that a fresh agent can continue without rediscovery.

## Current Handoff

- Next item: LOOP-001
- Next step: inspect the ready queue item, prove the issue locally, then make the smallest safe change.
- Scope guard: do not broaden beyond the selected queue item.
- First validation: run the focused check named in the queue item, then `git diff --check`.

## Entries

### Loop 0 — bootstrap

- status: initialized
- commit: none
- validation: none
- notes: template ledger created
