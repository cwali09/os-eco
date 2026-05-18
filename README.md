# os-eco

[![Warren CI](https://github.com/jayminwest/warren/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/warren/actions/workflows/ci.yml)
[![Burrow CI](https://github.com/jayminwest/burrow/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/burrow/actions/workflows/ci.yml)
[![Plot CI](https://github.com/jayminwest/plot/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/plot/actions/workflows/ci.yml)
[![Mulch CI](https://github.com/jayminwest/mulch/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/mulch/actions/workflows/ci.yml)
[![Seeds CI](https://github.com/jayminwest/seeds/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/seeds/actions/workflows/ci.yml)
[![Canopy CI](https://github.com/jayminwest/canopy/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/canopy/actions/workflows/ci.yml)
[![Sapling CI](https://github.com/jayminwest/sapling/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/sapling/actions/workflows/ci.yml)
[![Overstory CI](https://github.com/jayminwest/overstory/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/overstory/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A self-hostable control plane for AI coding agents — and the integrated toolchain it sits on top of.

<p align="center">
  <img src="branding/logo.png" alt="os-eco" width="444" />
</p>

## Warren — the agent control plane

[**Warren**](https://github.com/jayminwest/warren) is the headline project. Point it at a GitHub repo, pick an agent, write a prompt; warren spawns the agent inside a sandbox, streams events back to a live UI, lets you steer mid-run, and pushes the workspace branch when it's done.

- **Self-hostable.** One container, one volume, one HTTP API, one UI. Run it on a home server, a Fly app, or a cluster.
- **Sandboxed per run.** Every run gets a fresh isolated workspace via [burrow](#substrate); the host is unreachable.
- **Closes the autonomous loop.** Polls GitHub for triaged issues, dispatches runs, opens PRs. No external daemon.
- **Standalone first.** Ships with the `claude-code` and `sapling` agents inline — fresh-install only needs a GitHub URL and an Anthropic key.

```bash
git clone https://github.com/jayminwest/warren && cd warren
cp .env.example .env
docker compose up -d
open http://localhost:8080
```

The rest of os-eco is the toolchain warren stands on. Each piece works standalone too, but together they form one coherent agent operating system.

## The toolchain

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

### Substrate — sandbox & coordination

| Tool | CLI | npm | What it does |
|------|-----|-----|--------------|
| [**Burrow**](https://github.com/jayminwest/burrow) | `burrow` / `bw` | [![npm](https://img.shields.io/npm/v/@os-eco/burrow-cli)](https://www.npmjs.com/package/@os-eco/burrow-cli) | OS-isolated sandbox runtime — `bwrap` on Linux, `sandbox-exec` on macOS. No Docker, no daemon. Warren embeds it per run; usable standalone for any coding agent. |
| [**Plot**](https://github.com/jayminwest/plot) | `plot` | [![npm](https://img.shields.io/npm/v/@os-eco/plot-cli)](https://www.npmjs.com/package/@os-eco/plot-cli) | Typed, queryable coordination object for multi-agent work — binds together seeds issues, mulch records, prompts, runs, and PRs around a single unit of work. The substrate warren uses to keep humans and agents on the same page. |

### Context primitives — what agents read & write

| Tool | CLI | npm | What it does |
|------|-----|-----|--------------|
| [**Mulch**](https://github.com/jayminwest/mulch) | `mulch` / `ml` | [![npm](https://img.shields.io/npm/v/@os-eco/mulch-cli)](https://www.npmjs.com/package/@os-eco/mulch-cli) | Structured expertise management — record conventions, patterns, and decisions as you work; retrieve them at the start of every session. In production across multiple engineering teams as the memory layer for their Claude Code / agent workflows. |
| [**Seeds**](https://github.com/jayminwest/seeds) | `sd` | [![npm](https://img.shields.io/npm/v/@os-eco/seeds-cli)](https://www.npmjs.com/package/@os-eco/seeds-cli) | Git-native issue tracking — JSONL storage, dependency graphs, structured plans for LLM decomposition, zero external dependencies. The primary planning and tracking surface for agent work. |
| [**Canopy**](https://github.com/jayminwest/canopy) | `cn` | [![npm](https://img.shields.io/npm/v/@os-eco/canopy-cli)](https://www.npmjs.com/package/@os-eco/canopy-cli) | Prompt management — version-controlled prompt composition with inheritance, pinning, and schema validation. |

### Runtime — single-agent execution

| Tool | CLI | npm | What it does |
|------|-----|-----|--------------|
| [**Sapling**](https://github.com/jayminwest/sapling) | `sp` | [![npm](https://img.shields.io/npm/v/@os-eco/sapling-cli)](https://www.npmjs.com/package/@os-eco/sapling-cli) | Headless coding agent with proactive context management between every LLM call. An alternative runtime warren can dispatch alongside Claude Code. |

## Shared design principles

Every tool in os-eco shares the same shape:

- **Git-native storage** — JSONL and YAML files that live in your repo, merge cleanly, and need no external database
- **Zero runtime dependencies** — each tool is a single Bun binary with no daemon or server
- **Multi-agent safe** — advisory file locking so concurrent agents don't corrupt shared state
- **CLI-first** — every operation is a shell command with `--json` output for scripting and piping
- **Consistent UX** — shared color palette, status icons, help screen layout, and flag conventions

## Quick start

The headline path is warren. Requires Docker.

```bash
git clone https://github.com/jayminwest/warren && cd warren
cp .env.example .env       # add ANTHROPIC_API_KEY + GITHUB_TOKEN
docker compose up -d
open http://localhost:8080
```

Each tool also stands alone. Install only what you need with [Bun](https://bun.sh/) >= 1.0:

```bash
# Context primitives
bun install -g @os-eco/mulch-cli      # expertise
bun install -g @os-eco/seeds-cli      # issues
bun install -g @os-eco/canopy-cli     # prompts

# Substrate
bun install -g @os-eco/burrow-cli     # sandbox
bun install -g @os-eco/plot-cli       # coordination

# Runtime
bun install -g @os-eco/sapling-cli    # headless agent
```

Initialize the data layer in a project:

```bash
cd your-project
ml init && sd init && cn init
ml --version && sd --version && cn --version
```

## Example workflow

```bash
# An agent starts a session
ml prime                              # load project expertise into context
sd ready                              # find unblocked issues to work on
sd update sd-a1b2 --status in_progress

# Agent does work, then wraps up
ml record testing --type convention \
  --description "Always mock fs in unit tests"
sd close sd-a1b2

# Multi-agent coordination via plot
plot init "Add OAuth to billing portal"
plot attach plot-abc1 seeds_issue:sd-a1b2 --role tracks

# Cloud orchestration via warren
# (see warren/README.md for the full UI + API surface)
```

## Alternative orchestrator

[**Overstory**](https://github.com/jayminwest/overstory) (`overstory` / `ov`, `@os-eco/overstory-cli`) is a local-first orchestrator: it spawns agents in tmux + git worktrees, coordinates through a SQLite mail layer, and merges with conflict resolution. Choose it over warren when you want a local-only workflow with no HTTP control plane.

```bash
bun install -g @os-eco/overstory-cli
cd your-project && ov init
ov sling sd-c3d4 --strategy worktree     # spawn an agent for an issue
```

## Repo structure

Each tool lives in its own sub-repo with independent git history, CI, and npm versioning. This meta-repo tracks cross-cutting concerns:

```
os-eco/
  warren/          # sub-repo: @os-eco/warren-cli         — headline control plane
  burrow/          # sub-repo: @os-eco/burrow-cli         — sandbox primitive
  plot/            # sub-repo: @os-eco/plot-cli           — coordination object
  mulch/           # sub-repo: @os-eco/mulch-cli          — expertise
  seeds/           # sub-repo: @os-eco/seeds-cli          — issues
  canopy/          # sub-repo: @os-eco/canopy-cli         — prompts
  sapling/         # sub-repo: @os-eco/sapling-cli        — headless agent
  overstory/       # sub-repo: @os-eco/overstory-cli      — local orchestrator
  branding/        # shared visual spec, CLI standards, checklists
  .mulch/          # ecosystem-level expertise
  .seeds/          # ecosystem-level issues
  .canopy/         # shared prompt templates
  .overstory/      # multi-repo orchestration config
```

## Development

```bash
# Run tests, lint, and typecheck for any tool
cd warren     && bun test && bun run lint && bun run typecheck
cd burrow     && bun test && bun run lint && bun run typecheck
cd plot       && bun test && bun run lint && bun run typecheck
cd mulch      && bun test && bun run lint && bun run typecheck
cd seeds      && bun test && bun run lint && bun run typecheck
cd canopy     && bun test && bun run lint && bun run typecheck
cd sapling    && bun test && bun run lint && bun run typecheck
cd overstory  && bun test && bun run lint && bun run typecheck
```

## Retired tools

| Tool | Status | Notes |
|------|--------|-------|
| [Greenhouse](https://github.com/jayminwest/greenhouse) | Archived 2026-05 | Autonomous development daemon (polls GitHub → dispatches orchestrator runs → opens PRs). Superseded by **warren**, which absorbed the autonomous-loop role into the same control plane that runs cloud agents. The repo is archived and remains readable for historical reference; the npm package `@os-eco/greenhouse-cli` was never published. |

## License

[MIT](LICENSE)
