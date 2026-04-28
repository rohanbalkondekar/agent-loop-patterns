# Review Gate Validation

## Always Required

- `git diff --check`
- inspect latest commit with `git show --stat --oneline HEAD`
- rerun the focused checks named by the worker

## QA Rules

The QA agent must fail the loop if:

- tests are missing for risky behavior
- the implementation is broader than the queue item
- blocking findings are unresolved
- the worker summary does not match the actual diff
