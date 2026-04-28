# Modernization Campaign Loop

Use this when the work is bigger than one issue but still needs to move in controlled slices: migrations, framework upgrades, runtime hardening, API boundary rewrites, and large refactors.

This directory is a documentation-only pattern card, not a runnable campaign. It demonstrates how to turn a broad migration into one-slice passes with proof, gates, and handoff notes. The files below are files you would create in a target repository when instantiating this pattern.

```text
milestone -> prove a live slice still exists -> implement one slice -> run gates -> update ledger -> next slice
```

## What It Controls

- Prevents broad refactors from turning into helper churn.
- Forces each pass to reduce a real ownership, runtime, migration, or architecture problem.
- Keeps the next handoff honest when the code has moved since the last run.
- Rejects docs-only progress when the campaign goal is runtime or architectural change.

## Files To Create In A Target Repo

```text
docs/agent-loops/campaign-action.md
docs/agent-loops/campaign-queue.md
docs/agent-loops/campaign-ledger.md
docs/agent-loops/campaign-validation.md
docs/agent-loops/prompts/fix-agent.md
docs/agent-loops/prompts/validator-agent.md
scripts/run-campaign-loop.sh
```

## Good Queue Items

- Move one legacy route to the new boundary.
- Replace one unsafe runtime path with the approved adapter.
- Finish one migration slice and prove the old path is no longer active.
- Convert one call family to the new API and prove the old path still works through compatibility tests.

## Bad Queue Items

- Clean up the module.
- Improve architecture.
- Continue refactoring.

If the item cannot name the live surface and the validation gate, it is not ready for the loop.

## Factory Example

```text
milestone: move read paths to the new service boundary
slice 1: migrate one read-only endpoint -> route tests pass -> checkpoint
slice 2: migrate one shared helper -> QA rejects broad blast radius -> rollback
slice 3: migrate the endpoint with a narrower adapter -> route tests pass -> checkpoint
ledger: next pass starts from the remaining write-path family
```
