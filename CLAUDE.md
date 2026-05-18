# os-eco

Meta-project for the AI agent tooling ecosystem. This repo tracks cross-cutting concerns across **eight integrated tools**, each living in its own sub-repo. (A ninth tool, **greenhouse**, was archived 2026-05 — see "Retired tools" below.)

**Warren is the headline project.** It is the self-hostable control plane that orchestrates ephemeral cloud agents and closes the autonomous loop (GitHub → dispatch → PR). The rest of os-eco is the toolchain warren stands on. Each piece works standalone too, but warren is where the ecosystem narrative begins.

## Ecosystem Overview

Tools group by role: **warren** is the flagship orchestrator. Underneath sit the **substrate** (sandbox + coordination), the **context primitives** (what agents read & write), and a **runtime** (single-agent execution). **Overstory** is an alternative local-first orchestrator.

### Flagship — agent control plane

| Tool | CLI | npm | Purpose | Sub-repo |
|------|-----|-----|---------|----------|
| **Warren** | `warren` | `@os-eco/warren-cli` | Self-hostable control plane for ephemeral cloud agents; polls GitHub → dispatches runs → opens PRs. Absorbed greenhouse's autonomous-loop role 2026-05. | `warren/` |

### Substrate — sandbox & coordination

| Tool | CLI | npm | Purpose | Sub-repo |
|------|-----|-----|---------|----------|
| **Burrow** | `burrow` / `bw` | `@os-eco/burrow-cli` | OS-isolated sandbox runtime (bwrap on Linux, sandbox-exec on macOS). Warren embeds it per run; usable standalone. | `burrow/` |
| **Plot** | `plot` | `@os-eco/plot-cli` | Typed, queryable coordination object — binds seeds issues, mulch records, prompts, runs, and PRs around a unit of work. The substrate warren uses to keep humans and agents in sync. | `plot/` |

### Context primitives — what agents read & write

| Tool | CLI | npm | Purpose | Sub-repo |
|------|-----|-----|---------|----------|
| **Mulch** | `mulch` / `ml` | `@os-eco/mulch-cli` | Structured expertise management. In production across multiple engineering teams as the memory layer for their agent workflows. | `mulch/` |
| **Seeds** | `sd` | `@os-eco/seeds-cli` | Git-native issue tracking with structured plans for LLM decomposition. Primary planning and tracking surface for agent work. | `seeds/` |
| **Canopy** | `cn` | `@os-eco/canopy-cli` | Prompt management & composition (inheritance, pinning, schema validation). | `canopy/` |

### Runtime — single-agent execution

| Tool | CLI | npm | Purpose | Sub-repo |
|------|-----|-----|---------|----------|
| **Sapling** | `sapling` / `sp` | `@os-eco/sapling-cli` | Headless coding agent with proactive context management. Alternative runtime warren can dispatch alongside Claude Code. | `sapling/` |

### Alternative orchestrator

| Tool | CLI | npm | Purpose | Sub-repo |
|------|-----|-----|---------|----------|
| **Overstory** | `overstory` / `ov` | `@os-eco/overstory-cli` | Local-first multi-agent orchestration via tmux + git worktrees. Choose over warren when you want a local-only workflow with no HTTP control plane. | `overstory/` |

### How they fit together

```
                              Warren  (cloud control plane)
                                 │
                  ┌──────────────┼──────────────┐
                  │              │              │
              Substrate       Context        Runtime
              ─────────       ───────        ───────
              Burrow          Mulch          Sapling
              Plot            Seeds
                              Canopy
```

- **Warren** is the flagship — a self-hostable HTTP/UI control plane that polls GitHub for triaged issues, dispatches runs, opens PRs, and runs each agent inside a burrow sandbox. Absorbed greenhouse's daemon role in 2026-05.
- **Burrow** is the sandbox primitive — bwrap on Linux, sandbox-exec on macOS. Used directly or embedded inside warren.
- **Plot** is the coordination object — a binder that holds intent, attachments, and event log for a unit of work. Warren bundles it as a feature; it stands alone too.
- **Mulch** is the expertise layer — agents call `ml record` / `ml prime` to store and retrieve learnings across sessions.
- **Seeds** is the issue tracker — `sd create` / `sd ready` / `sd close` drive the work queue.
- **Canopy** is the prompt library — `cn emit` renders prompts for agent consumption.
- **Sapling** is an alternative coding agent runtime.
- **Overstory** is the local-first orchestrator — tmux + git worktrees, top-down decomposition, SQLite mail.

Each sub-repo has its own `CLAUDE.md` with tool-specific conventions, architecture, and commands.

## Root-Level Tool Instances

The root `.mulch/`, `.seeds/`, `.canopy/`, and `.overstory/` directories are for **cross-repo concerns**:
- Use root `.seeds/` for ecosystem-wide issues (integration bugs, cross-tool features)
- Use root `.mulch/` for ecosystem-level expertise (the `ecosystem` domain)
- Use root `.canopy/` for shared prompt templates
- Use root `.overstory/` for multi-repo orchestration

## Build & Test Commands

All tools use Bun. Run from the respective sub-repo:

```bash
cd warren      && bun test && bun run lint && bun run typecheck
cd burrow      && bun test && bun run lint && bun run typecheck
cd plot        && bun test && bun run lint && bun run typecheck
cd mulch       && bun test && bun run lint && bun run typecheck
cd seeds       && bun test && bun run lint && bun run typecheck
cd canopy      && bun test && bun run lint && bun run typecheck
cd sapling     && bun test && bun run lint && bun run typecheck
cd overstory   && bun test && bun run lint && bun run typecheck
```

## Retired tools

- **Greenhouse** (`greenhouse` / `grhs`, `@os-eco/greenhouse-cli`) — archived 2026-05. Was the autonomous development daemon (GitHub poll → dispatch → PR). Superseded by warren, which absorbed the autonomous-loop role into the same control plane that runs cloud agents. The greenhouse GitHub repo (https://github.com/jayminwest/greenhouse) is archived and readable for historical context; the npm package was never published; the local sub-repo was removed. Records and seeds issues that reference greenhouse are kept for traceability but marked obsolete.

## Scripts

- `scripts/run-plan.sh <plan-id>` — sequential, non-parallel alternative to `ov sling`. For each open child of a seeds plan, runs `claude -p "work on sd <id>..."` with `--permission-mode bypassPermissions`, logs to `.run-plan-logs/<plan>/<id>.log`, stops on the first non-zero exit. Idempotent: skips closed children on re-runs. Requires `sd`, `claude`, `jq` on PATH.

## Conventions

- Sub-repos are independently versioned and managed — each has its own git history
- The root git repo ignores all sub-repo directories (see `.gitignore`)
- Cross-repo issues go in root `.seeds/`; per-tool issues go in each sub-repo's `.seeds/`
- When making changes that span multiple tools, file a root-level issue to track the integration

<!-- mulch:start -->
## Project Expertise (Mulch)
<!-- mulch-onboard-v:2 -->

This project uses [Mulch](https://github.com/jayminwest/mulch) for structured expertise management.

**At the start of every session**, run:
```bash
ml prime
```

Injects project-specific conventions, patterns, decisions, failures, references, and guides into
your context. Run `ml prime --files src/foo.ts` before editing a file to load only records
relevant to that path (per-file framing, classification age, and confirmation scores included).

**Before completing your task**, record insights worth preserving — conventions discovered,
patterns applied, failures encountered, or decisions made:
```bash
ml record <domain> --type <convention|pattern|failure|decision|reference|guide> --description "..."
```

Evidence auto-populates from git (current commit + changed files). Link explicitly with
`--evidence-seeds <id>` / `--evidence-gh <id>` / `--evidence-linear <id>` / `--evidence-bead <id>`,
`--evidence-commit <sha>`, or `--relates-to <mx-id>`. Upserts of named records merge outcomes
instead of replacing them; validation failures print a copy-paste retry hint with missing fields
pre-filled.

Run `ml status` for domain health, `ml doctor` to check record integrity (add `--fix` to strip
broken file anchors), `ml --help` for the full command list. Write commands use file locking and
atomic writes, so multiple agents can record concurrently. Expertise survives `git worktree`
cleanup — `.mulch/` resolves to the main repo.

### Before You Finish

1. Discover what to record (shows changed files and suggests domains):
   ```bash
   ml learn
   ```
2. Store insights from this work session:
   ```bash
   ml record <domain> --type <convention|pattern|failure|decision|reference|guide> --description "..."
   ```
3. Validate and commit:
   ```bash
   ml sync
   ```
<!-- mulch:end -->

<!-- seeds:start -->
## Issue Tracking (Seeds)
<!-- seeds-onboard-v:1 -->

This project uses [Seeds](https://github.com/jayminwest/seeds) for git-native issue tracking.

**At the start of every session**, run:
```
sd prime
```

This injects session context: rules, command reference, and workflows.

**Quick reference:**
- `sd ready` — Find unblocked work
- `sd create --title "..." --type task --priority 2` — Create issue
- `sd update <id> --status in_progress` — Claim work
- `sd close <id>` — Complete work
- `sd sync` — Sync with git (run before pushing)

### Before You Finish
1. Close completed issues: `sd close <id>`
2. File issues for remaining work: `sd create --title "..."`
3. Sync and push: `sd sync && git push`
<!-- seeds:end -->

<!-- canopy:start -->
## Prompt Management (Canopy)
<!-- canopy-onboard-v:1 -->

This project uses [Canopy](https://github.com/jayminwest/canopy) for git-native prompt management.

**At the start of every session**, run:
```
cn prime
```

This injects prompt workflow context: commands, conventions, and common workflows.

**Quick reference:**
- `cn list` — List all prompts
- `cn render <name>` — View rendered prompt (resolves inheritance)
- `cn emit --all` — Render prompts to files
- `cn update <name>` — Update a prompt (creates new version)
- `cn sync` — Stage and commit .canopy/ changes

**Do not manually edit emitted files.** Use `cn update` to modify prompts, then `cn emit` to regenerate.
<!-- canopy:end -->
