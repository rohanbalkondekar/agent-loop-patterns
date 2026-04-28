# Agent Loop Safety

Agent loops can run commands, edit files, commit changes, and repeat. Treat them like automation with write access to your repository.

## Default Safety Rules

- Run loops only in a clean git worktree.
- Do not run loops on a branch with unrelated uncommitted work.
- Do not push automatically from a loop.
- Keep logs outside the repository unless they are intentionally sanitized.
- Keep queue items small enough to validate in one pass.
- Use an independent validator pass for unattended work.

## Template Runner Behavior

`template/generic-codex-queue-loop/scripts/run-agent-loop.sh` now defaults to:

- `FIXER_CODEX_SANDBOX_MODE=workspace-write`
- `VALIDATOR_CODEX_SANDBOX_MODE=read-only`

The fixer needs write access to make a local commit. The validator should not need write access.

If validation fails, the runner:

1. Saves the rejected commit under `refs/agent-loop/rejected/<stamp>`.
2. Runs `git reset --hard <baseline-commit>` to restore the pre-loop commit.
3. Stops for human inspection.

That reset is why the clean-worktree precondition matters. Do not weaken it.

## What To Check Before A Long Run

Run:

```bash
git status --short --branch
./scripts/run-agent-loop.sh --prepare-only
```

Then inspect:

- the ready queue
- the current handoff
- the validation contract
- the sandbox modes
- the log destination

## Publication Safety

Do not publish raw loop logs, real queue files, or real ledgers unless they have been reviewed. They often contain:

- local absolute paths
- issue tracker IDs
- product defect details
- security-hardening notes
- command histories
- fake or real environment variable names
- internal repository names

Prefer sanitized examples that show the loop mechanics with fictional tasks.
