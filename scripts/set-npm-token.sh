#!/usr/bin/env bash
# Set the NPM_TOKEN GitHub Actions secret across every publishing sub-repo.
#
# Usage:
#   scripts/set-npm-token.sh              # prompt for the token (no echo)
#   NPM_TOKEN=npm_xxx scripts/set-npm-token.sh
#   scripts/set-npm-token.sh < token.txt  # read from stdin
#
# Requires: gh (authenticated with admin on the target repos).
#
# Repos covered: every sub-repo whose release workflow uses NPM_TOKEN.
# Warren is intentionally excluded (it deploys to Fly, not npm).
# Overstory was removed 2026-05 (repo archived; archived repos reject secret writes).

set -euo pipefail

REPOS=(
  jayminwest/burrow
  jayminwest/plot
  jayminwest/mulch
  jayminwest/seeds
  jayminwest/canopy
  jayminwest/sapling
  jayminwest/trellis
)

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI not found on PATH" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "error: gh is not authenticated; run 'gh auth login' first" >&2
  exit 1
fi

token="${NPM_TOKEN:-}"

if [[ -z "$token" ]]; then
  if [[ ! -t 0 ]]; then
    # Piped or redirected input.
    token="$(cat)"
  else
    printf 'Paste npm token (input hidden): ' >&2
    IFS= read -rs token
    printf '\n' >&2
  fi
fi

# Strip surrounding whitespace / trailing newline.
token="${token#"${token%%[![:space:]]*}"}"
token="${token%"${token##*[![:space:]]}"}"

if [[ -z "$token" ]]; then
  echo "error: empty token" >&2
  exit 1
fi

echo "Setting NPM_TOKEN on ${#REPOS[@]} repos..." >&2

fail=0
for repo in "${REPOS[@]}"; do
  if printf '%s' "$token" | gh secret set NPM_TOKEN --repo "$repo"; then
    printf '  ok   %s\n' "$repo" >&2
  else
    printf '  FAIL %s\n' "$repo" >&2
    fail=$((fail + 1))
  fi
done

if (( fail > 0 )); then
  echo "done: $fail repo(s) failed" >&2
  exit 1
fi

echo "done: all repos updated" >&2
