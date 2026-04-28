# Review Gate Action

## Intent

Put an independent QA station after implementation. The worker lands a bounded change; the validator attacks the actual commit and can reject it.

## Operating Model

- one loop = one implementation plus independent review
- worker agent may edit and commit
- QA agent must inspect diff/recent commit and rerun checks
- review findings must be fixed or recorded as explicit follow-up
- nothing is pushed automatically

## Hard Rules

- worker must not claim success without tests or concrete proof
- QA must inspect the actual commit, not just the worker summary
- QA must report findings by severity
- unresolved blocking findings fail the loop
