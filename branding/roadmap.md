# Roadmap

Future work beyond the immediate CLI harmonization and branding.

---

## Greenhouse CLI Standards Gaps — Archived 2026-05

> **No longer tracked.** Greenhouse was archived 2026-05 when warren absorbed its autonomous-loop role. The original list (Help Style A, Icon Set D, `-q` flag, `process.exitCode`, typo suggestions, completions, upgrade, doctor `--fix`) is preserved in the archived greenhouse repo for historical reference but will not be implemented.

---

## @os-eco/cli-common Shared Package

A dev-time shared package (not a runtime dep) to prevent drift across tools.

### What it exports
- Palette constants (brand colors, semantic colors)
- `outputJson()` / `outputJsonError()` — JSON envelope helpers
- `printSuccess()` / `printWarn()` / `printError()` — message format helpers
- Commander presets (global flags: `--json`, `--quiet`, `--verbose`)
- Version-check logic (query npm registry, compare semver)
- Status icon constants (`ICONS.open`, `ICONS.active`, `ICONS.closed`, `ICONS.blocked`)
- Help screen formatter (consistent layout from command metadata)
- Typo suggestion helper (edit-distance for "did you mean?")

### How tools consume it
```json
// package.json
{ "devDependencies": { "@os-eco/cli-common": "workspace:*" } }
```

Each tool copies/bundles what it needs at build time, preserving the zero-runtime-deps claim.
Alternatively, just import directly since Bun resolves workspace deps at runtime anyway.

### When to build this
The original six tools all use commander + chalk; burrow and warren joined post-V1 and their stacks haven't been audited against this spec yet. Patterns across the core six have largely converged:
- Common output helpers: `printSuccess()`, `printError()`, `printWarning()`
- Shared palette: brand color + accent (amber) + muted (stone gray)
- Status icon set D: `- > x !`
- Register pattern for commands

**Ready to extract.** Start with palette constants and message format helpers.

---

## CI Parity

All eight repos should use an identical GitHub Actions workflow structure. Seeds already has CI + auto-publish to npm.

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install
      - run: bun run typecheck
      - run: bun run lint
      - run: bun test
```

### Additions to consider
- Version-sync check: fail CI if `package.json` version != `src/index.ts` VERSION
- Branding lint: check that palette constants match the spec (via a test)
- Publish workflow: auto-publish to npm on version tag

---

## Consistent Test Patterns

All tools should follow:
- Test files: `src/commands/<name>.test.ts` (colocated with source)
- Test runner: `bun test`
- Naming: `describe("<command>", () => { it("should ...", ...) })`
- Coverage: track but don't gate on a threshold yet
- Fixtures: `tests/fixtures/` for sample JSONL, configs, etc.

---

## --timing Flag — Done

Show execution time on any command. Great for demonstrating Bun's fast startup.

```
$ sd list --timing
  ... normal output ...
  Done in 12ms
```

- Only prints when `--timing` is passed
- Output goes to stderr (doesn't interfere with `--json` piping)
- Format: `Done in <N>ms` in muted text

**Status:** Complete across the original six tools. Burrow + warren audit pending.

---

## Cross-Tool JSON Piping

Document and test that tools compose via `--json` stdout:

```bash
# Find unblocked work and sling it to an agent
sd ready --json | ov sling --stdin

# Check all tool health in one shot
ov doctor --json | jq '.checks[] | select(.status == "fail")'
```

This requires:
- Consistent JSON envelope (already in cli-standards.md)
- `--stdin` flag on commands that accept piped input
- Integration tests that verify cross-tool piping

---

## Shell Completions — Done (5/8)

Five tools (mulch, seeds, canopy, overstory, sapling) now ship completions for bash, zsh, and fish via a `completions <shell>` subcommand. Burrow + warren joined post-V1 and their support is unaudited. (Greenhouse was the sixth tool here; archived 2026-05.)

```bash
# Generate and install
sd completions zsh > ~/.zfunc/_sd
cn completions bash > /etc/bash_completion.d/cn
mulch completions fish > ~/.config/fish/completions/mulch.fish
ov completions zsh > ~/.zfunc/_ov
sp completions fish > ~/.config/fish/completions/sp.fish
# grhs completions zsh — not yet implemented
```

**Status:** Complete for mulch, seeds, canopy, overstory, sapling. Burrow + warren audit pending. (Greenhouse archived 2026-05.)

---

## Man Pages

Generated from help text. Unusual for TS/Bun tools — polished touch.

### Approach
- Generate from commander's command metadata at build time
- Output to `man/` directory in each repo
- Install via npm `man` field in package.json:
  ```json
  { "man": ["./man/sd.1"] }
  ```
- Format: roff (standard man page format)
- Can use a simple generator script, no heavy deps needed

---

## ov init Bootstraps Everything

`ov init` becomes the one-command project setup:

```bash
$ ov init
✓ Initialized .overstory/
✓ Initialized .mulch/
✓ Initialized .seeds/
✓ Initialized .canopy/
✓ Set up .gitattributes (merge=union for JSONL)
✓ Added tool sections to CLAUDE.md
```

Flags:
- `--mulch-only`, `--seeds-only`, etc. for partial init
- `--force` to overwrite existing configs

---

## ov ecosystem Command — Done

Dashboard showing the full ecosystem status (implemented in v0.7.4):

```
os-eco ecosystem status

Tool          Version    Status     Health
─────────────────────────────────────────────
mulch     ml    0.10.0   - latest   ✓ 8/8 checks
seeds     sd    0.4.4    - latest   ✓ 10/10 checks
canopy    cn    0.2.4    - latest   ✓ 6/6 checks
sapling   sp    0.3.2    - latest   ✓ 3/3 checks
burrow    bw    0.3.0    - latest   - audit pending
overstory ov    0.11.0   - latest   ✓ 11/11 checks
warren    wr    0.3.0    - latest   - audit pending
greenhouse grhs 0.1.2    - latest   ✓ 6/6 checks

Last sync: 2 minutes ago
Active agents: 3  |  Open issues: 12  |  Prompts: 7
```

Gathers data by running each tool's `--version` and `doctor --json` commands.

---

## Website

A single-page GitHub Pages site for the ecosystem:

- Stacked-layer logo (rendered with brand colors via CSS/SVG)
- One-paragraph description of the ecosystem
- Card per tool: name, tagline, install command, link to repo
- Architecture diagram showing relationships
- "Get Started" code snippet
- Links to npm packages

Keep it minimal — a single `index.html` with inline CSS is fine.
The site exists to make the GitHub profile / portfolio presentable, not as full docs.

---

## Spinner Style

For any command that takes >500ms, use a consistent spinner:

```
⠋ Running health checks...
⠙ Running health checks...
⠹ Running health checks...
```

- Braille dot spinner (standard, works in all terminals)
- Text in dim
- Clears line on completion, replaced by success/error message
- Use `ora` or a minimal hand-rolled implementation
