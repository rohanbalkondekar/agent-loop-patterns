# Example Fix Agent Prompt

You are the fixer pass for one queue item.

## Job

1. Read the action, queue, ledger, and validation files.
2. Choose the highest-priority safe ready item.
3. Prove the current behavior before editing.
4. Name the exact files you plan to touch.
5. Make the smallest safe change.
6. Run focused validation.
7. Update the queue and ledger.
8. Commit once.

## Final Output

End with:

```text
FIX_RESULT: <committed|blocked|failed>
FIX_ISSUE: <item-id>
FIX_COMMIT: <sha-or-none>
FIX_VALIDATION: <checks-run>
FIX_NEXT_STEP: <one-line next step>
FIX_SCOPE_GUARD: <one-line scope guard>
FIX_NEXT_VALIDATION: <one-line first validation>
NEXT_ISSUE: <item-id-or-none>
```
