---
name: health-check
description: "Cross-repo health dashboard: tests, lint, types, and code quality across all ecosystem repos"
---

## description

Scan all eight active ecosystem sub-repos (warren, burrow, plot, mulch, seeds, canopy, sapling, trellis) for build health, test coverage gaps, and code quality signals. Report a single consolidated dashboard. (Greenhouse and overstory were also tools here — both archived 2026-05, superseded by warren; do not include in scans.)

**Argument:** `$ARGUMENTS` — optional: a repo name to focus on (e.g., `warren`, `sapling`). If empty, scan the full ecosystem.

## scan

Use the Agent tool to spawn **eight parallel Explore agents**, one per active sub-repo (warren, burrow, plot, mulch, seeds, canopy, sapling, trellis). Each agent runs from within that sub-repo directory and reports:

### Per-repo checks

#### Build health
- Run `bun test` — capture total tests, pass count, fail count, skip count
- Run `bun run lint` — capture error count and warning count
- Run `bun run typecheck` — capture error count

#### Code quality signals
- Count `TODO` comments: `grep -r "TODO" src/ --include="*.ts" | wc -l`
- Count `FIXME` comments: `grep -r "FIXME" src/ --include="*.ts" | wc -l`
- Count `HACK` comments: `grep -r "HACK" src/ --include="*.ts" | wc -l`

#### Test coverage gaps
- List all source files: `find src -name "*.ts" -not -name "*.test.ts" -not -name "*.d.ts"`
- List all test files: `find src -name "*.test.ts"`
- Report source files that have no corresponding `.test.ts` file

#### Infrastructure health
- Check that `.mulch/`, `.seeds/`, `.canopy/` directories exist and are initialized
- Check that `CLAUDE.md` exists and contains mulch/seeds/canopy onboarding sections
- Check that `.claude/commands/` has the standard slash commands (release, prioritize, issue-reviews, pr-reviews)

If `$ARGUMENTS` specifies a single repo, spawn only one agent for that repo.

## report

After all agents return, consolidate into a single dashboard:

### Health Dashboard

| Repo | Tests | Lint | Types | TODOs | FIXMEs | Coverage Gaps | Infra |
|------|-------|------|-------|-------|--------|---------------|-------|

Where:
- **Tests**: `✓ N pass` or `✗ N fail / M total`
- **Lint**: `✓ clean` or `✗ N errors`
- **Types**: `✓ clean` or `✗ N errors`
- **TODOs/FIXMEs**: count (flag if > 10)
- **Coverage Gaps**: count of untested source files
- **Infra**: `✓` if all infrastructure checks pass, list missing items otherwise

### Regressions
Flag any repo where:
- Tests were previously passing but now fail
- Lint/type errors have increased since last check
- New source files were added without tests

### Action Items
- List specific issues that should be filed (as seeds) based on health findings
- Prioritize: failing tests > type errors > lint errors > coverage gaps > TODOs

Do NOT file the issues yourself. Present them as recommendations for the human operator or the `/prioritize` command to act on.
