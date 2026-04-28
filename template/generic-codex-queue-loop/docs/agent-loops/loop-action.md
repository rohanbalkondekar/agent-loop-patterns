# Agent Loop Action

## Intent

Resolve one bounded, curated task per loop with a local commit and independent validation.

## Operating Model

- one loop = one bounded slice = one local commit
- the fixer agent may edit files and commit
- the validator agent must only inspect and run checks
- the queue, ledger, and current repo state are the source of truth
- nothing is pushed automatically

## Source of Truth Order

1. live file contents
2. `git status --short --branch`
3. `docs/agent-loops/loop-queue.md`
4. `docs/agent-loops/loop-ledger.md`
5. linked issue/ticket text, if already copied into the queue

All paths are relative to the loop root, not necessarily the git repository root.

## Hard Rules

- work only in this repo and current branch
- start from a clean worktree
- do not create branches or worktrees from inside the loop
- do not push
- do not revert unrelated user work
- do not mix multiple queue items in one commit
- do not take broad or ambiguous items just because they are next
- if the next item is unsafe, mark it blocked/deferred in the queue and ledger, commit that note, and stop
- do not rerun the same failing command more than twice without changing code or narrowing scope

## Queue States

- `[ ]` ready
- `[x]` completed
- `[~]` blocked/deferred

## Required Loop Output

Each accepted loop should leave:

- one local commit
- queue state updated
- ledger entry updated
- validation checks recorded
- next handoff recorded

## Stop Conditions

Stop if:

- the worktree is dirty before start
- the task is too broad to finish safely
- validation cannot run locally
- the validator fails the commit
- the queue has no ready items
