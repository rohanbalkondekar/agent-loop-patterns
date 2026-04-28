# Agent Loop Validation Contract

## Always Required

The validator must always run:

- `git diff --check`
- a focused test/check relevant to the changed files

## Add Project-Specific Checks

Edit these sections for your stack.

### JavaScript / TypeScript

Run when JS/TS source changes:

- `npm run typecheck` if available
- focused unit tests
- `npm test` or `npm run test` for broad changes

### Go

Run when Go source changes:

- `go test ./... -count=1`
- `make lint` if available and relevant
- `make build` for CLI/runtime surfaces

### Docs-only / queue-only changes

Run:

- `git diff --check`

Docs-only commits are valid only for scoping, verify-close, queue updates, or blocker notes explicitly allowed by `loop-action.md`.

## Validator Rules

The validator must:

- inspect the latest commit
- decide checks from changed files
- rerun those checks independently
- fail incomplete or under-validated work

The validator must not:

- edit files
- stage files
- commit
- fix forward during validation
