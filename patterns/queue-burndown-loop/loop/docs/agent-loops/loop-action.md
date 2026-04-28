# Queue Burn-Down Action

## Intent

Turn a curated backlog into a sequence of reviewable local commits: one item, one proof, one change, one QA decision.

## Operating Model

- one loop = one queue item = one local commit
- worker agent may edit and commit
- QA agent must only inspect and run checks
- queue and ledger are the factory memory
- nothing is pushed automatically

## Source Of Truth

1. live file contents
2. `git status --short --branch`
3. `docs/agent-loops/loop-queue.md`
4. `docs/agent-loops/loop-ledger.md`
5. linked issue text only if copied into the queue

All paths are relative to the loop root.

## Hard Rules

- pick the highest-priority safe `[ ]` queue item
- prove the current state before editing
- do not mix multiple queue items in one commit
- do not broaden vague tasks
- block unsafe work instead of guessing
- do not push

## Stop Conditions

Stop if the worktree is dirty, the next item is too broad, validation cannot run, the QA pass fails, or there are no ready queue items.
