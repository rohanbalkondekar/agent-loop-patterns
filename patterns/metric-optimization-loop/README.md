# Metric Optimization Loop

Use this when success can be scored: build time, test runtime, latency, bundle size, memory use, accuracy, allocations, or any other repeatable number.

The important insight from autoresearch is that this is not only for ML training. It is perfect for boring, high-value engineering work that humans rarely schedule: shaving CI time, reducing allocations, shrinking bundles, speeding tests, or improving a hot path one small experiment at a time.

```text
baseline -> idea -> experiment -> metric -> keep/revert -> log -> next idea
```

## What Is In This Pattern

```text
loop/       copyable runnable skeleton with autoresearch.* files and queue runner
README.md   pattern explanation and usage notes
```

The `loop/` directory makes the metric contract concrete. It includes:

```text
autoresearch.md
autoresearch.sh
autoresearch.checks.sh
autoresearch.jsonl
docs/agent-loops/*
scripts/run-agent-loop.sh
```

## What It Controls

- Stops the agent from declaring victory without a number.
- Keeps regressions out of the working tree.
- Builds a durable experiment history so the next pass does not repeat bad ideas.
- Separates the primary metric from secondary observations.
- Gives the agent permission to try aggressive ideas while forcing it to throw away bad ones.

## Enforcement Boundary

This pattern enforces metric behavior through the files in `loop/`:

- worker must run `./autoresearch.sh`
- worker must run `./autoresearch.checks.sh`
- worker must append `autoresearch.jsonl`
- QA must fail if the benchmark was skipped, checks failed, the log was not updated, or a regression was kept

The generic runner supplies the outer factory mechanics: worker pass, local commit, QA pass, checkpoint or rollback.

## Factory Example

```text
baseline: test suite takes 91s
idea 1: parallelize slow group -> 78s + checks pass -> keep
idea 2: skip setup step -> 42s + checks fail -> revert
idea 3: cache generated fixture -> 66s + checks pass -> keep
log: next pass should investigate database fixture startup
```

## Reference

See Shopify's writeup, ["Autoresearch isn't just for training models"](https://shopify.engineering/autoresearch), for the broader framing: metric loops are useful anywhere the agent can repeatedly try ideas, measure a fixed metric, keep wins, and discard regressions.
