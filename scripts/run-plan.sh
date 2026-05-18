#!/usr/bin/env bash
# Run claude code sessions in sequence over the children of a seeds plan.
#
# Usage: ./run-plan.sh <plan-id>
#
# For each open child issue in the plan, invokes:
#   claude -p "work on sd <id>. use ml. commit when done, no push." \
#     --permission-mode bypassPermissions \
#     --verbose --output-format stream-json
#
# Stops on the first non-zero claude exit. Closed children are skipped so
# re-runs are idempotent. Per-child logs land in ./.run-plan-logs/<plan>/:
#   <id>.log    human-readable per-event summary (timestamped, tail -f friendly)
#   <id>.jsonl  raw stream-json events (full fidelity, jq-able)

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <plan-id>" >&2
  exit 2
fi

plan_id="$1"

for bin in sd claude jq; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: '$bin' not found on PATH" >&2
    exit 2
  fi
done

plan_json="$(sd plan show "$plan_id" --json)"

if [[ "$(jq -r '.success' <<<"$plan_json")" != "true" ]]; then
  echo "error: sd plan show failed for $plan_id" >&2
  jq '.' <<<"$plan_json" >&2
  exit 2
fi

children=()
while IFS= read -r line; do
  children+=("$line")
done < <(jq -r '.plan.children[]' <<<"$plan_json")

if [[ ${#children[@]} -eq 0 ]]; then
  echo "no children found in plan $plan_id" >&2
  exit 0
fi

log_dir=".run-plan-logs/$plan_id"
mkdir -p "$log_dir"

# jq filter: turn stream-json NDJSON into one human-readable block per event.
# Robust against stray non-JSON lines via -R + fromjson?. Long tool inputs /
# results are truncated in the .log; the .jsonl keeps the originals.
event_filter='
def ts: now | strftime("%H:%M:%S");
def trunc(n): if (. | length) > n then .[0:n] + "…[+\((. | length) - n) chars]" else . end;
def text_of_content:
  if   type == "array"  then map(.text // tojson) | join("\n")
  elif type == "string" then .
  else  tojson end;
def fmt:
  if .type == "system" then
    "[\(ts)] system:\(.subtype // "?") " +
      (if .subtype == "init"
       then "session=\(.session_id // "?") model=\(.model // "?") cwd=\(.cwd // "?")"
       else (. | tojson | trunc(500)) end)
  elif .type == "assistant" then
    (.message.content // [] | map(
      if   .type == "text"     then "[\(ts)] assistant:\n\(.text)"
      elif .type == "thinking" then "[\(ts)] thinking:\n\(.thinking // "")"
      elif .type == "tool_use" then "[\(ts)] tool_use:\(.name) " + ((.input // {}) | tojson | trunc(800))
      else "[\(ts)] content:\(.type // "?")" end
    ) | join("\n"))
  elif .type == "user" then
    (.message.content // [] | map(
      if .type == "tool_result"
      then "[\(ts)] tool_result" + (if .is_error then "[err]" else "" end) + ":\n" +
             ((.content // "") | text_of_content | trunc(2000))
      else "[\(ts)] user:\(.type // "?")" end
    ) | join("\n"))
  elif .type == "result" then
    "[\(ts)] result:\(.subtype // "?") turns=\(.num_turns // "?") cost=$\(.total_cost_usd // 0) duration=\(.duration_ms // 0)ms" +
      (if .result then "\n" + (.result | tostring | trunc(2000)) else "" end)
  else
    "[\(ts)] \(.type // "?") " + (. | tojson | trunc(500))
  end;
((fromjson? | fmt) // ("[\(now | strftime("%H:%M:%S"))] raw: " + .))
'

echo "plan $plan_id: ${#children[@]} children"
for id in "${children[@]}"; do
  status="$(sd show "$id" --json 2>/dev/null | jq -r '.issue.status // .issues[0].status // empty')"
  if [[ "$status" == "closed" ]]; then
    echo "  skip  $id (closed)"
    continue
  fi

  echo "  run   $id (status=${status:-unknown})"
  prompt="work on sd $id. use ml. commit when done, no push."
  log="$log_dir/$id.log"
  raw_log="$log_dir/$id.jsonl"

  if ! claude -p "$prompt" \
        --permission-mode bypassPermissions \
        --verbose \
        --output-format stream-json 2>&1 \
      | tee "$raw_log" \
      | jq -R --unbuffered -r "$event_filter" \
      | tee "$log"; then
    echo "error: claude exited non-zero on $id — see $log (raw: $raw_log)" >&2
    exit 1
  fi
done

echo "done."
