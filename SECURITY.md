# Security Policy

## Supported versions

| Tool | Version | Supported |
|------|---------|-----------|
| Warren | 0.3.x | Yes |
| Burrow | 0.3.x | Yes |
| Plot | 0.3.x | Yes |
| Mulch | 0.10.x | Yes |
| Seeds | 0.4.x | Yes |
| Canopy | 0.2.x | Yes |
| Sapling | 0.3.x | Yes |
| Trellis | 0.0.x (pre-release) | Yes |
| Overstory | — | No (archived 2026-05) |

Older versions receive no security patches. Please upgrade to the latest release.

## Reporting a vulnerability

**Do not open a public issue.** Instead, use [GitHub Security Advisories](https://github.com/jayminwest/os-eco/security/advisories/new) to report vulnerabilities privately.

For tool-specific vulnerabilities, report to the relevant sub-repo:
- [Warren security advisories](https://github.com/jayminwest/warren/security/advisories/new)
- [Burrow security advisories](https://github.com/jayminwest/burrow/security/advisories/new)
- [Plot security advisories](https://github.com/jayminwest/plot/security/advisories/new)
- [Mulch security advisories](https://github.com/jayminwest/mulch/security/advisories/new)
- [Seeds security advisories](https://github.com/jayminwest/seeds/security/advisories/new)
- [Canopy security advisories](https://github.com/jayminwest/canopy/security/advisories/new)
- [Sapling security advisories](https://github.com/jayminwest/sapling/security/advisories/new)
- [Trellis security advisories](https://github.com/jayminwest/trellis/security/advisories/new)

## Response timeline

| Step | Target |
|------|--------|
| Acknowledgment | 48 hours |
| Initial assessment | 7 days |
| Fix or mitigation | 30 days |

## Scope

Vulnerabilities we care about across the ecosystem:

- Command injection via CLI arguments
- Path traversal or arbitrary file access
- Symlink attacks on storage directories
- Temp file race conditions
- Sandbox escape or privilege escalation (Burrow, Warren)
- Prompt injection via stored templates (Canopy)
- Prompt injection via audited repo contents during the LLM investigation pass (Trellis)

## Not in scope

- Denial of service via extremely large files
- Issues requiring existing shell access to the machine
- Social engineering
- Costs from spawning many agents (Warren)

## Security measures

The tools share these design principles:
- Atomic writes with advisory file locking for multi-agent safety
- Input validation on all CLI arguments
- Local-first, git-native storage; network access only where the tool's job requires it (warren's GitHub polling, trellis's bounded LLM investigation pass)
- No eval or dynamic code execution on user input
