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

## Office-Hours Field Guide

This repo is the public-safe version of a short talk on agent harnesses and Ralph loops.

The core argument is simple:

```text
small harness + explicit tools + durable context + boring loop + hard validation = useful agents
```

The main takeaways:

1. **The harness matters more than the chat box.** A coding agent becomes useful when you define the tools it can call, the context it should load, the permissions it has, the checks it must run, and the memory it must update.
2. **Dumb loops beat clever orchestration.** Start with one sequential loop before building multi-agent coordination. Most teams are bottlenecked by specification, review, and release gates, not by the number of agents running in parallel.
3. **The queue is the multiplier.** Repeating one prompt can catch missed work, but the real value comes from a queue of small, ordered, verifiable tasks.
4. **Feedback is the product.** Tests, benchmarks, screenshots, static checks, reviewers, and validators are how the loop learns whether it did useful work. Self-reported success is not enough.
5. **Validation should be independent.** The worker is biased toward believing it is done. A fresh validator, ideally read-only, should inspect the actual diff and rerun the checks.
6. **Safety means reversible progress.** Let agents prepare changes, drafts, and local commits. Do not let them push, publish, send messages, close projects, or touch production systems without a human gate.
7. **Memory belongs in files, not chat.** A ledger and current handoff make the next pass concrete and prevent the agent from rediscovering the same state every run.

Use this repository when you want to turn those ideas into runnable local machinery.

## Quick Start

### 1. Pick The Factory Line

Start with the pattern cards and their copyable `loop/` skeletons. The README in each pattern explains what kind of factory you are building; the `loop/` directory gives you a runnable starting point to adapt in a target repository.

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
├── patterns/                              # pattern cards + copyable loop skeletons
│   ├── queue-burndown-loop/               # queue -> fixer -> validator -> next item
│   ├── modernization-campaign-loop/       # milestone -> slice -> gates -> handoff
│   ├── metric-optimization-loop/          # idea -> metric -> keep/revert -> next idea
│   └── review-gate-loop/                  # implementation -> review -> fix findings
└── template/
    └── generic-codex-queue-loop/          # reusable runnable starter template
```

Each `patterns/*/` directory contains a README plus a `loop/` skeleton. The README explains the factory line. The `loop/` directory is a copyable starting point built on the same tested runner as `template/generic-codex-queue-loop/`, with action/queue/ledger/validation files specialized for that pattern.

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

