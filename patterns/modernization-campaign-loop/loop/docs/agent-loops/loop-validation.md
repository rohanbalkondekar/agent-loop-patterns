# Modernization Campaign Validation

## Always Required

- `git diff --check`
- inspect latest commit
- run the focused gate named by the queue item

## Runtime Or Migration Changes

The QA agent must fail the loop if:

- no proof showed the old surface was still live
- the commit is helper churn with no migration effect
- docs-only changes are counted as runtime progress
- compatibility or focused route tests were skipped
- unrelated surfaces changed without a queue item
