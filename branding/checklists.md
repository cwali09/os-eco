# Implementation Checklists

Per-tool TODO lists. Check items off as work is completed.
Last full audit: 2026-03-05 against the versions noted in each tool's heading. Burrow and warren joined post-V1 (added 2026-05-13) and their audit is pending. Version headings below reflect current shipped versions; any divergence from the audit baseline is a re-audit candidate.

---

## Mulch (v0.10.0)

### Branding — Complete
- [x] Apply forest palette (brand: `rgb(139, 90, 43)`, accent, muted) — done (v0.6.0, palette.ts)
- [x] Adopt help screen style A (see visual-spec.md) — done (v0.6.0, custom configureHelp in cli.ts)
- [x] Adopt status icon set D (`✓ ! ✗ - > x`) — done (v0.6.0, icons object in palette.ts)
- [x] Adopt message format standards (`✓ ✗ !`) — done (v0.6.0, printSuccess/Error/Warning in palette.ts)

### CLI Standards
- [x] Migrate arg parsing to commander — done (v0.6.0)
- [x] Replace raw ANSI with chalk — done (v0.6.0)
- [x] Standardize version flag to `-v, --version` — done (v0.6.0)
- [x] Add `--version --json` (rich metadata output) — done (v0.6.0, outputs name/version/runtime/platform)
- [x] Move VERSION to `export const VERSION` in entry point — done (v0.6.0, cli.ts)
- [x] Add `--quiet, -q` global flag — done (v0.6.0, setQuiet in palette.ts)
- [x] Add `--verbose` global flag — done (registered globally in cli.ts, used by prime/query/status)
- [x] Add `--compact` to `mulch prime` — done (v0.6.0, default output mode)
- [x] Add typo suggestions for unknown commands — done (Levenshtein in cli.ts)
- [x] Add shell completions (`completions <shell>`) — done (bash/zsh/fish, completions.ts)
- [x] Add `--timing` flag — done (global flag, outputs to stderr)
- [x] JSON output helpers (`--json` flag, outputJson/outputJsonError) — done (json-output.ts)

### Commands
- [x] Add `mulch upgrade` command — done (v0.6.0, with `--check` and `--json`)
- [x] Add `mulch doctor` command (8 checks, `--fix`, `--json`) — done

---

## Seeds (v0.4.4) — Fully Complete

### Branding — Complete
- [x] Apply forest palette (brand: `rgb(124, 179, 66)`, accent, muted) — done (v0.2.2)
- [x] Adopt help screen style A (see visual-spec.md) — done (v0.2.2, custom configureHelp in index.ts)
- [x] Adopt status icon set D (`- > x !`) — done (v0.2.2)
- [x] Adopt message format standards (`✓ ✗ !`) — done (v0.2.2)

### CLI Standards — Complete
- [x] Migrate arg parsing to commander — done (v0.2.1)
- [x] Replace raw ANSI with chalk — done (v0.2.1)
- [x] Add per-command `--help` (free from commander) — done
- [x] Standardize version flag to `-v, --version` — done
- [x] Add `--version --json` (rich metadata output) — done (v0.2.2, outputs name/version/runtime/platform)
- [x] Switch to `process.exitCode = 1` (no hard exit) — done (v0.2.1)
- [x] Add `--quiet, -q` global flag — done (v0.2.2)
- [x] Add `--verbose` global flag — done (v0.2.2)
- [x] Add `--dry-run` to `sd sync` — done (v0.2.2)
- [x] Add typo suggestions for unknown commands — done (Levenshtein, index.ts)
- [x] Add shell completions (`completions <shell>`) — done (bash/zsh/fish, completions.ts)
- [x] Add `--timing` flag — done (global flag, outputs to stderr)

### Commands — Complete
- [x] Add `sd upgrade` command (self-update from npm) — done (v0.2.2)
- [x] Add `sd doctor` command (10 checks, `--fix`, `--json`) — done

---

## Canopy (v0.2.4) — Fully Complete

### Branding — Complete
- [x] Apply forest palette (brand: `rgb(56, 142, 60)`, accent, muted) — done (v0.1.5)
- [x] Adopt help screen style A (see visual-spec.md) — done (v0.1.5, custom branded header)
- [x] Adopt status icon set D (`- > x !`) — done (v0.1.5, icons object in output.ts)
- [x] Adopt message format standards (`✓ ✗ !`) — done (v0.1.5, fmt helpers in output.ts)

### CLI Standards — Complete
- [x] Remove dual-track arg parsing (commander-only) — done (register pattern, all 22 commands)
- [x] Add `--version --json` (rich metadata output) — done (v0.1.6, outputs name/version/runtime/platform)
- [x] Add `--quiet, -q` global flag — done (v0.1.6, setQuiet in output.ts)
- [x] Add `--verbose` global flag — done (v0.1.6, used by doctor command)
- [x] Add typo suggestions for unknown commands — done (v0.1.9, Levenshtein in index.ts)
- [x] Add shell completions (`completions <shell>`) — done (v0.1.9, bash/zsh/fish, completions.ts)
- [x] Add `--timing` flag — done (v0.1.9, global flag, outputs to stderr)

### Commands — Complete
- [x] Implement `cn doctor` (6 checks, `--fix`, `--json`) — done (v0.1.6)
- [x] Add `cn upgrade` command (self-update from npm) — done (v0.1.6, with `--check` and `--json`)

---

## Sapling (v0.3.2) — Fully Complete

### Branding
- [x] Apply forest palette (brand: `rgb(76, 175, 80)`, accent, muted) — done (v0.1.1, color.ts with exact RGB)
- [x] Adopt help screen style A (see visual-spec.md) — done (v0.3.0, brand.bold in index.ts)
- [x] Adopt status icon set D (`- > x !`) — done (v0.1.1, icons object in color.ts, verified v0.3.1)
- [x] Adopt message format standards (`✓ ✗ !`) — done (v0.1.1, printSuccess/Error/Warning in color.ts, verified v0.3.1)

### CLI Standards
- [x] Migrate arg parsing to commander — done (v0.1.0, Commander v14.0.3)
- [x] Replace raw ANSI with chalk — done (v0.1.0, chalk v5.6.2, centralized in logging/color.ts)
- [x] Standardize version flag to `-v, --version` — done (v0.1.0, via Commander .version())
- [x] Add `--version --json` (rich metadata output) — done (v0.1.1, outputs name/version/runtime/platform, verified v0.3.1)
- [x] Move VERSION to `export const VERSION` in entry point — done (v0.1.0, index.ts, verified v0.3.1)
- [x] Add `--quiet, -q` global flag — done (v0.1.0, suppresses output + disables color)
- [x] Add `--verbose` global flag — done (v0.1.0, logs context manager decisions)
- [x] Add `--json` flag — done (v0.1.0, NDJSON event output)
- [x] Add `--timing` flag — done (v0.1.1, global flag, outputs to stderr)
- [x] Switch JSON envelope to `{ success, command }` format — done (v0.1.1, json.ts with jsonOutput/jsonError helpers, verified v0.3.1)
- [x] Switch to `process.exitCode = 1` (no hard exit) — done (v0.1.1, used throughout, verified v0.3.1)
- [x] Add typo suggestions for unknown commands — done (v0.1.1, Levenshtein in typo.ts, verified v0.3.1)
- [x] Add shell completions (`completions <shell>`) — done (v0.1.1, bash/zsh/fish, completions.ts, verified v0.3.1)

### Commands
- [x] Add `sp upgrade` command (with `--check` and `--json`) — done (v0.1.1, verified v0.3.1)
- [x] Add `sp doctor` command (with `--fix` and `--json`) — done (v0.1.1, 3 checks, verified v0.3.1)

### Documentation
- [x] README.md with install, CLI reference, architecture — done
- [x] CHANGELOG.md in Keep a Changelog format — done
- [x] Add badges to README (npm, CI, license) — done (v0.1.1, verified v0.3.1)

---

## Burrow (v0.3.0) — Audit Pending

Brand color: `rgb(121, 85, 72)` (warm clay). Joined the ecosystem 2026-05-13. No items below have been verified against burrow's actual source — schedule a full audit against `visual-spec.md` + `cli-standards.md`.

### Branding — Pending
- [ ] Apply forest palette (brand: `rgb(121, 85, 72)`, accent, muted)
- [ ] Adopt help screen style A (see visual-spec.md)
- [ ] Adopt status icon set D (`- > x !`)
- [ ] Adopt message format standards (`✓ ✗ !`)

### CLI Standards — Pending
- [ ] Commander + chalk arg parsing
- [ ] `-v, --version` flag with `--version --json` rich metadata
- [ ] Global flags: `--json`, `--quiet, -q`, `--verbose`, `--timing`
- [ ] `process.exitCode = 1` (no hard exit)
- [ ] `{ success, command }` JSON envelope
- [ ] Typo suggestions for unknown commands
- [ ] Shell completions (`completions <shell>`)

### Commands — Pending
- [ ] `burrow upgrade` (with `--check` and `--json`)
- [ ] `burrow doctor` (with `--fix` and `--json`)

### Documentation
- [x] README.md with install, CLI reference, badges — done (verified 2026-05-13)
- [x] CHANGELOG.md — done

---

## Warren (v0.3.0) — Audit Pending

Brand color: `rgb(82, 105, 110)` (slate). Joined the ecosystem 2026-05-13. No items below have been verified against warren's actual source — schedule a full audit against `visual-spec.md` + `cli-standards.md`.

### Branding — Pending
- [ ] Apply forest palette (brand: `rgb(82, 105, 110)`, accent, muted)
- [ ] Adopt help screen style A (see visual-spec.md)
- [ ] Adopt status icon set D (`- > x !`)
- [ ] Adopt message format standards (`✓ ✗ !`)

### CLI Standards — Pending
- [ ] Commander + chalk arg parsing
- [ ] `-v, --version` flag with `--version --json` rich metadata
- [ ] Global flags: `--json`, `--quiet, -q`, `--verbose`, `--timing`
- [ ] `process.exitCode = 1` (no hard exit)
- [ ] `{ success, command }` JSON envelope
- [ ] Typo suggestions for unknown commands
- [ ] Shell completions (`completions <shell>`)

### Commands — Pending
- [ ] `warren upgrade` (with `--check` and `--json`)
- [ ] `warren doctor` (with `--fix` and `--json`)

### Documentation
- [x] README.md with install, CLI reference, badges — done (verified 2026-05-13)
- [x] CHANGELOG.md — done

---

## Cross-Cutting

### Documentation
- [x] Unify all sub-repo READMEs to template (see documentation.md) — done for the audited tools (burrow + warren audit pending)
- [x] Add consistent badge set to all repos (npm, CI, license) — done for all active repos
- [x] Adopt Keep a Changelog format in all repos — done for the audited tools (burrow + warren have CHANGELOG.md; format audit pending)
- [x] Ensure `npx @os-eco/<tool>-cli` works for all tools — done for the audited tools (burrow + warren audit pending)
- [x] Update root os-eco README as ecosystem landing page — done (layered ecosystem landing page with ASCII stacked-layers art, workflow example, design principles)
- [x] Align `.claude/commands/` across all sub-repos — done for the audited tools; burrow + warren pending

### Infrastructure
- [ ] Standardize CI workflows across all repos
- [ ] Add version-sync CI check (package.json vs VERSION constant) — Seeds has this, Canopy doctor checks it
- [ ] Create `@os-eco/cli-common` shared package — the audited tools all on commander+chalk and ready to extract; consume from burrow + warren once they're audited onto the same stack

### Future
- [ ] Cross-tool JSON piping tests
- [ ] Man page generation
- [ ] One-command bootstrap that initializes all tools
- [ ] GitHub Pages website
- [ ] Consistent spinner style for long-running commands
