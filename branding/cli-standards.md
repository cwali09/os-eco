# CLI Standards

Technical conventions that all tools must follow. The original six tools (mulch, seeds, canopy, sapling, overstory, greenhouse) were fully audited against this spec. Burrow (v0.3.0) and warren (v0.3.0) joined post-V1 — their compliance with this spec is not yet audited and is tracked as pending in `checklists.md`.

> **Greenhouse archived 2026-05** — rows below are preserved as a historical audit snapshot (v0.1.2 state at archival). "5/6" or "all 6" counts refer to the original six and no longer reflect the active toolset (5 active + 2 pending audit). Greenhouse gaps will not be closed.

---

## Arg Parsing & Color: Commander + Chalk

All tools use `commander` (v14+) for arg parsing and `chalk` (v5+) for color output.

| Tool | commander | chalk | Status |
|------|-----------|-------|--------|
| Mulch | yes | yes | done (v0.6.0) |
| Seeds | yes | yes | done (v0.2.1) |
| Canopy | yes | yes | done (v0.2.2, register pattern) |
| Overstory | yes | yes | done (v0.8.5) |
| Sapling | yes | yes | done (v0.3.1) |
| Greenhouse | yes | yes | done (v0.1.0) |

All six original tools are fully migrated to Commander + Chalk. Burrow and warren audit pending.

---

## Global Flags

Every tool must support these flags:

| Flag | Description |
|------|-------------|
| `-h, --help` | Show help (global and per-command) |
| `-v, --version` | Print bare semver string (e.g. `0.6.0`, no prefix) |
| `--json` | Machine-readable JSON output |
| `--quiet, -q` | Suppress non-error output |
| `--verbose` | Extra diagnostic output |
| `--timing` | Print execution time to stderr |

### Current status

| Flag | Mulch | Seeds | Canopy | Overstory | Sapling | Greenhouse |
|------|-------|-------|--------|-----------|---------|------------|
| `-v, --version` | done | done | done | done | done | done |
| per-command `--help` | done | done | done | done | done | done |
| `--quiet, -q` | done | done | done | done | done | `--quiet` only (missing `-q`) |
| `--verbose` | done | done | done | done | done | done |
| `--json` | done | done | done | done | done | done |
| `--timing` | done | done | done | done | done | done |

---

## Version Output

```
$ sd --version
0.4.4
```

- Bare semver, no tool name prefix
- `--version --json` returns rich metadata:

```json
{
  "name": "@os-eco/seeds-cli",
  "version": "0.4.4",
  "runtime": "bun",
  "platform": "darwin-arm64"
}
```

### VERSION constant

All tools: `export const VERSION = "<semver>"` in the entry point, kept in sync with `package.json` via `version:bump` script.

| Tool | Location | Status |
|------|----------|--------|
| Mulch | `export const VERSION` in `src/cli.ts` | done |
| Seeds | `export const VERSION` in `src/index.ts` | done |
| Canopy | `export const VERSION` in `src/index.ts` | done |
| Overstory | `export const VERSION` in `src/index.ts` | done |
| Sapling | `export const VERSION` in `src/index.ts` | done |
| Greenhouse | `export const VERSION` in `src/cli.ts` | done |

---

## JSON Response Envelope

All `--json` output uses this shape:

```json
{ "success": true, "command": "<name>", ...data }
{ "success": false, "command": "<name>", "error": "<message>" }
```

| Tool | Uses envelope | Status |
|------|-------------|--------|
| Mulch | yes | done |
| Seeds | yes | done |
| Canopy | yes | done |
| Overstory | yes | done (v0.8.5, json.ts with jsonOutput/jsonError helpers) |
| Sapling | yes | done (v0.3.1, json.ts with jsonOutput/jsonError helpers) |
| Greenhouse | yes | done |

All six original tools use the standard `{ success, command }` envelope. Burrow and warren audit pending.

### JSON error channel

- **With `--json`:** errors go to **stdout** inside the `{ success: false }` envelope
- **Without `--json`:** errors go to **stderr** as colored text

Rationale: machine consumers parse stdout; stderr is for human-only diagnostics.

---

## Error Handling

### Exit mechanism

Use `process.exitCode = 1` everywhere. No hard `process.exit()`.
Rationale: testable, allows cleanup/finally blocks to run.

| Tool | Status |
|------|--------|
| Mulch | done (`process.exitCode = 1`) |
| Seeds | done (`process.exitCode = 1`, migrated v0.2.1) |
| Canopy | done (`ExitError` -> `process.exitCode`) |
| Overstory | done (`process.exitCode = 1`; `process.exit(0)` only for SIGINT cleanup and --version --json early exit, v0.8.5) |
| Sapling | done (`process.exitCode = 1`, v0.3.1) |
| Greenhouse | **mixed** — some commands use `process.exit()` (poll, start, stop, ingest), others use `process.exitCode` |

### Error codes

Overstory has structured error codes (`CONFIG_ERROR`, `AGENT_ERROR`, etc.).
The other tools don't need this — Overstory is more complex. No need to force on simpler tools.

---

## Doctor Command

Every tool has a `doctor` command with `--fix` and `--json`.

| Tool | Exists | --fix | --json | Status |
|------|--------|-------|--------|--------|
| Mulch | yes (8 checks) | yes | yes | done |
| Seeds | yes (10 checks) | yes | yes | done |
| Canopy | yes (6 checks) | yes | yes | done (v0.2.2) |
| Overstory | yes (11 categories) | yes | yes | done (v0.8.5) |
| Sapling | yes (3 checks) | yes | yes | done (v0.3.1) |
| Greenhouse | yes (6 checks) | **no** | yes | missing `--fix` flag |

### Overstory ecosystem check (`ov doctor`)
Verify sibling tools are:
1. Installed and on `$PATH`
2. Reporting a version (`mulch --version`, `sd --version`, `cn --version`)
3. At a compatible version

`ov doctor --fix` should:
1. Run `bun install -g @os-eco/mulch-cli @os-eco/seeds-cli @os-eco/canopy-cli`
2. Re-check versions after update
3. Report what was updated

---

## Upgrade Command (self-update)

Use `upgrade` (not `update`) to avoid collision with Seeds/Canopy record-update commands.

```
sd upgrade              # install latest from npm
sd upgrade --check      # check for updates without installing
```

| Tool | Command | Status |
|------|---------|--------|
| Mulch | `mulch upgrade` | done (with `--check` and `--json`) |
| Seeds | `sd upgrade` | done (v0.2.2, with `--check` and `--json`) |
| Canopy | `cn upgrade` | done (v0.2.2, with `--check` and `--json`) |
| Overstory | `ov upgrade` + `ov upgrade --all` | done (v0.8.5, with `--check`, `--all`, `--json`) |
| Sapling | `sp upgrade` | done (v0.3.1, with `--check` and `--json`) |
| Greenhouse | — | **not implemented** |

### Behavior
- Check npm registry for latest `@os-eco/<tool>-cli`
- Compare with local VERSION
- `--check`: print current vs latest, exit 0 if current, exit 1 if outdated
- Default: install latest via `bun install -g @os-eco/<tool>-cli@latest`
- `--json`: `{ "current": "0.11.0", "latest": "0.12.0", "upToDate": false }`
- `ov upgrade --all`: update the core six tools at once (burrow + warren not yet integrated)

---

## Features to Propagate

Status counts below are against the original six (mulch, seeds, canopy, sapling, overstory, greenhouse). Burrow (v0.3.0) and warren (v0.3.0) joined post-V1 and are not yet audited — all rows are pending for those two.

| Feature | Status (core 6) | Notes |
|---------|-----------------|-------|
| `--quiet, -q` | 5/6 | Greenhouse missing `-q` short form |
| `--verbose` | all 6 | — |
| `--dry-run` (sync) | 4/6 | Sapling (N/A — no sync command), Greenhouse (N/A) |
| Per-command `--help` | all 6 | — |
| Shell completions | 5/6 | Greenhouse missing |
| `--timing` | all 6 | — |
| Typo suggestions | 5/6 | Greenhouse missing |
| `upgrade` command | 5/6 | Greenhouse missing |
| `doctor` command | all 6 | Greenhouse missing `--fix` |
| `--version --json` | all 6 | — |
| `process.exitCode = 1` | 5/6 | Greenhouse mixed |
| `{ success, command }` JSON envelope | all 6 | — |
