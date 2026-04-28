# Review Gate Loop

Use this when implementation should not be trusted until a second agent has attacked it. This is the QA station for the factory.

This directory is a documentation-only pattern card, not a runnable review harness. It demonstrates how to separate builder and reviewer roles, turn findings into bounded fixes, and require final validation. The files below are files you would create in a target repository when instantiating this pattern.

```text
implementation -> independent review -> findings -> fixes -> final validation
```

## What It Controls

- Separates builder bias from reviewer judgment.
- Catches missing tests, weak validation, broad scope, and maintainability problems.
- Turns review findings into another bounded implementation pass instead of a long comment thread.

## Files To Create In A Target Repo

```text
review-action.md
review-prompt.md
fix-findings-prompt.md
reviews/
```

## Loop Contract

1. Implementation agent completes a bounded change.
2. Review agent inspects the diff and recent commits.
3. Review agent returns findings ordered by severity.
4. Implementation agent fixes accepted findings.
5. Final validation proves the fix and records what remains.

The review agent should be independent, read-first, and willing to fail the work.

## Factory Example

```text
worker: lands a bounded API change with tests
reviewer: finds missing error-path coverage and an over-broad helper
worker: adds the missing test and narrows the helper
final validation: focused tests + diff check pass
ledger: record remaining non-blocking follow-up, then move on
```
