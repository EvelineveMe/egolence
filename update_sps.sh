#!/usr/bin/env bash
SPS_EXEC_PATH="/root/.openclaw/workspace/tools/sps_exec_one.sh"
SPS_ENQUEUE_PATH="/root/.openclaw/workspace/tools/sps_enqueue.sh"
cp "$SPS_EXEC_PATH" "${SPS_EXEC_PATH}.bak.$(date +%s)"
cp "$SPS_ENQUEUE_PATH" "${SPS_ENQUEUE_PATH}.bak.$(date +%s)"

cat << 'EOF' > "$SPS_EXEC_PATH"
#!/usr/bin/env bash
set -euo pipefail
LOCKFILE="/tmp/eve8_exec.lock"
exec 9>"$LOCKFILE" || exit 1
flock -n 9 || exit 0
WORKSPACE="/root/.openclaw/workspace"
PROJECTS_DIR="$WORKSPACE/life/projects"
ACTIVE_FILE="$PROJECTS_DIR/_active.json"
TODAY_FILE="$WORKSPACE/memory/$(date -u +%Y-%m-%d).md"
[ -f "$ACTIVE_FILE" ]: # "|| exit 0"
ACTIVE_SLUG=$(jq -r 'if type=="string" then . elif type=="array" then .[0] else empty end' "$ACTIVE_FILE")
[ -n "$ACTIVE_SLUG" ]: # "&& [ \"$ACTIVE_SLUG\" != \"null\" ] || exit 0"
PROJECT_DIR="$PROJECTS_DIR/$ACTIVE_SLUG"
QUEUE_FILE="$PROJECT_DIR/next_actions.txt"
[ -f "$QUEUE_FILE" ]: # "|| exit 0"
ACTION=$(head -n 1 "$QUEUE_FILE")
[ -n "$ACTION" ]: # "|| exit 0"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
safe_path() {
  local rel="$1"
  local target="$WORKSPACE/$rel"
  [[ "$target" == "$WORKSPACE"* ]] || return 1
  [[ "$rel" != /* ]] || return 1
  [[ "$rel" != *".."* ]] || return 1
  echo "$target"
}
log_receipt() {
  local status="$1"
  local msg="$2"
  echo "$TS $status: $msg" >> "$TODAY_FILE"
  openclaw system event --text "SPS $status: $msg" --mode now || true
}
if [[ "$ACTION" == SPS_WRITE* ]] || [[ "$ACTION" == SPS_APPEND* ]]; then
  CMD=$(echo "$ACTION" | awk '{print $1}')
  REL=$(echo "$ACTION" | awk '{print $2}')
  B64=$(echo "$ACTION" | awk '{print $3}')
  TARGET=$(safe_path "$REL") || { log_receipt "BLOCKED" "$ACTION — invalid path"; exit 0; }
  mkdir -p "$(dirname "$TARGET")"
  CONTENT=$(echo "$B64" | base64 -d)
  if [ "$CMD" = "SPS_WRITE" ]; then printf "%s" "$CONTENT" > "$TARGET"; else printf "%s" "$CONTENT" >> "$TARGET"; fi
  log_receipt "EXECUTED" "$ACTION"
  tail -n +2 "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
  exit 0
fi
if [[ "$ACTION" == SPS_PATCH* ]]; then
  REL=$(echo "$ACTION" | awk '{print $2}')
  FIND_B64=$(echo "$ACTION" | awk '{print $3}')
  REPLACE_B64=$(echo "$ACTION" | awk '{print $4}')
  TARGET=$(safe_path "$REL") || { log_receipt "BLOCKED" "$ACTION — invalid path"; exit 0; }
  [ -f "$TARGET" ] || { log_receipt "BLOCKED" "$ACTION — file not found"; exit 0; }
  FIND_STR=$(echo "$FIND_B64" | base64 -d)
  REPLACE_STR=$(echo "$REPLACE_B64" | base64 -d)
  python3 -c "
import sys
path = '$TARGET'
find_str = \"\"\"$FIND_STR\"\"\"
replace_str = \"\"\"$REPLACE_STR\"\"\"
with open(path, 'r') as f:
    content = f.read()
if find_str in content:
    new_content = content.replace(find_str, replace_str)
    with open(path, 'w') as f:
        f.write(new_content)
    sys.exit(0)
else:
    sys.exit(1)
" && { log_receipt "EXECUTED" "$ACTION"; } || { log_receipt "FAILED" "$ACTION — string not found"; }
  tail -n +2 "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
  exit 0
fi
if [[ "$ACTION" == SPS_MKDIR* ]]; then
  REL=$(echo "$ACTION" | awk '{print $2}')
  TARGET=$(safe_path "$REL") || { log_receipt "BLOCKED" "$ACTION — invalid path"; exit 0; }
  mkdir -p "$TARGET"
  log_receipt "EXECUTED" "$ACTION"
  tail -n +2 "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
  exit 0
fi
if [[ "$ACTION" == SPS_CP* ]]; then
  SRC_REL=$(echo "$ACTION" | awk '{print $2}')
  DST_REL=$(echo "$ACTION" | awk '{print $3}')
  SRC=$(safe_path "$SRC_REL") || { log_receipt "BLOCKED" "$ACTION — invalid src"; exit 0; }
  DST=$(safe_path "$DST_REL") || { log_receipt "BLOCKED" "$ACTION — invalid dst"; exit 0; }
  [ -f "$SRC" ] || { log_receipt "BLOCKED" "$ACTION — src not file"; exit 0; }
  mkdir -p "$(dirname "$DST")"
  cp "$SRC" "$DST"
  log_receipt "EXECUTED" "$ACTION"
  tail -n +2 "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
  exit 0
fi
tail -n +2 "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
exit 0
EOF

cat << 'EOF' > "$SPS_ENQUEUE_PATH"
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
timestamp() { date -u +%FT%TZ; }
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
EOF

chmod +x "$SPS_EXEC_PATH"
chmod +x "$SPS_ENQUEUE_PATH"
echo "SPS Upgrade Complete!"
