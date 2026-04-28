# Metric Optimization Loop

Use this when success can be scored: build time, test runtime, latency, bundle size, memory use, accuracy, allocations, or any other repeatable number.

This directory is a documentation-only pattern card, not a runnable implementation. It demonstrates the control contract for metric-driven agent work: the agent must measure, keep only improvements, revert failures, and log what happened.

The important insight from autoresearch is that this is not only for ML training. It is perfect for boring, high-value engineering work that humans rarely schedule: shaving CI time, reducing allocations, shrinking bundles, speeding tests, or improving a hot path one small experiment at a time.

```text
baseline -> idea -> experiment -> metric -> keep/revert -> log -> next idea
```

## What It Controls

- Stops the agent from declaring victory without a number.
- Keeps regressions out of the working tree.
- Builds a durable experiment history so the next pass does not repeat bad ideas.
- Separates the primary metric from secondary observations.
- Gives the agent permission to try aggressive ideas while forcing it to throw away bad ones.

## Enforcement Boundary

The generic queue runner in this repo does **not** enforce metric keep/revert by itself. It enforces the outer factory mechanics: one worker pass, one commit, one QA pass, checkpoint or rollback.

To make this pattern real, instantiate it in a target repo by adding metric-specific files and checks, then wire them into the queue and validation contract. The QA agent must fail any pass that does not run the benchmark, does not update the experiment log, or keeps a regression.

## Files To Create In A Target Repo

```text
autoresearch.md
autoresearch.sh
autoresearch.checks.sh
autoresearch.jsonl
```

## Loop Contract

1. Record the baseline.
2. Try one idea.
3. Run the same benchmark command.
4. Run correctness checks.
5. Keep only if the primary metric improves and checks pass.
6. Revert if the metric regresses, checks fail, or the run crashes.
7. Log the result with enough detail for the next pass.

## How To Run It With This Repo

Use `template/generic-codex-queue-loop/` as the outer runner, then make queue items that explicitly require the metric contract:

```text
- [ ] EXP-001 — try one test-runtime improvement
  Why safe: one isolated test helper, benchmark is fixed
  Validation hint: run `./autoresearch.sh`, run `./autoresearch.checks.sh`, append `autoresearch.jsonl`
```

Then update `loop-validation.md` so the validator must check:

```text
- benchmark command ran
- correctness checks passed
- `autoresearch.jsonl` has a new entry
- kept changes improved the primary metric
- reverted changes leave no dirty worktree
```

Good metric loops are ruthless: no number, no win.

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
