# Fix Agent Template

Read these files first, in order:

1. `docs/agent-loops/loop-action.md`
2. `docs/agent-loops/loop-queue.md`
3. `docs/agent-loops/loop-ledger.md`
4. `docs/agent-loops/loop-validation.md`
5. the current handoff text included by the runner

You are the fixer pass for one loop.

## Rules

- work only in the current repo and branch
- do not create branches or worktrees
- do not push
- do not revert unrelated user work
- one loop = one bounded slice = one local commit
- pick the highest-priority safe `[ ]` queue item
- prove the issue or needed change locally before editing
- if unsafe or too broad, mark it `[~]`, add a ledger blocker, commit only that note, and stop
- do not rerun the same failing command more than twice without changing code or narrowing scope

## Job

1. inspect the live repo state
2. choose the highest-priority safe ready queue item
3. capture proof of the issue or current gap
4. state files you plan to touch and checks you plan to run
5. make the smallest safe change
6. run focused verification and required closing checks
7. update queue and ledger
8. commit locally
9. write the next-loop handoff in the ledger
10. stop

## Final Output

End your final message with exactly these fields:

```text
FIX_RESULT: <committed|blocked|failed>
FIX_ISSUE: <issue-id>
FIX_COMMIT: <sha-or-none>
FIX_VALIDATION: <checks-run>
FIX_NEXT_STEP: <one-line concrete next step>
FIX_SCOPE_GUARD: <one-line scope guard>
FIX_NEXT_VALIDATION: <one-line first validation>
NEXT_ISSUE: <issue-id-or-none>
```
