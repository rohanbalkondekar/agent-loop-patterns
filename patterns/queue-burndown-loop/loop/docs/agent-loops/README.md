# Agent Loop

Local-only loop for working through a curated queue of small, verifiable tasks.

All paths in these files are relative to the loop root: the directory where `scripts/run-agent-loop.sh` lives. If the loop is installed in a nested directory, do not include the parent directory name in queue or ledger paths.

## Files

- `loop-action.md` — mission, hard rules, stop conditions.
- `loop-queue.md` — curated queue consumed by the loop.
- `loop-ledger.md` — append-only history and handoff notes.
- `loop-validation.md` — checks required by changed surface.
- `prompts/fix-agent.md` — implementation-pass instructions.
- `prompts/validator-agent.md` — independent validation-pass instructions.
- `scripts/run-agent-loop.sh` — runner.
- `scripts/run-agent-loop-supervised.sh` — stale-run supervisor.

## Protocol

1. Start from a clean local worktree.
2. Run a prepare-only preflight.
3. Run a small pilot batch.
4. Review generated commits and logs.
5. Only then run longer unattended batches.

```bash
./scripts/run-agent-loop.sh --prepare-only
./scripts/run-agent-loop.sh 3
./scripts/run-agent-loop-supervised.sh 25
```
