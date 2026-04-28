# Metric Optimization Queue

## Ready Queue

- [ ] EXP-001 — try one safe improvement to the primary metric
  Why safe: one isolated change, fixed benchmark command
  Validation hint: `./autoresearch.sh`, `./autoresearch.checks.sh`, new `autoresearch.jsonl` entry

- [ ] EXP-002 — try one alternative implementation strategy
  Why safe: independent from EXP-001
  Validation hint: same benchmark, same checks, append experiment log

## Blocked / Deferred

- [~] BROAD-001 — improve performance everywhere
  Reason: too broad; choose one metric and one surface

## Done

Mark experiments done with keep/revert/crash/checks_failed outcome notes.
