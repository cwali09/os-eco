# Pi Extensions for the os-eco Ecosystem — Investigation

**Status:** Investigation / design proposal. Building proceeds against `pi-mulch`, `pi-seeds`, `pi-canopy` only.
**V1 scope:** `pi-mulch`, `pi-seeds`, `pi-canopy`.
**Deferred to v0.2 (kept in doc as context, not in build queue):** `pi-burrow`, `pi-warren`.

> See [Appendix A: prime + config surface audit](#appendix-a-prime--config-surface-audit) for the empirical results that ground the design choices below.
**Out of scope:** sapling (already a pi-style agent runtime), overstory (orchestrator, runs pi *under* it). (Greenhouse, the autonomous daemon that originally dispatched pi runs, was archived 2026-05 and replaced by warren.)

## Why extensions

[Pi](https://github.com/earendil-works/pi-coding-agent) is the coding-agent harness most users run our primitives *under*. Today integration is purely conventional:

- We document `ml prime` / `sd prime` / `cn prime` in `CLAUDE.md` files and tell agents to run them at session start.
- We rely on the LLM noticing those instructions and calling out to bash.
- Recording new expertise, claiming issues, rendering prompts — all of it happens by the model deciding to shell out.

This works, but it's lossy and brittle. The agent forgets `ml prime` mid-session, fails to `sd close` on completion, or never thinks to record a `failure` record after a debug detour. Pi extensions let us hard-wire those rituals into lifecycle events instead of relying on prompt discipline.

The five tools split cleanly into three integration patterns:

| Tool    | Pattern               | Primary pi surface                                                |
|---------|-----------------------|--------------------------------------------------------------------|
| mulch   | passive store         | `session_start` priming, `tool_call` scope-loading, `agent_end` record-nudge |
| seeds   | issue queue           | autocomplete, custom commands, structured tools, status widget    |
| canopy  | prompt library        | `resources_discover` to register prompts as slash commands        |
| burrow  | sandbox primitive     | `user_bash` + bash tool override, like the `sandbox` example      |
| warren  | cloud orchestrator    | custom tool + command to dispatch / steer remote runs             |

Each extension below has the same shape: **what it does, hooks it uses, tools/commands it exposes, open questions, similar example to crib from.**

---

## 1. `@os-eco/pi-mulch` — passive expertise loader

**Goal:** make project expertise show up automatically; make recording it part of the agent's exit ritual rather than a thing the LLM may or may not remember.

### Hooks

- **`session_start`** — shell `ml prime --json` (or `ml prime` if json mode is added) and either
  - inject the rendered markdown via `before_agent_start` as a `systemPrompt` append, or
  - inject it as a persistent custom message (`pi.sendMessage({ customType: "mulch-prime", … })`) so the user sees what was loaded.
  - In **manifest mode** (set in `mulch.config.yaml`), emit only the domain index at startup and scope-load on demand.
- **`tool_call`** for `read` / `edit` / `write` — when the LLM is about to touch a file, fire `ml prime --files <path> --json` in the background and append the resulting records via `sendMessage(..., { deliverAs: "steer" })`. This realizes the per-file framing mulch already supports, but currently requires the agent to remember to run.
- **`agent_end`** — call `ml learn --json` to detect changed files / suggested domains, then surface a non-blocking widget (`ctx.ui.setWidget("mulch", […])`) prompting the user (or LLM, on the next turn) to record insights. Optional: a slash command `/ml:record` that walks through the type → domain → description fields via `ctx.ui.select` / `ctx.ui.input`.

### Custom tools

- `record_expertise(domain, type, description, evidence?)` — wraps `ml record …`. Lets the LLM record without escaping into bash. `promptGuidelines` should be a single sentence telling the LLM to call `record_expertise` whenever a new convention/failure/pattern is established.
- `query_expertise(query, domain?, files?)` — wraps `ml search` / `ml prime --files`. Cheaper than re-running prime in bash and the result is structured.

### Commands

- `/ml:prime [domain?]` — re-run prime mid-session (re-injects).
- `/ml:status` — wraps `ml status`, renders in the TUI.
- `/ml:doctor` — wraps `ml doctor`.

### Notes & open questions

- Mulch already has a `setup` recipe per agent runtime (claude, cursor, codex). Pi would be the **first runtime where setup is an extension rather than a hook script.** Adding a `pi` recipe to `src/commands/setup.ts` is the natural counterpart: it installs/symlinks the extension and seeds default config.
- Need to define how mulch's `pre-prime` / `post-record` hooks interact with the extension. Probably: extension fires `ml record` like any other client; hooks run inside `ml`, not in pi.
- `ml prime` output today is markdown shaped for prompt injection. Good fit for `systemPrompt`. We may want a `--format json` flag on mulch to make UI rendering cleaner.
- Closest example: combine `dynamic-resources/index.ts` (for the `resources_discover` shape if we register prompt templates), `dynamic-tools.ts` (for the runtime-registered tools), and `summarize.ts` (for the session-event lifecycle pattern).

---

## 2. `@os-eco/pi-seeds` — issue queue integration

**Goal:** make the seeds work queue first-class in pi the way GitHub issues are with `gh`. Status visible in the footer, fast `sd …` autocomplete, structured tools so the LLM doesn't have to parse human output.

### Hooks

- **`session_start`** — run `sd prime --json` and inject context, same as `ml prime`. Also load the list of `sd ready` IDs into memory for autocomplete.
- **`session_start` / `resources_discover`** — set a status widget: `"sd: 3 ready / 1 in-progress / blocked: 2"` via `ctx.ui.setStatus`.
- **`tool_call`** on `bash` — if the LLM is about to run `sd close <id>`, optionally confirm or just record what was closed in the widget.
- **`agent_end`** — if any tool call mutated `.seeds/issues.jsonl`, refresh the cached ready list and status line.
- **`input`** — intercept `#sd-1a2b3` style references and expand them to a short `sd show` blob the LLM can read (cheap context boost).

### Custom tools

- `sd_create({ title, type, priority, … })`
- `sd_ready()` — returns the unblocked queue as structured JSON.
- `sd_show(id)`
- `sd_update(id, fields)` — status, priority, labels, deps.
- `sd_close(id, { reason? })`
- `sd_dep(action, id, depId)` — add / remove / list.

All wrap the existing `sd …` commands. Since seeds already supports `--json` on most commands, these are thin shims.

### Autocomplete

Direct port of `github-issue-autocomplete.ts`:

- Trigger on `#` token. Preload `sd list --json` once per session.
- Resolve numeric prefix matches first (`#sd-1a2…`), then fuzzy by title.
- Cache invalidates on `agent_end` if we detect a write.

### Commands

- `/sd` — short reference (mirrors `sd prime` top bullets).
- `/sd:ready`, `/sd:create`, `/sd:show <id>`, `/sd:close <id>` — TUI-rendered.
- `/sd:claim <id>` — `sd update <id> --status in_progress`, then set a `currentIssue` status line.

### Notes & open questions

- Pi shortcut for "what am I working on" — keep a tiny extension state `{ currentIssueId?: string }` persisted via `pi.appendEntry("seeds-state", …)` so it survives `/reload`.
- Worktree-aware: seeds resolves `.seeds/` to the main repo when inside a worktree (same as mulch). Confirm the extension respects `ctx.cwd` and not `process.cwd()`.
- Closest example: `github-issue-autocomplete.ts` for `#` completion, `dynamic-tools.ts` for the tool surface, `status-line.ts` / `custom-footer.ts` for the queue widget.

---

## 3. `@os-eco/pi-canopy` — prompt library as slash commands

**Goal:** every canopy prompt becomes a pi slash command without an explicit emit step.

Canopy today emits prompts to plain `.md` files in `~/.claude/commands/` (or similar) so other tools can pick them up. Pi has native prompt template support — we can skip the emit-to-disk dance entirely.

### Hooks

- **`resources_discover`** — return `promptPaths` for every prompt in `.canopy/` (rendered to a tmpdir on the fly, or — better — register via a virtual path API if pi adds one; otherwise generate on demand).
  - On startup, walk `.canopy/prompts.jsonl`, render each via `cn render <name> --format text`, write to `~/.pi/cache/canopy/<sessionId>/<name>.md`, return that directory.
- **`session_start` reload** — re-render when `.canopy/` changes (file watcher in the extension, or refresh on `/reload`).

### Custom tools

- `render_prompt(name, vars?)` — returns the resolved prompt text so the LLM can compose prompts programmatically (useful for sub-agent setups).
- `list_prompts()` — structured listing for tools that want to pick one.

### Commands

- `/cn:list`, `/cn:render <name>`, `/cn:update <name>` — wrappers around the existing CLI but with TUI rendering.

### Notes & open questions

- Canopy's `cn emit` already targets multiple runtimes (claude code, cursor, codex). Adding a `pi` target in canopy is the alternative path — but **the extension is strictly better** because it eliminates the emit step entirely and the prompts stay in sync as the user edits them.
- Inheritance resolution belongs to canopy. The extension should always call `cn render` rather than reimplementing it.
- Closest example: `dynamic-resources/` for the `resources_discover` shape, `commands.ts` for command registration patterns.

---

## 4. `@os-eco/pi-burrow` — bash-in-sandbox

> **Deferred to v0.2.** Highest design risk (nesting under warren container) and lowest leverage for the daily-driver agent loop. Section retained as design context.

**Goal:** every bash tool call (LLM-issued or user-issued `!`) runs inside a burrow sandbox. This is the os-eco analogue of pi's existing `sandbox/` example, but using burrow as the substrate so the same isolation works on macOS (`sandbox-exec`) and Linux (`bwrap`).

The pi `sandbox/` example is the obvious template — it overrides the `bash` tool, hooks `user_bash`, manages init/teardown in `session_start` / `session_shutdown`, and reads config from `.pi/sandbox.json`. We swap `SandboxManager` (from `@anthropic-ai/sandbox-runtime`) for a burrow client.

### Architecture

Two deployment modes, both worth supporting:

1. **Per-command burrow** — spawn `burrow run -- bash -c <cmd>` per tool call. Simple, slow (cold start per call), but uses burrow's CLI as-is. Fine for ad-hoc work.
2. **Long-lived burrow server** — extension spawns `burrow serve` once during `session_start`, gets a unix socket back, and shells `bash` calls through the HTTP API (see `burrow/src/server/handlers.ts` / `warren/src/burrow-client/`). Tool calls then add a few ms of overhead instead of seconds.

For V1 of the extension, ship mode 1 and document mode 2 as the warren-style fast path.

### Hooks

- **`session_start`** — read `.pi/burrow.json` (or global `~/.pi/agent/extensions/burrow.json`), validate burrow is on PATH, optionally start `burrow serve`, set status (`🐇 burrow: <profile>`).
- **`session_shutdown`** — tear down the server, clean up the workspace mount if ephemeral.
- **Bash tool override** — register a replacement `bash` tool whose `execute()` shells through burrow. Mirrors how the pi `sandbox` example wraps `createBashTool`.
- **`user_bash`** — return `{ operations: createBurrowBashOps() }` so `!` commands also run inside the sandbox.
- **`tool_call`** on `write` / `edit` — optionally enforce path allowlists (burrow's workspace boundary).

### Custom tools

- `burrow_exec({ command, profile?, network?, timeoutMs? })` — explicit sandboxed exec, useful when the LLM wants stricter isolation than the default bash override (e.g. running untrusted scripts).
- `burrow_workspace_snapshot()` / `burrow_workspace_diff()` — tooling around the workspace mount; useful for review steps.

### Commands

- `/burrow` — print current profile, allowed network, mount points.
- `/burrow:profile <name>` — switch profile mid-session.
- `/burrow:logs` — tail burrow events.

### Config shape

```jsonc
{
  "enabled": true,
  "profile": "default",          // burrow profile name
  "network": { "allow": ["github.com", "registry.npmjs.org"] },
  "workspace": { "path": ".", "writable": true },
  "longLived": false             // mode 1 vs mode 2
}
```

### Notes & open questions

- **Nesting:** pi itself is often run inside warren (which runs inside burrow). Nesting burrow inside burrow is an open question — the warren spec calls out `enableWeakerNestedSandbox` for the existing pi `sandbox` example. We need to test whether `bwrap` inside `bwrap` works with the userns flags the warren docker-compose sets, or whether the extension should detect "I'm already in a burrow" and no-op.
- **Path collision with sandbox example:** users shouldn't load both `sandbox/` and `pi-burrow`. Either we detect each other's tool registration, or we document the conflict and let the later one win.
- Closest example: `sandbox/index.ts` is essentially the skeleton. We swap `SandboxManager.wrapWithSandbox()` for either `burrow run -- bash -c …` (mode 1) or HTTP calls to the burrow socket (mode 2, copy `warren/src/burrow-client/` patterns).

---

## 5. `@os-eco/pi-warren` — cloud handoff and dispatch

> **Deferred to v0.2.** Largest surface (workspace setup, SSE-into-TUI, custom overlay), most design work, lowest priority until the data-plane extensions ship. Section retained as design context.

**Goal:** from inside a local pi session, hand work off to a warren cloud run, or pull observability of warren runs into the local TUI.

This is the most ambitious of the five because warren is a control plane, not a CLI primitive. The interesting pi surface is:

- "I'm stuck — dispatch this prompt to a fresh warren agent with the same project" — handoff.
- "Show me the current state of run X" — observability.
- "Steer that run mid-flight" — interactive steering of a remote agent from a local pi.

### Hooks

- **`session_start`** — verify `WARREN_BASE_URL` + auth token; ping `/health`. Set status `☁ warren: <host> (3 runs active)`.
- **Polling** — every N seconds (or via SSE `GET /runs/:id/stream` when watching a specific run), update the status widget with run states.

### Custom tools

- `warren_run({ agent, projectId, prompt, branch? })` — calls `POST /runs`, returns the run ID and (optionally) blocks until the run reports its first checkpoint.
- `warren_status(runId)` — `GET /runs/:id`, returns structured state.
- `warren_steer(runId, message)` — `POST /runs/:id/steer`, mid-run nudge.
- `warren_logs(runId, { since? })` — paginated `GET /runs/:id/events`.

These wrap the warren JSON API (`warren/src/server/handlers.ts`), no shelling out. The `burrow-client/` pattern is the template: a typed facade over `fetch()` with bearer-token auth.

### Commands

- `/warren:dispatch` — interactive flow (`ctx.ui.select` agent, `ctx.ui.input` prompt, confirm). Calls `warren_run`. Closest example: `handoff.ts`.
- `/warren:runs` — list active runs in a TUI overlay (`ctx.ui.custom`).
- `/warren:watch <runId>` — open an SSE stream that pipes events into the message stream; Esc to detach.
- `/warren:abort <runId>` — `DELETE /runs/:id`.

### Notes & open questions

- **Authentication:** today warren auth is bearer-token. The extension reads `WARREN_TOKEN` from env or `~/.pi/agent/extensions/warren.json`. Token rotation / OAuth is V2.
- **Project mapping:** when the user says "dispatch this prompt," which warren project? Default: match by git remote URL. Fall back to picker.
- **Bidirectional handoff:** the inverse — warren spawning a pi session that hands back to the user when blocked — needs the warren side to know about pi-extension wiring. Probably ship the pi side first, then teach warren about a `handoff-to-user` agent kind.
- Closest examples: `handoff.ts` for session/handoff lifecycle, `commands.ts` for command registration, `dynamic-tools.ts` for the API-backed tool surface.

---

## Cross-cutting concerns

### Distribution & repo placement

**Recommendation: ship each extension inside the existing CLI package in the same repo, with one exception for warren.** Pi packages are just npm packages with a `pi` manifest — there's no requirement they be standalone. Adding `extensions/pi/index.ts` + a six-line manifest to the existing `package.json` is enough.

#### The three options

| Option | Result | Trade-off |
|--------|--------|-----------|
| **A. Inside existing CLI package** — `@os-eco/<tool>-cli` gets a `pi` manifest pointing at `./extensions/pi/index.ts` | One package per repo, one version, one publish workflow. Cannot drift. | CLI-only users carry ~15 KB of dormant extension code; peer-dep warning unless marked optional. |
| **B. Sibling package, same repo** — `<tool>/extensions/pi/` is its own `@os-eco/pi-<tool>` package via bun workspaces | Clean separation; independent versioning. | Two version bumps to coordinate per release; the existing `publish.yml` needs a second version-diff step. |
| **C. Separate repo per extension** | Cleanest isolation. | Five new repos; cross-repo PRs; maximum drift; loses the "extension and the CLI change in one PR" workflow. |

Option C is rejected outright. Between A and B:

- **Use Option A for `pi-mulch`, `pi-seeds`, `pi-canopy`, `pi-burrow`.** All four are thin wrappers around the tool's own CLI — they shell out to `ml` / `sd` / `cn` / `burrow` on PATH and parse `--json`. The extension is essentially "official pi bindings for this CLI" and belongs in the same tarball the way ESM and CJS belong in one library tarball. Version-locking is automatic.
- **Use Option B for `pi-warren`.** Warren is a much larger package whose primary users are server operators running `warren serve`. Bundling a pi extension into `@os-eco/warren-cli` means every Docker image carries pi-runtime peer-dep noise. Ship `@os-eco/pi-warren` as a sibling workspace package instead. Versioning de-couples cleanly because the extension talks to warren over HTTP, not in-process.

#### Concrete shape — Option A (seeds example)

Additions to the existing `seeds/package.json`:

```jsonc
{
  "name": "@os-eco/seeds-cli",
  "keywords": ["issue-tracking", "git", "ai", "agents", "cli", "developer-tools", "pi-package"],
  "files": ["src", "extensions"],          // add extensions/
  "pi": {                                   // new
    "extensions": ["./extensions/pi/index.ts"]
  },
  "peerDependencies": {                     // new
    "@earendil-works/pi-coding-agent": "*",
    "typebox": "*"
  },
  "peerDependenciesMeta": {                 // suppress warnings for CLI-only users
    "@earendil-works/pi-coding-agent": { "optional": true },
    "typebox": { "optional": true }
  }
}
```

New files in the repo:

```
seeds/
  extensions/
    pi/
      index.ts        # the ExtensionAPI factory
      tools.ts        # sd_create / sd_ready / sd_show / ... tool defs
      autocomplete.ts # #sd-* completion provider
      README.md       # one-page user docs
```

Two install paths, one source:

```bash
npm install -g @os-eco/seeds-cli        # CLI on PATH only; peer deps unresolved
pi install npm:@os-eco/seeds-cli        # Pi installs peers; extension activates
```

The existing `publish.yml` workflow needs **zero changes**. The version-bump script (`scripts/version-bump.ts`) also doesn't change — one package, one version. The `pi-package` keyword opts the extension into the [pi gallery](https://pi.dev/packages).

#### Concrete shape — Option B (warren example)

Use bun workspaces:

```jsonc
// warren/package.json
{
  "name": "@os-eco/warren-cli",
  "workspaces": ["extensions/pi"]
}

// warren/extensions/pi/package.json
{
  "name": "@os-eco/pi-warren",
  "version": "0.1.0",
  "keywords": ["pi-package"],
  "pi": { "extensions": ["./src/index.ts"] },
  "peerDependencies": {
    "@earendil-works/pi-coding-agent": "*",
    "typebox": "*"
  }
}
```

The existing warren `publish.yml` gains a second job that diffs `@os-eco/pi-warren` against npm and publishes from `extensions/pi/` when its version bumps. The two packages can version independently — a warren server bump that changes nothing on the client side doesn't force a `pi-warren` republish.

#### Shared helpers

Where multiple extensions need the same logic (auth helpers, status-line rendering, JSON-parsing of `<tool> prime --json`), each maintains a local copy under `extensions/pi/lib/`. Cross-repo `pi-os-eco-shared` package considered and rejected — the helpers are small (status widget = ~30 lines, prime renderer = ~50 lines) and a shared package would force coordinated releases across all five tool repos for a single utility change.

If a real cross-cutting need emerges (say all four extensions need to talk to a warren control plane to report telemetry), promote that subset to a `@os-eco/pi-shared` package bundled via `bundledDependencies` per pi's docs.

#### Identity & install dedup

Option A means one user could end up with the same package referenced two ways: pi's `~/.pi/agent/settings.json` lists `npm:@os-eco/seeds-cli`, and the user also has `@os-eco/seeds-cli` globally installed via `npm install -g`. Pi handles this fine — pi-installed packages live in `~/.pi/agent/npm/`, the global CLI lives in npm's global prefix, and they don't collide. The user gets two copies of the package on disk; both are functional; bumping one doesn't bump the other.

For users who want a single source of truth, the project-local install path works:

```bash
pi install -l npm:@os-eco/seeds-cli   # writes to .pi/settings.json (project-local)
```

Then the team picks up the extension via project settings on first `pi` invocation.

### Setup story

For each tool's existing `setup` command (where applicable — mulch and seeds have one, canopy will), add a `pi` recipe that:

1. Writes `.pi/settings.json` adding the relevant `packages` entry.
2. Drops a default config file (`.pi/{mulch,seeds,canopy,burrow,warren}.json`).
3. Verifies the extension loads with `pi --list-extensions`.

This mirrors the existing claude / cursor / codex recipes.

### Onboarding markers in `CLAUDE.md`

Currently every tool's onboarding section (the `<!-- mulch:start -->` / `<!-- seeds:start -->` / `<!-- canopy:start -->` blocks) instructs the agent to manually run `ml prime` / `sd prime` / `cn prime`. With the extensions in place those become **automatic, not prompted.** The onboarding sections should:

- Detect the pi extension via a new `pi-onboard-v` marker.
- When pi extension is installed: emit a shorter "automatically primed" note.
- When not installed: keep the manual instructions as today.

Each tool already supports this idiom via marker-delimited sections (see `seeds/src/markers.ts`).

### Failure modes & guardrails

- **Don't fight the user.** Every hook should be cancellable via config. e.g. `mulch.autoPrime: false` skips `session_start` priming.
- **Don't double-inject.** If the user has both the extension and an `AGENTS.md` block prompting `ml prime`, the agent will prime twice. The extension should set an env var or context marker the bash-wrapper can check, or we update the onboarding markers as above.
- **Worktree semantics.** All five tools resolve their state dir to the main repo when inside a git worktree. Extensions must do the same — use `ctx.cwd` and let each tool's CLI handle the resolution.
- **Idle-time work.** `agent_end` / `session_shutdown` handlers must not block exit; fire-and-forget where possible.

---

## V1 rollout order

1. **`pi-mulch`** — highest leverage. Every project loses expertise today because the agent skips `ml record`. Auto-priming + a `record_expertise` tool with `promptGuidelines` instantly fixes this. Mostly read-only; lowest risk. Estimate: 2–3 days.
2. **`pi-seeds`** — next-highest leverage. Status line + autocomplete + structured tools make the work queue visible. Modest risk (tool wrappers + cache invalidation). Estimate: 3–5 days.
3. **`pi-canopy`** — small surface, mostly mechanical. Wins: prompts stay in sync without an emit step. **Blocked on the in-flight canopy work** (`cn config`, `cn prime --json`). Estimate: 2–3 days once unblocked.

Total V1: **~7–10 days focused** or **~2–3 weeks parallel** under light supervision.

### Deferred to v0.2

- **`pi-burrow`** — nesting validation under warren is the highest unknown. Revisit after the data-plane extensions have shaken out the common scaffolding.
- **`pi-warren`** — SSE-into-TUI is the second-largest unknown. Revisit alongside `pi-burrow`.

## Tracking

V1 build is tracked one seed per tool, in that tool's own `.seeds/`. No root-level epic — each repo owner decomposes with `sd plan` if/when they want to.

| Repo | Seed | Status |
|------|------|--------|
| `mulch/.seeds/` | [`mulch-ca5e`](../mulch/.seeds/issues.jsonl) — build pi-mulch extension | open |
| `seeds/.seeds/` | [`seeds-7164`](../seeds/.seeds/issues.jsonl) — build pi-seeds extension | open |
| `canopy/.seeds/` | [`canopy-a29b`](../canopy/.seeds/issues.jsonl) — build pi-canopy extension | open (blocked on in-flight canopy work) |

Cross-cutting concerns (test harness pattern, peer-dep policy, onboarding-marker coordination) handled inside each seed via the build checklist — first one to land sets the pattern, others follow.

### Non-blocking related work

- **Canopy issue** for `cn prime --json` — being handled by an agent working on canopy alongside `cn config` parity (§Appendix A).
- **[`seeds-e445`](../seeds/.seeds/issues.jsonl)** in `seeds/.seeds/` — richer `sd prime --json` output. Nice-to-have, not on the V1 critical path.
- **[`mulch-e3b5`](../mulch/.seeds/issues.jsonl)** in `mulch/.seeds/` — `ml record schema` subcommand. Nice-to-have; without it, `record_expertise` hard-codes the six built-in type schemas.

### Spike to do first

Spike `pi-mulch` end-to-end in a scratch `extensions/pi/` directory inside the mulch repo. Validate the `session_start` → `ml prime --json` → systemPrompt injection flow against current mulch output. This is the smallest viable proof; everything else copies the pattern.

---

## Appendix A: prime + config surface audit

Ran against the os-eco root checkout on 2026-05-15 to verify what the extensions can rely on without scraping human output. Result: **the situation is better than I assumed for mulch, fine for seeds, gappy for canopy.**

### `ml prime` — fully structured ✅

`ml prime --json` emits per-record objects, not a markdown blob:

```json
{
  "type": "expertise",
  "domains": [
    {
      "domain": "ecosystem",
      "entry_count": 12,
      "records": [
        { "type": "reference", "name": "...", "description": "...",
          "classification": "tactical", "recorded_at": "...",
          "tags": [...], "id": "mx-db7fc1" },
        ...
      ]
    }
  ]
}
```

Every lever `pi-mulch` wants is already a flag on `ml prime`:

| Flag                      | Use in extension                                              |
|---------------------------|---------------------------------------------------------------|
| `--json`                  | Structured injection — extension controls rendering           |
| `--files <paths...>`      | Scope-load on `tool_call` for `read` / `edit` / `write`       |
| `--context`               | Auto-scope to changed files (git status)                      |
| `--manifest`              | Cheap startup mode for monolith projects                      |
| `--domain` / `--exclude-domain` | Filter by domain                                        |
| `--budget <tokens>`       | Token budget enforcement                                      |
| `--dry-run` + `--budget`  | Emit `wouldPrime: [{id,type,domain,tokens}]` *before* paying the cost — extension can budget-aware pick records and only fetch the full payload for the ones it wants |

**Implication:** `pi-mulch` does not need any new mulch flags. The scope-loader described in §1 can be implemented as a literal `ml prime --files <path> --json --budget N` shell-out, no parsing tricks.

### `sd prime` — single-blob JSON ⚠️

`sd prime --json` returns:

```json
{
  "success": true,
  "command": "prime",
  "content": "# Seeds Workflow Context\n\n> **Context Recovery**: ..."
}
```

The content is the entire markdown prime as one string. There's no per-section structure (rules, commands, workflows). For `pi-seeds`, this is **good enough for the systemPrompt injection** but useless for any structured rendering.

**Workaround inside the extension:** treat `sd prime` as opaque markdown and use the *other* sd commands (which **do** have rich `--json`) for structured data:

- `sd list --json` / `sd ready --json` — drive the autocomplete cache and status widget.
- `sd show <id> --json` — expand `#sd-...` references.
- `sd stats --json` — drive the status line counts.

Filed as [`seeds-e445`](../seeds/.seeds/issues.jsonl) in `seeds/.seeds/` (low priority, non-blocking) asking `sd prime --json` to split content into `{ rules, commands, workflows }` so the extension can render them as a TUI panel instead of dumping markdown.

### `cn prime` — no JSON ❌

```
$ cn prime --json
error: unknown option '--json'
```

Despite `cn --help` advertising `--json` as a global flag, `cn prime` rejects it. This is the only confirmed gap. `pi-canopy` therefore has two options:

1. Call `cn prime` (markdown), inject as-is into the system prompt — fine for the initial drop.
2. Skip `cn prime` entirely and rely on `resources_discover` + `cn list --json` + `cn render <name>` (which do work) to expose individual prompts as slash commands. **This is the better design anyway** — it sidesteps the gap and matches what §3 already proposed.

Action item: **`cn prime --json` is being handled** — a separate agent is working on canopy and adding `cn config` (parity with `ml`/`sd`) at the same time. Non-blocking for the extension itself; track via the canopy repo.

### Config schema introspection — unexpected win 🎁

Both `ml config` and `sd config` expose `schema` / `show` / `set` / `unset` subcommands:

```
$ ml config schema      # emits MulchConfig JSON Schema
$ ml config show        # emits the effective config as JSON
$ ml config set <path> <value>   # YAML-parsed value, atomic write under file lock, schema-validated
$ ml config unset <path>          # falls back to schema default

$ sd config schema      # emits .seeds/config.yaml JSON Schema  (mirrors ml exactly)
```

The mulch `config schema` help text explicitly calls out: *"Emit MulchConfig JSON Schema for **warren and other config-UI consumers**."* Pi extensions are exactly that kind of consumer.

**Design consequence:** extension-owned knobs should *not* live in their own `.pi/mulch.json` shadow file. They should be **stored inside the tool's existing config under a namespaced key** (e.g. `pi.autoPrime: false`, `pi.scopeLoadOnEdit: true` inside `mulch.config.yaml`), written via `ml config set pi.autoPrime false`, and read via `ml config show --path pi`. That way:

- One source of truth per tool.
- File locking + atomic write + schema validation are reused.
- Multi-agent concurrency safety is inherited for free (this is the same surface warren uses).
- The `/ml:config` interactive command in `pi-mulch` can introspect `ml config schema` to drive `ctx.ui.select` for enums and `ctx.ui.input` with type validation.

Mulch's schema would need to gain a `pi` block (or we use the open `additionalProperties` if the schema permits it). Seeds the same. **Canopy has no `cn config` at all** — it's not in `cn --help`. That's a third action item: add `cn config` to canopy following the mulch/seeds pattern before `pi-canopy` ships any non-trivial config.

### Updated open questions (closed / new)

| Original open question                            | Status after audit                                     |
|---------------------------------------------------|--------------------------------------------------------|
| Do `ml/sd/cn prime` have `--json`?                | ml ✅ rich, sd ⚠️ blob, cn ❌ missing                  |
| How does the extension scope-load by file?        | Closed — `ml prime --files <paths> --json` is built-in |
| How should extension config interact with tools?  | New answer — store under `pi.*` in the tool's own config via `<tool> config set` |
| What schema do we use for `/ml:record` / `/sd:create` interactive flows? | New answer — introspect `<tool> config schema` (and the equivalent record schema if mulch adds one) |

New items to track:

- **`cn config` parity** — in flight on the canopy side alongside `cn prime --json`.
- **[`mulch-e3b5`](../mulch/.seeds/issues.jsonl)** — `ml record schema` subcommand emitting per-type field schemas (currently in `src/schemas/record.ts`) so the `record_expertise` tool's parameter validation can be data-driven instead of hard-coded.
- **[`seeds-e445`](../seeds/.seeds/issues.jsonl)** — structured `sd prime --json` sections so the TUI can render rules/commands/workflows without re-parsing markdown.
