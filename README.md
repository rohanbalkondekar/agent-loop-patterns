# Agent Loop Patterns

An opinionated playbook for turning coding agents into a software factory.

The point is not to make a clever prompt. The point is to make agents work on ultra-long-horizon tasks: burn down hundreds of small issues, migrate a codebase slice by slice, run experiments for days, and keep producing reviewable progress without forgetting what happened yesterday.

The factory shape is:

```text
work queue -> worker agent -> local proof -> QA agent -> checkpoint -> next handoff -> repeat
```

Start with `GUIDE.md` for the operating model. Read `SAFETY.md` before giving a loop write access to a real repository.

The runnable template uses **Codex CLI** through `codex exec`. It is opinionated by default:

```text
CODEX_MODEL=gpt-5.5
CODEX_REASONING_EFFORT=xhigh
```

Users can override those env vars, but the starter works without choosing a model first.

## Quick Start

### 1. Pick The Factory Line

Start with the pattern cards. They are not runnable examples; they are blueprints for deciding what kind of factory you are building.

```text
patterns/queue-burndown-loop/          backlog -> worker -> QA -> next item
patterns/modernization-campaign-loop/  milestone -> slice -> gates -> handoff
patterns/metric-optimization-loop/     idea -> benchmark -> keep/revert -> next idea
patterns/review-gate-loop/             implementation -> review -> fixes
```

Use them to answer:

- What is the work intake?
- What does one unit of work look like?
- What proof must the worker produce?
- What can the QA agent reject?
- What handoff should the next pass inherit?

### 2. Install The Runnable Template

From this repository:

```bash
TARGET=/path/to/target-repo
mkdir -p "$TARGET/docs/agent-loops/prompts" "$TARGET/scripts"
cp -R template/generic-codex-queue-loop/docs/agent-loops/* "$TARGET/docs/agent-loops/"
cp template/generic-codex-queue-loop/scripts/* "$TARGET/scripts/"
chmod +x "$TARGET/scripts/run-agent-loop.sh" "$TARGET/scripts/run-agent-loop-supervised.sh"
```

### 3. Define The Factory Goal

Edit `docs/agent-loops/loop-action.md`.

Write the goal like a production contract, not a wish:

```text
Goal: migrate one bounded API surface per loop while keeping tests green.
Allowed work: implementation, focused tests, queue/ledger updates.
Forbidden work: broad cleanup, unrelated refactors, automatic push.
Stop if: the task needs design, external credentials, or edits outside the selected slice.
```

### 4. Build The Queue

Edit `docs/agent-loops/loop-queue.md`.

Good queue items are small enough for one worker pass:

```text
- [ ] API-001 — move one read-only handler to the new service boundary
  Why safe: one handler, one adapter, one focused route test
  Validation hint: run the focused route test and `git diff --check`

- [ ] API-002 — add regression coverage for the migrated read path
  Why safe: test-only follow-up for API-001
  Validation hint: run the focused route test
```

Bad queue items are vague:

```text
- [ ] clean up API layer
- [ ] finish migration
- [ ] improve architecture
```

### 5. Set The Handoff

Edit `docs/agent-loops/loop-ledger.md`.

The handoff is what tomorrow's agent reads first:

```text
Next item: API-001
Next step: inspect the current read-only handler and prove the old boundary is still active.
Scope guard: do not touch write handlers or shared auth code.
First validation: run the focused route test, then `git diff --check`.
```

### 6. Define QA Gates

Edit `docs/agent-loops/loop-validation.md`.

Map changed surfaces to checks:

```text
Always:
- git diff --check

API handler changes:
- focused route test
- typecheck if available

Shared runtime changes:
- focused test
- broader integration test
```

### 7. Tune The Prompts

Edit:

```text
docs/agent-loops/prompts/fix-agent.md
docs/agent-loops/prompts/validator-agent.md
```

The worker prompt should say:

```text
prove the current state -> make one bounded change -> run checks -> update queue/ledger -> commit once
```

The QA prompt should say:

```text
inspect the actual commit -> rerun checks independently -> pass or fail -> do not edit
```

### 8. Run A Preflight

Start from a clean worktree:

```bash
git status --short --branch
./scripts/run-agent-loop.sh --prepare-only
```

### 9. Run A Pilot Batch

Run a small batch first:

```bash
./scripts/run-agent-loop.sh 3
```

If the commits are good, run longer:

```bash
./scripts/run-agent-loop-supervised.sh 25
```

The loop writes local commits and checkpoint refs. It does not push.

## What Is Here

```text
agent-loop-patterns/
├── README.md
├── GUIDE.md
├── SAFETY.md
├── LICENSE
├── patterns/                              # documentation-only pattern cards
│   ├── queue-burndown-loop/               # queue -> fixer -> validator -> next item
│   ├── modernization-campaign-loop/       # milestone -> slice -> gates -> handoff
│   ├── metric-optimization-loop/          # idea -> metric -> keep/revert -> next idea
│   └── review-gate-loop/                  # implementation -> review -> fix findings
└── template/
    └── generic-codex-queue-loop/          # reusable runnable starter template
```

The `patterns/` directories are not runnable harnesses and do not contain every file named in their READMEs. They are concise pattern cards: each one explains what that factory line is for, what files you would create in a target repository, and what a healthy pass looks like. The runnable starter is `template/generic-codex-queue-loop/`.

## Standard Shape

Use this shape when the work is too large for one chat:

```text
repo/
├── docs/agent-loops/
│   ├── README.md                  # human overview and runbook
│   ├── <loop-name>-action.md      # mission, hard rules, stop conditions
│   ├── <loop-name>-queue.md       # curated work queue; no live-ticket scraping per pass
│   ├── <loop-name>-ledger.md      # append-only loop history + current handoff
│   ├── <loop-name>-validation.md  # validation matrix by touched surface
│   └── prompts/
│       ├── fix-agent.md           # implementation-pass contract + required final markers
│       └── validator-agent.md     # independent validation-pass contract + final markers
├── scripts/
│   ├── run-<loop-name>.sh         # bounded loop runner
│   └── run-<loop-name>-supervised.sh # stale-run monitor / restart wrapper
```

For long-running local worktrees, keep logs outside the repo under `../_loop-runs/<repo-name>/`, write checkpoint refs, and never push automatically.

## Agents As A Software Factory

The factory principle is to stop treating an agent like a single genius worker and start treating it like a production system.

In a factory, work moves through stations. Each station has a contract, a narrow job, an output format, and a quality gate. Agent loops should work the same way:

```text
work intake -> scoped task -> worker agent -> proof -> QA agent -> checkpoint -> next handoff
```

The human designs the line. The runner enforces the line. The agents operate inside the line.

- **Intake**: turn vague goals into a queue of small, ordered work items.
- **Worker station**: let the agent change code, but only for one bounded item.
- **Proof station**: require a local repro, test, metric, or code-path proof before claiming progress.
- **QA station**: run an independent validator that can reject the work.
- **Memory station**: update the ledger so the next pass starts with concrete state, not rediscovery.
- **Ratchet station**: checkpoint accepted work and quarantine rejected work.
- **Supervisor station**: watch for stale runs, empty output, and repeated failure.

Common factory lines:

- **Issue burn-down line**: curated backlog -> worker -> commit -> QA -> checkpoint -> next issue.
- **Modernization line**: migration milestone -> bounded code slice -> runtime gates -> ledger handoff -> next slice.
- **Optimization line**: idea -> benchmark -> score -> keep/revert -> experiment log -> next idea.
- **Review gate line**: implementation -> independent review -> findings -> fixes -> final validation.
- **Supervisor line**: runner -> stale detection -> restart or stop -> durable logs.

These lines can be mixed. A serious long-horizon run often uses all of them: queue for intake, worker for implementation, review gate for QA, metric loop for optimization, and supervisor for overnight continuity.

## Core Primitives

Every useful line uses the same primitives:

1. **Action contract** — tells the agent what outcome matters and what is out of scope.
2. **Queue / handoff** — prevents rediscovery; keeps the next iteration concrete.
3. **Prompt templates** — stable fixer/validator roles with machine-parseable final fields.
4. **Runner** — launches the agent, captures logs, detects empty or stale attempts.
5. **Validation contract** — maps changed files to required checks.
6. **Progress ratchet** — commit, checkpoint ref, ledger entry, or metric log per accepted loop.
7. **Supervisor** — restarts stale batches, stashes/quarantines dirty failed attempts if safe.

## Concrete Example

Suppose a repo has 120 small quality issues, 20 flaky validation failures, and a migration from old API handlers to a new service boundary.

Do not ask an agent to "clean up the repo."

Build a queue:

```text
[ ] make one config error actionable
[ ] move one handler to the new service boundary
[ ] add regression coverage for one flaky path
[ ] verify one old bug is already closed
```

Then let the loop run:

```text
item 1 -> fixer commits -> validator passes -> checkpoint
item 2 -> fixer commits -> validator rejects -> rollback + rejected ref
item 3 -> fixer commits -> validator passes -> checkpoint
next handoff tells tomorrow's agent exactly where to continue
```

That is the factory: small slices, hard gates, durable memory, no vague progress.

## References And Lineage

This repo packages the loop mechanics into a public-safe factory template, but the ideas come from real agent-loop work:

- Geoffrey Huntley's Ralph loop writing: <https://ghuntley.com/ralph/> and <https://ghuntley.com/loop/>
- The Ralph playbook: <https://github.com/ghuntley/how-to-ralph-wiggum>
- Andrej Karpathy's autoresearch loop: <https://github.com/karpathy/autoresearch>
- Shopify's generalization of autoresearch beyond model training: <https://shopify.engineering/autoresearch>
- Hamel Husain's Claude review-loop plugin: <https://github.com/hamelsmu/claude-review-loop>

This project does not vendor those implementations. It distills the shared factory primitives: queue, worker, proof, QA, ledger, checkpoint, supervisor.

