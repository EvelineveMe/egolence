#!/usr/bin/env bash
WORKSPACE="/root/.openclaw/workspace"
ACTIVE=$(jq -r '.[0] // empty' "$WORKSPACE/life/projects/_active.json" 2>/dev/null)
QUEUE="$WORKSPACE/life/projects/$ACTIVE/next_actions.txt"
MEM="$WORKSPACE/memory/$(date -u +%Y-%m-%d).md"

LEN=0
[ -f "$QUEUE" ] && LEN=$(wc -l < "$QUEUE")

echo "Active: $ACTIVE"
echo "Queue length: $LEN"
echo "Last 10 EXECUTED/BLOCKED:"
grep -E "EXECUTED:|BLOCKED:" "$MEM" | tail -n 10
