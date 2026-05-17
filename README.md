# os-eco

[![Mulch CI](https://github.com/jayminwest/mulch/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/mulch/actions/workflows/ci.yml)
[![Seeds CI](https://github.com/jayminwest/seeds/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/seeds/actions/workflows/ci.yml)
[![Canopy CI](https://github.com/jayminwest/canopy/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/canopy/actions/workflows/ci.yml)
[![Sapling CI](https://github.com/jayminwest/sapling/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/sapling/actions/workflows/ci.yml)
[![Burrow CI](https://github.com/jayminwest/burrow/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/burrow/actions/workflows/ci.yml)
[![Overstory CI](https://github.com/jayminwest/overstory/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/overstory/actions/workflows/ci.yml)
[![Warren CI](https://github.com/jayminwest/warren/actions/workflows/ci.yml/badge.svg)](https://github.com/jayminwest/warren/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An integrated ecosystem of CLI tools for AI agent workflows. Each tool handles one concern — expertise, issues, prompts, runtime, sandbox, orchestration, or the autonomous loop — and they compose together so multi-agent teams can operate on real codebases.

<p align="center">
  <img src="branding/logo.png" alt="os-eco" width="444" />
</p>

## Tools

Grouped by role: **primitives** hold the data agents need, **runtimes** execute a single agent, **orchestrators** coordinate many, and a **daemon** closes the autonomous loop.

### Primitives — context, issues, prompts

| Tool | CLI | npm | What it does |
|------|-----|-----|-------------|
| [**Mulch**](https://github.com/jayminwest/mulch) | `mulch` / `ml` | [![npm](https://img.shields.io/npm/v/@os-eco/mulch-cli)](https://www.npmjs.com/package/@os-eco/mulch-cli) | Structured expertise management — record conventions, patterns, and decisions as you work, retrieve them at the start of every session |
| [**Seeds**](https://github.com/jayminwest/seeds) | `sd` | [![npm](https://img.shields.io/npm/v/@os-eco/seeds-cli)](https://www.npmjs.com/package/@os-eco/seeds-cli) | Git-native issue tracking — JSONL storage, dependency graphs, templates, zero external dependencies |
| [**Canopy**](https://github.com/jayminwest/canopy) | `cn` | [![npm](https://img.shields.io/npm/v/@os-eco/canopy-cli)](https://www.npmjs.com/package/@os-eco/canopy-cli) | Prompt management — version-controlled prompt composition with inheritance, pinning, and schema validation |

### Runtimes — single-agent execution

| Tool | CLI | npm | What it does |
|------|-----|-----|-------------|
| [**Sapling**](https://github.com/jayminwest/sapling) | `sp` | [![npm](https://img.shields.io/npm/v/@os-eco/sapling-cli)](https://www.npmjs.com/package/@os-eco/sapling-cli) | Headless coding agent — proactive context management between every LLM call, pluggable backends |
| [**Burrow**](https://github.com/jayminwest/burrow) | `burrow` / `bw` | [![npm](https://img.shields.io/npm/v/@os-eco/burrow-cli)](https://www.npmjs.com/package/@os-eco/burrow-cli) | OS-isolated sandbox runtime — `bwrap` on Linux, `sandbox-exec` on macOS; no Docker, no daemon |

### Orchestrators — multi-agent coordination & autonomous loop

| Tool | CLI | npm | What it does |
|------|-----|-----|-------------|
| [**Overstory**](https://github.com/jayminwest/overstory) | `overstory` / `ov` | [![npm](https://img.shields.io/npm/v/@os-eco/overstory-cli)](https://www.npmjs.com/package/@os-eco/overstory-cli) | Local multi-agent orchestration — spawns agents in git worktrees via tmux, coordinates through SQLite mail, merges with conflict resolution |
| [**Warren**](https://github.com/jayminwest/warren) | `warren` | [![npm](https://img.shields.io/npm/v/@os-eco/warren-cli)](https://www.npmjs.com/package/@os-eco/warren-cli) | Self-hostable control plane for ephemeral cloud agents — one container, one volume, one HTTP API, one UI; embeds burrow per run. Also closes the autonomous loop (GitHub → dispatch → PR), the role formerly held by [greenhouse](#retired-tools) |

## How they fit together

```
warren                           autonomous outer loop (GitHub → dispatch → PR)
   │                             and cloud control plane
   ├─► overstory  (local)        local orchestrator: tmux + worktrees
   │
   └─► sapling                   runtimes execute a single agent
       burrow                    (warren embeds burrow for sandboxed runs)
          │
          ├─► mulch              primitives feed agents context
          ├─► seeds              (expertise, work queue, prompts)
          └─► canopy
```

Warren closes the manual loop and orchestrates cloud runs; overstory handles local multi-agent decomposition; sandbox primitives keep execution safe; data primitives feed every agent the context it needs. All tools share the same design principles:

- **Git-native storage** — JSONL and YAML files that live in your repo, merge cleanly, and need no external database
- **Zero runtime dependencies** — each tool is a single Bun binary with no daemon or server
- **Multi-agent safe** — advisory file locking so concurrent agents don't corrupt shared state
- **CLI-first** — every operation is a shell command with `--json` output for scripting and piping
- **Consistent UX** — shared color palette, status icons, help screen layout, and flag conventions

## Quick start

Requires [Bun](https://bun.sh/) >= 1.0.

```bash
# Install the data + runtime layer
bun install -g \
  @os-eco/mulch-cli \
  @os-eco/seeds-cli \
  @os-eco/canopy-cli \
  @os-eco/sapling-cli \
  @os-eco/burrow-cli

# Add orchestration as you need it
bun install -g @os-eco/overstory-cli       # local, tmux + worktrees
bun install -g @os-eco/warren-cli          # self-hostable cloud control plane + autonomous loop

# Initialize in your project
cd your-project
ml init && sd init && cn init && ov init

# Verify
ml --version && sd --version && cn --version && sp version && ov --version
```

Each tool works standalone — install just the ones you need:

```bash
bun install -g @os-eco/seeds-cli    # just issue tracking
bun install -g @os-eco/mulch-cli    # just expertise management
bun install -g @os-eco/burrow-cli   # just the sandbox primitive
```

## Example workflow

```bash
# An agent starts a session
ml prime                              # load project expertise into context
sd ready                              # find unblocked issues to work on
sd update seed-a1b2 --status in_progress

# Agent does work, then wraps up
ml record testing --type convention \
  --description "Always mock fs in unit tests"
sd close seed-a1b2

# Local multi-agent orchestration
ov sling seed-c3d4 --strategy worktree   # spawn an agent for an issue
ov status                                 # monitor running agents
ov merge builder-01                       # merge completed work back

# Cloud control plane — one container, one volume
git clone https://github.com/jayminwest/warren && cd warren
cp .env.example .env && docker compose up -d
open http://localhost:8080
```

## Repo structure

Each tool lives in its own sub-repo with independent git history, CI, and npm versioning. This meta-repo tracks cross-cutting concerns:

```
os-eco/
  mulch/           # sub-repo: @os-eco/mulch-cli
  seeds/           # sub-repo: @os-eco/seeds-cli
  canopy/          # sub-repo: @os-eco/canopy-cli
  sapling/         # sub-repo: @os-eco/sapling-cli
  burrow/          # sub-repo: @os-eco/burrow-cli
  overstory/       # sub-repo: @os-eco/overstory-cli
  warren/          # sub-repo: @os-eco/warren-cli
  branding/        # shared visual spec, CLI standards, checklists
  .mulch/          # ecosystem-level expertise
  .seeds/          # ecosystem-level issues
  .canopy/         # shared prompt templates
  .overstory/      # multi-repo orchestration config
```

## Development

```bash
# Run tests, lint, and typecheck for any tool
cd mulch      && bun test && bun run lint && bun run typecheck
cd seeds      && bun test && bun run lint && bun run typecheck
cd canopy     && bun test && bun run lint && bun run typecheck
cd sapling    && bun test && bun run lint && bun run typecheck
cd burrow     && bun test && bun run lint && bun run typecheck
cd overstory  && bun test && bun run lint && bun run typecheck
cd warren     && bun test && bun run lint && bun run typecheck

# Check ecosystem health
ov doctor          # checks all tools are installed and healthy
ov ecosystem       # dashboard with versions, health, and status
```

## Retired tools

| Tool | Status | Notes |
|------|--------|-------|
| [Greenhouse](https://github.com/jayminwest/greenhouse) | Archived 2026-05 | Autonomous development daemon (polls GitHub → dispatches orchestrator runs → opens PRs). Superseded by **warren**, which absorbed the autonomous-loop role into the same control plane that runs cloud agents. The repo is archived and remains readable for historical reference; the npm package `@os-eco/greenhouse-cli` was never published. |

## License

[MIT](LICENSE)
