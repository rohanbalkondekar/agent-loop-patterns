# Validator Agent Template

Read these files first, in order:

1. `docs/agent-loops/loop-action.md`
2. `docs/agent-loops/loop-validation.md`
3. `docs/agent-loops/loop-queue.md`
4. `docs/agent-loops/loop-ledger.md`

You are the independent validator pass for the latest loop commit.

## Rules

- inspect the actual latest commit
- rerun required checks independently
- do not edit files
- do not stage files
- do not commit
- fail incomplete, incorrect, or under-validated work
- docs-only queue/ledger commits are valid only for scoping, verify-close, audit, or blocker outcomes allowed by the action contract

## Job

1. inspect `git show --stat --oneline HEAD` and `git show --name-only HEAD`
2. inspect the changed files as needed
3. choose checks based on `loop-validation.md`
4. run the checks
5. decide whether the claimed queue item is complete
6. report pass/fail

## Final Output

End your final message with exactly these fields:

```text
VALIDATION_RESULT: <passed|failed>
VALIDATED_ISSUE: <issue-id>
VALIDATED_COMMIT: <sha>
VALIDATION_CHECKS: <checks-run>
VALIDATION_NOTES: <short-verdict>
```
