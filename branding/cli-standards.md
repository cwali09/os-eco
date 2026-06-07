# CLI Standards

Technical conventions that all tools must follow. The original audited tools were mulch, seeds, canopy, and sapling; overstory and greenhouse have since been archived. Burrow (v0.3.0) and warren (v0.3.0) joined post-V1, and trellis (v0.0.1, pre-release) joined 2026-06-06 — their compliance with this spec is not yet audited and is tracked as pending in `checklists.md`.

---

## Arg Parsing & Color: Commander + Chalk

All tools use `commander` (v14+) for arg parsing and `chalk` (v5+) for color output.

| Tool | commander | chalk | Status |
|------|-----------|-------|--------|
| Mulch | yes | yes | done (v0.6.0) |
| Seeds | yes | yes | done (v0.2.1) |
| Canopy | yes | yes | done (v0.2.2, register pattern) |
| Sapling | yes | yes | done (v0.3.1) |

All audited tools are fully migrated to Commander + Chalk. Burrow, warren, and trellis audit pending (trellis is commander-based per its SPEC; unverified).

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

| Flag | Mulch | Seeds | Canopy | Sapling |
|------|-------|-------|--------|---------|
| `-v, --version` | done | done | done | done |
| per-command `--help` | done | done | done | done |
| `--quiet, -q` | done | done | done | done |
| `--verbose` | done | done | done | done |
| `--json` | done | done | done | done |
| `--timing` | done | done | done | done |

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
| Sapling | `export const VERSION` in `src/index.ts` | done |

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
| Sapling | yes | done (v0.3.1, json.ts with jsonOutput/jsonError helpers) |

All audited tools use the standard `{ success, command }` envelope. Burrow and warren audit pending.

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
| Sapling | done (`process.exitCode = 1`, v0.3.1) |

---

## Doctor Command

Every tool has a `doctor` command with `--fix` and `--json`.

| Tool | Exists | --fix | --json | Status |
|------|--------|-------|--------|--------|
| Mulch | yes (8 checks) | yes | yes | done |
| Seeds | yes (10 checks) | yes | yes | done |
| Canopy | yes (6 checks) | yes | yes | done (v0.2.2) |
| Sapling | yes (3 checks) | yes | yes | done (v0.3.1) |

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
| Sapling | `sp upgrade` | done (v0.3.1, with `--check` and `--json`) |

### Behavior
- Check npm registry for latest `@os-eco/<tool>-cli`
- Compare with local VERSION
- `--check`: print current vs latest, exit 0 if current, exit 1 if outdated
- Default: install latest via `bun install -g @os-eco/<tool>-cli@latest`
- `--json`: `{ "current": "0.11.0", "latest": "0.12.0", "upToDate": false }`

---

## Features to Propagate

Status counts below are against the audited tools (mulch, seeds, canopy, sapling). Burrow (v0.3.0) and warren (v0.3.0) joined post-V1 and are not yet audited — all rows are pending for those two.

| Feature | Status (audited 4) | Notes |
|---------|--------------------|-------|
| `--quiet, -q` | all 4 | — |
| `--verbose` | all 4 | — |
| `--dry-run` (sync) | 3/4 | Sapling (N/A — no sync command) |
| Per-command `--help` | all 4 | — |
| Shell completions | all 4 | — |
| `--timing` | all 4 | — |
| Typo suggestions | all 4 | — |
| `upgrade` command | all 4 | — |
| `doctor` command | all 4 | — |
| `--version --json` | all 4 | — |
| `process.exitCode = 1` | all 4 | — |
| `{ success, command }` JSON envelope | all 4 | — |
