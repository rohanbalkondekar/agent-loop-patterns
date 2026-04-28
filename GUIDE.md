# How Agent Loops Work

An agent loop is a software factory pattern.

A normal agent session is a craftsperson: useful, but bounded by one context window, one burst of attention, and one final answer. A loop turns that into a production line: the agent takes one work item, proves the current state, changes the repo, validates the result, records the handoff, and moves to the next item.

This is how agents become useful for ultra-long-horizon work:

- large backlog burn-downs
- multi-week migrations
- runtime modernization campaigns
- repeated benchmark optimization
- implementation plus independent review
- unattended overnight batches

The useful shape is:

```text
factory goal
  -> work queue
  -> worker agent
  -> local proof
  -> commit or experiment result
  -> QA agent
  -> checkpoint or rollback
  -> ledger handoff
  -> next item
```

## Factory Lines

```text
Issue factory: backlog item -> worker agent -> commit -> QA agent -> checkpoint/rollback -> next item
Migration factory: milestone -> one code slice -> compatibility tests -> ledger handoff -> next slice
Optimization factory: idea -> benchmark -> score -> keep/revert -> experiment log -> next idea
Review factory: implementation -> independent review -> findings -> fixes -> final validation
Supervisor: start runner -> watch logs -> kill stale run -> restart batch -> exit on clean completion
```

These are factory lines built from the same parts. The names are just shorthand for the kind of work being manufactured.

## The Minimal Factory

The smallest useful factory has five things:

1. A contract that says what success means.
2. A queue that says what to do next.
3. A worker prompt that allows edits.
4. A QA prompt that validates without editing.
5. A ledger that records what happened and where to continue.

The runnable version of this is `template/generic-codex-queue-loop/`.

## One Factory Pass

For a queue item like `make one unclear failure actionable`, one factory pass should look like this:

1. Runner reads contract, queue, ledger, validation rules, and latest handoff.
2. Worker agent proves the current failure locally.
3. Worker agent names the files it will touch.
4. Worker agent makes the smallest safe change.
5. Worker agent runs focused checks.
6. Worker agent updates the queue and ledger.
7. Worker agent commits once.
8. QA agent inspects the actual commit without editing.
9. QA agent reruns the required checks.
10. Runner checkpoints the commit if QA passes.
11. Runner saves a rejected ref and restores the previous commit if QA fails.

## Long-Horizon Example

Goal: migrate a large codebase from an old boundary to a new boundary while keeping the product green.

Bad prompt:

```text
Refactor the old boundary to the new one.
```

Factory queue:

```text
[ ] move one read-only route to the new boundary
[ ] move one write route to the new boundary
[ ] add regression coverage for one migrated route
[ ] remove one dead adapter after proof no caller remains
[ ] verify one old bug is already closed on current main
```

Factory behavior:

```text
route slice -> worker commit -> QA reruns route tests -> checkpoint
next slice -> worker overreaches -> QA fails -> rejected ref + rollback
next slice -> worker narrows scope -> QA passes -> checkpoint
ledger tells tomorrow's agent exactly where to continue
```

The factory does not need one genius agent. It needs many small passes that cannot lie about progress.

## What Makes Loops Fail

- The queue item is too broad.
- The handoff is stale and the agent trusts it over live code.
- The worker changes code without proving the current behavior first.
- The QA agent only reads the summary instead of inspecting the commit.
- The loop accepts docs-only churn as progress when the goal was runtime change.
- The runner allows dirty worktrees or untracked local state to mix into the result.

Good factories are ruthless: one task, one proof, one change, one validation result, one next handoff.
