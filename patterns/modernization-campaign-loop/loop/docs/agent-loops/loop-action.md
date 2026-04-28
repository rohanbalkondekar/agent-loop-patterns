# Modernization Campaign Action

## Intent

Move a large migration forward through small, validated slices. Each loop should reduce one real legacy surface, not create helper churn.

## Operating Model

- one loop = one campaign slice = one local commit
- worker agent may edit and commit
- QA agent validates changed runtime/migration surface
- ledger carries milestone state and next handoff
- nothing is pushed automatically

## Hard Rules

- prove the legacy or migration slice is still live before editing
- name the exact surface and validation gate before changing files
- do not accept docs-only progress for runtime migration items
- do not batch unrelated surfaces
- if the slice is stale, update queue/ledger and stop
