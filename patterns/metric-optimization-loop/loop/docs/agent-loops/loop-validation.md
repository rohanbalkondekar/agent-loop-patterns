# Metric Optimization Validation

## Always Required

- `git diff --check`
- `./autoresearch.sh`
- `./autoresearch.checks.sh`
- inspect latest `autoresearch.jsonl` entry

## QA Rules

The QA agent must fail the loop if:

- no benchmark was run
- correctness checks failed or were skipped
- `autoresearch.jsonl` was not updated
- a regression was kept instead of reverted
- the benchmark/check command was weakened without explicit queue approval
