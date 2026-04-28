# Queue Burn-Down Validation

## Always Required

- `git diff --check`
- inspect latest commit
- run the focused check named by the queue item

## QA Rules

The QA agent must fail the loop if:

- more than one queue item was mixed into the commit
- the queue or ledger was not updated
- the focused check was skipped
- unrelated files changed without a clear reason
