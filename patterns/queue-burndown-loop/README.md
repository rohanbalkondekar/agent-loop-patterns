# Queue Burn-Down Loop

This is the basic software-factory line: feed it a curated queue, make the worker agent land one bounded change, make the QA agent verify it, then move to the next item.

This directory is a documentation-only pattern card. The runnable version of this pattern is `template/generic-codex-queue-loop/`. The files below are files you would create or copy into a target repository when instantiating this pattern.

```text
queue item -> worker agent -> local commit -> QA agent -> checkpoint/rollback -> next item
```

Use it when you want:

- one bounded task per loop
- one local commit per accepted task
- a separate validator pass
- durable handoff notes between iterations
- no automatic push

## Files To Create In A Target Repo

```text
docs/agent-loops/
├── example-action.md
├── example-queue.md
├── example-ledger.md
├── example-validation.md
└── prompts/
    ├── fix-agent.md
    └── validator-agent.md
```

Use the template when you want executable scripts; use this README when you only need to understand the pattern.

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
