# Review Gate Loop

Use this when implementation should not be trusted until a second agent has attacked it. This is the QA station for the factory.

```text
implementation -> independent review -> findings -> fixes -> final validation
```

## What Is In This Pattern

```text
loop/       copyable runnable skeleton built on the generic queue runner
README.md   pattern explanation and usage notes
```

The `loop/` directory contains action, queue, ledger, validation, prompts, and runner scripts specialized for implementation-plus-review work.

## What It Controls

- Separates builder bias from reviewer judgment.
- Catches missing tests, weak validation, broad scope, and maintainability problems.
- Turns review findings into another bounded implementation pass instead of a long comment thread.

## Loop Contract

1. Worker agent completes a bounded change.
2. QA agent inspects the diff and recent commit.
3. QA agent returns findings ordered by severity.
4. Worker fixes accepted findings or records non-blocking follow-up.
5. Final validation proves the fix and records what remains.

The QA agent should be independent, read-first, and willing to fail the work.

## Factory Example

```text
worker: lands a bounded API change with tests
reviewer: finds missing error-path coverage and an over-broad helper
worker: adds the missing test and narrows the helper
final validation: focused tests + diff check pass
ledger: record remaining non-blocking follow-up, then move on
```
