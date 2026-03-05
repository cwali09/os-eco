---
name: release-plan
description: Plan coordinated releases across ecosystem repos based on unreleased changes
---

## description

Analyze unreleased changes across all ecosystem repos, determine which repos need releases, recommend version bumps, and produce a sequenced release plan.

**Argument:** `$ARGUMENTS` — optional: a repo name to plan a single release for. If empty, plan across the full ecosystem.

## gather

Use the Agent tool to spawn **six parallel Explore agents**, one per sub-repo. Each agent reports:

### Per-repo analysis

#### Unreleased changes
- Read `CHANGELOG.md` — extract the "Unreleased" section contents
- Run `git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD --oneline` to see commits since last tag
- Run `git tag --sort=-v:refname | head -5` to see recent tags and current version

#### Change classification
Classify each unreleased change as:
- **Breaking** — API changes, removed features, renamed exports
- **Feature** — new commands, new capabilities, new options
- **Fix** — bug fixes, error handling improvements
- **Chore** — refactoring, dependency updates, CI changes, docs

#### Cross-repo impact
- Check if this repo exports types or APIs consumed by other ecosystem repos
- Note any changes that affect the public interface (CLI flags, config format, JSONL schema)

## plan

After all agents return, produce:

### Release Status

| Repo | Current Version | Last Release | Commits Since | Releasable? |
|------|-----------------|--------------|---------------|-------------|

### Version Bump Recommendations

For each repo with releasable changes:
- **Repo:** name
- **Current:** x.y.z
- **Recommended:** x.y.z → a.b.c
- **Bump type:** patch / minor / major
- **Rationale:** summary of changes driving the bump
- **Breaking changes:** list any, or "none"

### Release Sequence

Order repos by dependency relationship:
1. Repos with no ecosystem dependents first (leaf nodes)
2. Repos that others depend on last (so consumers can update)

For each release in sequence:
```
1. <repo> v<old> → v<new>
   Changes: <summary>
   Depends on: none / <other releases in this batch>
   Command: cd <repo> && /release
```

### Risks and Blockers

- Repos with failing tests or lint errors (should fix before releasing)
- Breaking changes that require coordinated updates across repos
- Unreleased changes that are incomplete or experimental (should defer)

### Post-Release Tasks

- Update any cross-references (README badges, ecosystem tables)
- File seeds issues for follow-up work discovered during analysis

Do NOT execute any releases. Present the plan for human review and approval.
