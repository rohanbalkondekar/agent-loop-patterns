# Generic Codex Queue Loop Template

This is a starter harness for a local queue loop:

```text
curated queue → fixer agent → local commit → independent validator → checkpoint / stop
```

It is intentionally small. Start here before copying any larger example.

## Install into a repo

From this repository root, copy the template into another repo:

```bash
TARGET=/path/to/target-repo
mkdir -p "$TARGET/docs/agent-loops/prompts" "$TARGET/scripts"
cp -R template/generic-codex-queue-loop/docs/agent-loops/* "$TARGET/docs/agent-loops/"
cp template/generic-codex-queue-loop/scripts/* "$TARGET/scripts/"
chmod +x "$TARGET/scripts/run-agent-loop.sh" "$TARGET/scripts/run-agent-loop-supervised.sh"
```

Then edit:

- `docs/agent-loops/loop-action.md`
- `docs/agent-loops/loop-queue.md`
- `docs/agent-loops/loop-validation.md`
- `docs/agent-loops/prompts/fix-agent.md`
- `docs/agent-loops/prompts/validator-agent.md`

## Run

```bash
./scripts/run-agent-loop.sh --prepare-only
./scripts/run-agent-loop.sh 3
./scripts/run-agent-loop-supervised.sh 25
```

## Prerequisites

- A git repository.
- A clean worktree before each batch.
- Codex CLI on `PATH`.
- Any project-specific test/build tools required by `loop-validation.md`.

The coding agent is **Codex CLI** via `codex exec`. By default the runner uses:

```text
CODEX_MODEL=gpt-5.5
CODEX_REASONING_EFFORT=xhigh
```

Override them only when you deliberately want a different factory line:

```bash
CODEX_MODEL=<model> CODEX_REASONING_EFFORT=<effort> ./scripts/run-agent-loop.sh 5
```

You can also use a Codex config profile:

```bash
CODEX_PROFILE=my-profile ./scripts/run-agent-loop.sh 5
```

By default the fixer runs with `FIXER_CODEX_SANDBOX_MODE=workspace-write` and the validator runs with `VALIDATOR_CODEX_SANDBOX_MODE=read-only`. Override those only when you understand the risk.

If you install the template in a nested directory, the runner automatically adds the git root, worktree git metadata, and git common directory to Codex's writable sandbox so commits can work. Set `CODEX_ADD_GIT_ROOT=false` to disable that behavior.

## Expectations

- Start from a clean worktree.
- Curate queue items before a long run; do not ask the loop to scrape live ticket systems every pass.
- One successful loop should create exactly one local commit.
- The validator must not edit or commit.
- Nothing is pushed automatically.
- Logs go outside the repo by default: `../_loop-runs/<repo-name>/`.

## What The Runner Actually Does

1. Refuses to start unless the worktree is clean.
2. Builds a fixer prompt from the action, queue, ledger, validation contract, and latest handoff.
3. Runs Codex for the fixer pass.
4. Requires the fixer to leave exactly one clean local commit.
5. Builds a validator prompt and runs Codex in read-only mode.
6. If validation passes, writes a checkpoint ref under `refs/agent-loop/checkpoints/`.
7. If validation fails, saves the rejected commit under `refs/agent-loop/rejected/` and resets the branch back to the pre-loop commit.

The rollback behavior is useful for unattended local work, but it is intentionally strong. Read `SAFETY.md` in the repository root before running this against important work.
