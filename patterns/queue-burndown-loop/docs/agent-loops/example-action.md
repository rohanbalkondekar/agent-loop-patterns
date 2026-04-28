# Example Queue Loop Action

## Intent

Resolve one curated task per loop with one local commit and independent validation.

## Rules

- Work only in the current repository and branch.
- Start from a clean worktree.
- Do not push.
- Do not mix multiple queue items in one commit.
- Prove the current behavior before editing.
- If the item is too broad, mark it blocked and stop.

## Successful Loop Output

Each accepted loop leaves:

- one local commit
- updated queue state
- updated ledger entry
- validation checks recorded
- concrete next handoff
