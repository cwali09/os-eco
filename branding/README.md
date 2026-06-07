# os-eco Branding & Standards

Canonical reference for visual identity, CLI conventions, and consistency standards
across the os-eco tooling ecosystem (warren, burrow, plot, mulch, seeds, canopy, sapling, trellis).

Last verified: 2026-03-05 (full audit with per-file evidence). Burrow and Warren added 2026-05-13, audit pending. Plot added 2026-05-17, audit pending. Trellis added 2026-06-06 (pre-release), audit pending. Overstory and greenhouse were archived 2026-05 and are no longer tracked.

## Status

Rows are ordered by ecosystem tier: flagship → substrate → context primitives → runtime → standards.

| Tool | Version | Branding | CLI Standards | Remaining |
|------|---------|----------|---------------|-----------|
| Warren | 0.3.0 | pending | pending | Full audit against visual-spec.md + cli-standards.md |
| Burrow | 0.3.0 | pending | pending | Full audit against visual-spec.md + cli-standards.md |
| Plot | 0.3.0 | pending | pending | Full audit against visual-spec.md + cli-standards.md |
| Mulch | 0.10.0 | complete | complete | — |
| Seeds | 0.4.4 | complete | complete | — |
| Canopy | 0.2.4 | complete | complete | — |
| Sapling | 0.3.2 | complete | complete | — |
| Trellis | 0.0.1 | pending | pending | Pre-release; full audit against visual-spec.md + cli-standards.md once the MVP lands |

## Quick Start

```bash
# See all visual standards rendered in your terminal
bun branding/preview.ts
```

## Contents

| File | What it covers |
|------|---------------|
| [visual-spec.md](visual-spec.md) | Color palette, ASCII logo, icons, message formats, help screen template |
| [cli-standards.md](cli-standards.md) | Flags, JSON envelope, error handling, version, arg parsing |
| [documentation.md](documentation.md) | README template, badges, changelog format, npx support |
| [roadmap.md](roadmap.md) | Future work: cli-common package, CI parity, man pages, website |
| [checklists.md](checklists.md) | Per-tool implementation checklists |
| [preview.ts](preview.ts) | Runnable branding reference script |

## For Agents

If you're an agent working in a sub-repo, here's what you need:

1. Run `bun branding/preview.ts` (from the os-eco root) to see the visual targets
2. Read `visual-spec.md` for exact colors, icons, and message formats
3. Read `cli-standards.md` for flag conventions and JSON output format
4. Check `checklists.md` for your tool's specific TODO items
