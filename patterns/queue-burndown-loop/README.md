# Queue Burn-Down Loop

This is the basic software-factory line: feed it a curated queue, make the worker agent land one bounded change, make the QA agent verify it, then move to the next item.

```text
queue item -> worker agent -> local commit -> QA agent -> checkpoint/rollback -> next item
```

## What Is In This Pattern

```text
loop/       copyable runnable skeleton built on the generic queue runner
README.md   pattern explanation and usage notes
```

Use `loop/` when you want an actual starting point. It contains scripts plus `docs/agent-loops/*` files specialized for queue burn-down work.

## Use It When You Want

- one bounded task per loop
- one local commit per accepted task
- a separate validator pass
- durable handoff notes between iterations
- no automatic push

## Factory Example

Queue item:

```text
[ ] make one unclear failure actionable
```

One factory pass:

1. The worker proves the current unclear error with a local command or failing test.
2. The worker changes only the narrow code path needed for that item.
3. The worker runs focused tests and `git diff --check`.
4. The worker marks the item complete and adds a ledger entry.
5. The worker commits once.
6. The QA agent inspects the commit and reruns the checks.
7. The runner checkpoints the commit or rejects it.

Good queue items are small enough to manufacture. Bad queue items say things like "clean up config" or "make errors better".
