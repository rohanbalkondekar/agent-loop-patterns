# Example Validation

## Always Required

- `git diff --check`
- one focused check tied to the changed files

## Code Changes

Run the smallest test that proves the queue item. For broad shared behavior, also run the nearest package or integration test.

## Docs-Only Changes

Run:

- `git diff --check`

Docs-only commits are valid for documentation tasks, scoping notes, and blocker records. They should not count as implementation progress for runtime tasks.
