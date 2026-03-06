#!/usr/bin/env bash
set -euo pipefail
WS="/root/.openclaw/workspace"
SLUG=$(jq -r '.[0]' "$WS/life/projects/_active.json")
PROJ="$WS/life/projects/$SLUG"
BACKLOG="$PROJ/backlog_primitives.txt"
QUEUE="$PROJ/next_actions.txt"
STATUS="$PROJ/status.txt"
MEM="$WS/memory/$(date -u +%F).md"
CMD="$1"
if [[ "$CMD" == "RUN" ]]; then
  N="$2"
  head -n "$N" "$BACKLOG" > "$PROJ/.move.tmp" || true
  cat "$PROJ/.move.tmp" >> "$QUEUE"
  tail -n +$((N+1)) "$BACKLOG" > "$PROJ/.remain.tmp" || true
  mv "$PROJ/.remain.tmp" "$BACKLOG"
  rm -f "$PROJ/.move.tmp"
  echo "$(date -u +%FT%TZ) ENQUEUED: RUN BACKLOG $N" >> "$MEM"
elif [[ "$CMD" == "STATUS" ]]; then
  COUNT=$(wc -l < "$BACKLOG" 2>/dev/null || echo 0)
  {
    echo "Remaining: $COUNT"
    echo "Next 5:"
    head -n 5 "$BACKLOG" 2>/dev/null || true
    echo "Recent log:"
    grep -E "ENQUEUED:|EXECUTED:|BLOCKED:" "$MEM" | tail -n 10 || true
  } > "$STATUS.tmp"
  mv "$STATUS.tmp" "$STATUS"
fi
