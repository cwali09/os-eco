# Contributing to os-eco

Thanks for your interest in the os-eco ecosystem. This guide covers contributions to the **meta-repo** — cross-cutting concerns, branding standards, and ecosystem-level issues.

For tool-specific contributions, see each sub-repo's own CONTRIBUTING.md:
- [Warren](https://github.com/jayminwest/warren/blob/main/CONTRIBUTING.md)
- [Burrow](https://github.com/jayminwest/burrow/blob/main/CONTRIBUTING.md)
- [Plot](https://github.com/jayminwest/plot/blob/main/CONTRIBUTING.md)
- [Mulch](https://github.com/jayminwest/mulch/blob/main/CONTRIBUTING.md)
- [Seeds](https://github.com/jayminwest/seeds/blob/main/CONTRIBUTING.md)
- [Canopy](https://github.com/jayminwest/canopy/blob/main/CONTRIBUTING.md)
- [Sapling](https://github.com/jayminwest/sapling/blob/main/CONTRIBUTING.md)
- [Trellis](https://github.com/jayminwest/trellis/blob/main/CONTRIBUTING.md)

## Getting started

1. Fork and clone the repo
2. Install [Bun](https://bun.sh/) >= 1.0
3. Clone the sub-repos if you need them locally:
   ```bash
   git clone https://github.com/jayminwest/warren.git
   git clone https://github.com/jayminwest/burrow.git
   git clone https://github.com/jayminwest/plot.git
   git clone https://github.com/jayminwest/mulch.git
   git clone https://github.com/jayminwest/seeds.git
   git clone https://github.com/jayminwest/canopy.git
   git clone https://github.com/jayminwest/sapling.git
   git clone https://github.com/jayminwest/trellis.git
   ```
4. Create a branch:
   ```bash
   git checkout -b feat/your-change
   ```

## Branch naming

| Prefix | Use |
|--------|-----|
| `fix/` | Bug fixes |
| `feat/` | New features |
| `docs/` | Documentation changes |
| `refactor/` | Refactoring |

## What lives in this repo

- `branding/` — Visual identity, CLI standards, documentation templates, checklists
- `.mulch/` — Ecosystem-level expertise (cross-tool patterns and decisions)
- `.seeds/` — Ecosystem-level issues (integration bugs, cross-tool features)
- `.canopy/` — Shared prompt templates
- `CLAUDE.md` — Agent instructions for the ecosystem
- `README.md` — Public-facing overview

## Commit message style

Use conventional-style prefixes when they fit, or plain descriptive messages:

```
feat: add ecosystem-wide branding checklist
fix: correct badge URLs in README
docs: update tool relationship diagram
```

## Pull request expectations

- Keep PRs focused — one concern per PR
- Describe what changed and why
- If your change affects multiple tools, note which sub-repos need corresponding changes
- Cross-repo integration issues should be filed in root `.seeds/`

## Reporting issues

- **Ecosystem-wide issues** (integration bugs, cross-tool features): file in this repo
- **Tool-specific issues**: file in the relevant sub-repo ([warren](https://github.com/jayminwest/warren/issues), [burrow](https://github.com/jayminwest/burrow/issues), [plot](https://github.com/jayminwest/plot/issues), [mulch](https://github.com/jayminwest/mulch/issues), [seeds](https://github.com/jayminwest/seeds/issues), [canopy](https://github.com/jayminwest/canopy/issues), [sapling](https://github.com/jayminwest/sapling/issues), [trellis](https://github.com/jayminwest/trellis/issues))

## License

By contributing you agree that your contributions will be licensed under the [MIT License](LICENSE).
