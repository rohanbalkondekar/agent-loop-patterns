# Metric Optimization Action

## Intent

Run one metric experiment per loop. Keep only changes that improve the primary metric and pass correctness checks.

## Operating Model

- one loop = one hypothesis = one experiment result
- worker agent may edit, benchmark, revert, and commit
- QA agent verifies metric evidence and correctness independently
- `autoresearch.md` and `autoresearch.jsonl` are durable experiment memory
- nothing is pushed automatically

## Source Of Truth

1. live file contents
2. `autoresearch.md`
3. `autoresearch.jsonl`
4. `docs/agent-loops/loop-queue.md`
5. `docs/agent-loops/loop-ledger.md`

All paths are relative to the loop root.

## Hard Rules

- run `./autoresearch.sh` for the primary metric
- run `./autoresearch.checks.sh` for correctness
- append a JSONL record for every attempt
- keep only improvements that pass checks
- revert regressions, crashes, and failed checks
- do not fake wins by weakening the benchmark or checks
