# Agent Loop Queue

Curate this file before long unattended runs. The loop should consume this queue, not rediscover live issues every pass.

## Ready Queue

- [ ] LOOP-001 — replace this with a small, verifiable task
  Source: local backlog / issue link
  Why safe: narrow file scope and clear validation
  Validation hint: `git diff --check` plus focused test

- [ ] LOOP-002 — add another bounded task
  Source: local backlog / issue link
  Why safe: independent of LOOP-001
  Validation hint: update after curation

## Blocked / Deferred

- [~] EXAMPLE-BROAD — example of a task too broad for unattended work
  Reason: split into smaller child items first

## Done

Move completed items here only if that makes the ready queue easier to scan. It is also fine to leave completed items in place with `[x]` and an outcome note.
