# Autoresearch Session

## Objective

Improve one primary metric through repeated experiments while preserving correctness.

## Primary Metric

Define exactly one metric before running, for example:

```text
primary_metric: test_runtime_ms
benchmark_command: ./autoresearch.sh
checks_command: ./autoresearch.checks.sh
```

## Rules

- keep improvements only when the primary metric improves and checks pass
- revert regressions, crashes, and failed checks
- append every attempt to `autoresearch.jsonl`
- do not change the benchmark command mid-run without recording why

## Current Best

Record the baseline and best-known result here before starting.
