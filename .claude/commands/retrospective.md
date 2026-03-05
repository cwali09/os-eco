---
name: retrospective
description: Review the last overstory swarm run for outcomes, patterns, and learnings
---

## description

Analyze the most recent overstory swarm run across the ecosystem. Review agent outcomes, token costs, success rates, and coordination patterns. Surface learnings worth capturing in mulch.

**Argument:** `$ARGUMENTS` — optional: a session ID or repo name to focus on. If empty, analyze the most recent run across all repos.

## gather

Use the Agent tool to spawn **three parallel agents**:

### Agent A: Run outcomes
For each sub-repo with `.overstory/` initialized:
- Run `ov session list --limit 5` to find recent sessions
- Run `ov session show <id>` for the most recent session
- Check `.overstory/logs/` for agent stdout/stderr logs from the latest run
- Capture: session ID, start time, duration, agent count, final status

For each agent in the session:
- What type was it (scout/builder/reviewer/lead/coordinator)?
- Did it complete successfully or fail?
- What was its assigned task/spec?
- How many turns did it take?

### Agent B: Issue resolution
- Run `sd list --status closed` in each sub-repo to find recently closed issues
- Cross-reference with the session: which issues were targeted vs. actually closed?
- Check for issues that were worked on but left open (partial progress)
- Run `sd list --status open` to see what remains

### Agent C: Code changes
For each sub-repo:
- Run `git log --since="1 week ago" --oneline --stat` to see recent changes
- Check for any unmerged branches from agent runs: `git branch --no-merged`
- Check `.overstory/worktrees/` for leftover worktrees
- Look at merge-queue state: are there pending merges?

## analyze

After all agents return, produce:

### Run Summary

| Repo | Session | Duration | Agents | Completed | Failed | Issues Closed |
|------|---------|----------|--------|-----------|--------|---------------|

### Agent Performance

| Agent Type | Total Spawned | Succeeded | Failed | Avg Turns | Notes |
|------------|---------------|-----------|--------|-----------|-------|

### What Went Well
- List successful patterns: agents that completed cleanly, effective delegation, good spec quality
- Note any repos that were particularly smooth

### What Went Poorly
- List failures with root cause analysis:
  - Agent failures: what went wrong and why?
  - Merge conflicts: which files, could they have been avoided by better scoping?
  - Stalled agents: what caused the stall?
  - Scope issues: were specs too broad or too narrow?

### Coordination Patterns
- How effective was the coordinator → lead → builder hierarchy?
- Were there communication bottlenecks (mail delays, unclear dispatches)?
- Did any agents duplicate work or step on each other?

### Cost Assessment
- Rough token estimate per agent type (based on turn count × average message size)
- Were any agents wasteful (many turns with little output)?
- Suggestions for reducing cost in future runs

### Mulch Candidates
Suggest specific mulch records to capture from this run:
```bash
ml record ecosystem --type <type> --description "<insight>"
```

Categories:
- **Patterns**: Coordination approaches that worked well
- **Failures**: Mistakes to avoid (with evidence from this run)
- **Decisions**: Scoping or sequencing choices that should become conventions
- **Conventions**: Standards that emerged from this run

### Cleanup
- Leftover worktrees that should be removed
- Unmerged branches that need attention
- Open issues that should be updated with progress notes

Do NOT perform cleanup. Present it as a checklist for the human operator.
