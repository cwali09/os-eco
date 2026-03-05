---
name: convention-audit
description: Detect configuration and convention drift across ecosystem repos
---

## description

Compare tooling configuration, project structure, and conventions across all six ecosystem repos (mulch, seeds, canopy, overstory, sapling, greenhouse). Identify drift and recommend alignment actions.

**Argument:** `$ARGUMENTS` — optional: a specific area to audit (e.g., `biome`, `tsconfig`, `commands`, `infrastructure`). If empty, audit everything.

## gather

Use the Agent tool to spawn **three parallel Explore agents**:

### Agent A: Build configuration
For each sub-repo, read and extract key settings from:
- `biome.json` — formatter (indentStyle, indentWidth, lineWidth), linter rules, organize imports settings
- `tsconfig.json` — target, module, moduleResolution, strict, paths, composite, outDir
- `package.json` — scripts object (test, lint, typecheck, build), engines, type field

Build a comparison matrix for each config file.

### Agent B: Project infrastructure
For each sub-repo, check:
- `.claude/commands/` — which slash commands exist? Are the standard four present (release, prioritize, issue-reviews, pr-reviews)?
- `CLAUDE.md` — does it have the mulch/seeds/canopy/overstory onboarding sections? Is the format consistent?
- `.gitignore` — are patterns consistent across repos?
- `.gitattributes` — is the JSONL merge=union strategy set?
- `.github/workflows/` — are CI workflows present and consistent?
- `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE`, `CODEOWNERS` — present or missing?

### Agent C: Code conventions
For each sub-repo, sample 3-5 source files and check:
- Import style: do all files use `.ts` extensions?
- Error handling: does the repo have an errors.ts with a base error class?
- Export patterns: barrel exports (index.ts) vs direct imports?
- Test patterns: colocated tests (foo.test.ts next to foo.ts) or separate test directory?
- CLI entry: Commander-based? Same option patterns (--json, --quiet, --verbose, --timing)?

## analyze

After all agents return, produce a drift report:

### Configuration Drift Matrix

For each config area, show which repos align and which diverge:

| Setting | mulch | seeds | canopy | overstory | sapling | greenhouse | Consensus |
|---------|-------|-------|--------|-----------|---------|------------|-----------|

Mark cells with `✓` (matches consensus), `✗` (diverges), or `—` (not applicable).

### Infrastructure Completeness

| Item | mulch | seeds | canopy | overstory | sapling | greenhouse |
|------|-------|-------|--------|-----------|---------|------------|
| Standard commands (4) | | | | | | |
| CLAUDE.md onboarding | | | | | | |
| CI workflow | | | | | | |
| .gitattributes JSONL | | | | | | |
| CONTRIBUTING.md | | | | | | |
| SECURITY.md | | | | | | |

### Convention Alignment

For each convention area (imports, errors, exports, tests, CLI), state the majority pattern and list repos that diverge.

### Recommendations

Prioritized list of alignment actions:
1. **Critical** — divergences that cause real problems (incompatible tsconfig, missing CI)
2. **Important** — inconsistencies that confuse agents or developers (different lint rules, missing commands)
3. **Nice-to-have** — cosmetic differences (different .gitignore entries, missing docs files)

For each recommendation, specify which repo needs to change and what the target state should be. Do NOT make the changes — present them as recommendations.
