---
name: dependency-audit
description: Audit shared dependencies for version mismatches and outdated packages across repos
---

## description

Compare npm dependencies across all six ecosystem repos. Identify version mismatches, outdated packages, and opportunities for alignment.

**Argument:** `$ARGUMENTS` — optional: a package name to focus on (e.g., `chalk`, `commander`). If empty, audit all shared dependencies.

## gather

Use the Agent tool to spawn **two parallel agents**:

### Agent A: Dependency extraction
For each sub-repo (mulch, seeds, canopy, overstory, sapling, greenhouse):
- Read `package.json` and extract `dependencies` and `devDependencies`
- Read `bun.lock` (or `bun.lockb`) if present for pinned versions
- Capture: package name, declared version range, resolved version (from lock), dep type (prod/dev)

Build a unified dependency list across all repos.

### Agent B: Ecosystem dependency check
- Read the root `package.json` if one exists
- Check if any sub-repos import from each other (e.g., does greenhouse depend on overstory?)
- Check for `@os-eco/*` packages in any dependencies
- Identify any workspace or monorepo configuration

## analyze

After both agents return, produce:

### Shared Dependency Matrix

| Package | mulch | seeds | canopy | overstory | sapling | greenhouse | Aligned? |
|---------|-------|-------|--------|-----------|---------|------------|----------|

Show the version used in each repo. Mark `Aligned?` as `✓` if all repos use the same version, `✗` if versions differ.

### Version Mismatches

For each package with version differences:
- List exact versions per repo
- Recommend target version (usually latest)
- Note any repos that might break from upgrading (check for breaking changes in changelogs if major version differs)

### Outdated Packages

For key dependencies, check if newer versions are available:
```bash
bun outdated  # Run in each sub-repo
```

List packages more than one minor version behind.

### Unnecessary Dependencies

Flag packages that:
- Are declared but not imported in source code
- Are duplicated between dependencies and devDependencies
- Could be replaced by a built-in (e.g., using `node:path` instead of `path` package)

### Cross-repo Dependencies

If any sub-repos depend on each other:
- Map the dependency graph
- Check version compatibility
- Flag circular dependencies

### Recommendations

Ordered by impact:
1. **Version mismatches** — specific `bun add` commands to align versions
2. **Outdated packages** — upgrade commands with risk assessment
3. **Unnecessary deps** — removal commands
4. **Missing deps** — packages one repo uses that others could benefit from

Do NOT run the commands. Present them as recommendations.
