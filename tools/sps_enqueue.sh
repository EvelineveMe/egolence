#!/usr/bin/env bash
set -euo pipefail

WS="/root/.openclaw/workspace"
ACTIVE_FILE="$WS/life/projects/_active.json"
[ -f "$ACTIVE_FILE" ]: # "|| exit 1"
SLUG=$(jq -r 'if type=="string" then . elif type=="array" then .[0] else empty end' "$ACTIVE_FILE")
[ -n "$SLUG" ]: # "&& [ \"$SLUG\" != \"null\" ] || exit 1"
PROJ="$WS/life/projects/$SLUG"
PLAN="$PROJ/plan.md"
QUEUE="$PROJ/next_actions.txt"
MEM="$WS/memory/$(date -u +%F).md"
INPUT="$*"

mkdir -p "$PROJ"

timestamp() {
  date -u +%FT%TZ
}

enqueue_action() {
  local action="$1"
  touch "$QUEUE"
  echo "$action" >> "$QUEUE"
  echo "$(timestamp) ENQUEUED: $action" >> "$MEM"
}

if [[ "$INPUT" == PLAN:* ]]; then
  TEXT="${INPUT#PLAN: }"
  echo "$TEXT" > "$PLAN.tmp"
  mv "$PLAN.tmp" "$PLAN"
  echo "$(timestamp) ENQUEUED: PLAN" >> "$MEM"
elif [[ "$INPUT" =~ ^Create\ folder\ (.+)$ ]]; then
  REL="${BASH_REMATCH[1]}"
  enqueue_action "SPS_MKDIR $REL"
elif [[ "$INPUT" =~ ^Write\ file\ ([^[:space:]]+)\ with\ text:\ (.+)$ ]]; then
  REL="${BASH_REMATCH[1]}"
  TEXT="${BASH_REMATCH[2]}"
  B64=$(printf "%s" "$TEXT" | base64 -w0)
  enqueue_action "SPS_WRITE $REL $B64"
elif [[ "$INPUT" =~ ^Append\ to\ file\ ([^[:space:]]+)\ with\ text:\ (.+)$ ]]; then
  REL="${BASH_REMATCH[1]}"
  TEXT="${BASH_REMATCH[2]}"
  B64=$(printf "%s" "$TEXT" | base64 -w0)
  enqueue_action "SPS_APPEND $REL $B64"
elif [[ "$INPUT" =~ ^Patch\ file\ ([^[:space:]]+)\ find:\ (.+)\ replace:\ (.+)$ ]]; then
  REL="${BASH_REMATCH[1]}"
  FIND="${BASH_REMATCH[2]}"
  REPLACE="${BASH_REMATCH[3]}"
  FIND_B64=$(printf "%s" "$FIND" | base64 -w0)
  REPLACE_B64=$(printf "%s" "$REPLACE" | base64 -w0)
  enqueue_action "SPS_PATCH $REL $FIND_B64 $REPLACE_B64"
elif [[ "$INPUT" =~ ^Copy\ file\ ([^[:space:]]+)\ to\ ([^[:space:]]+)$ ]]; then
  SRC="${BASH_REMATCH[1]}"
  DST="${BASH_REMATCH[2]}"
  enqueue_action "SPS_CP $SRC $DST"
fi
