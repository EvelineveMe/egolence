#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# SPS Promoter v1.0 — STRICT PROJECT SYSTEM
# Deterministic promotion of Telegram messages into projects
# ============================================================

WORKSPACE="/root/.openclaw/workspace"
LIFE="${WORKSPACE}/life"
PROJECTS="${LIFE}/projects"
MEMORY="${WORKSPACE}/memory"
SIGNALS="${MEMORY}/_signals"

INDEX_JSON="${PROJECTS}/_index.json"
ACTIVE_JSON="${PROJECTS}/_active.json"
MENTIONS_JSON="${SIGNALS}/project_mentions.json"

mkdir -p "${PROJECTS}" "${MEMORY}" "${SIGNALS}"

# =========================
# INPUT
# =========================

TS_UTC="${TS_UTC:-${1:-}}"
CHAT_ID="${CHAT_ID:-${2:-}}"
MESSAGE_ID="${MESSAGE_ID:-${3:-}}"
TEXT="${TEXT:-${4:-}}"

if [[ -z "${TS_UTC}" || -z "${CHAT_ID}" || -z "${MESSAGE_ID}" ]]; then
  echo "STATUS=FAIL reason=missing_required_inputs"
  exit 2
fi

TEXT_LC="$(printf '%s' "${TEXT}" | tr '[:upper:]' '[:lower:]')"

# =========================
# DAILY NOTE ENSURE
# =========================

DAY="$(date -u -d "${TS_UTC}" +%F)"
TODAY_NOTE="${MEMORY}/${DAY}.md"

if [[ ! -f "${TODAY_NOTE}" ]]; then
  : > "${TODAY_NOTE}"
  chmod 600 "${TODAY_NOTE}"
fi

HHMMZ="$(date -u -d "${TS_UTC}" +%H:%M)Z"

append_daily() {
  printf '%s %s\n' "${HHMMZ}" "$1" >> "${TODAY_NOTE}"
}

# =========================
# ENSURE REGISTRIES
# =========================

test -f "${INDEX_JSON}" || printf '%s\n' '[]' > "${INDEX_JSON}"
test -f "${ACTIVE_JSON}" || printf '%s\n' '[]' > "${ACTIVE_JSON}"
test -f "${MENTIONS_JSON}" || printf '%s\n' '{}' > "${MENTIONS_JSON}"

chmod 600 "${INDEX_JSON}" "${ACTIVE_JSON}" "${MENTIONS_JSON}" || true

# =========================
# SLUGIFY
# =========================

slugify() {
  local s="$1"
  s="$(printf '%s' "$s" | tr '[:upper:]' '[:lower:]')"
  s="$(printf '%s' "$s" | sed -E 's/[^a-z0-9]+/-/g')"
  s="$(printf '%s' "$s" | sed -E 's/^-+//; s/-+$//; s/-+/-/g')"
  s="${s:0:48}"
  printf '%s' "$s"
}

# =========================
# PROJECT MARKER
# =========================

HAS_PROJECT=0
if printf '%s' "${TEXT_LC}" | grep -q "project:"; then
  HAS_PROJECT=1
fi

if [[ "${HAS_PROJECT}" -eq 0 ]]; then
  append_daily "HEARTBEAT_OK — no PROJECT marker"
  echo "STATUS=OK action=none reason=no_project_marker"
  exit 0
fi

PROJECT_TITLE="$(printf '%s' "${TEXT}" | sed -nE 's/.*[Pp][Rr][Oo][Jj][Ee][Cc][Tt]:[[:space:]]*(.*)/\1/p' | head -n 1)"
PROJECT_NEW=0

if printf '%s' "${PROJECT_TITLE}" | grep -qi '^new[[:space:]]+'; then
  PROJECT_NEW=1
  PROJECT_TITLE="$(printf '%s' "${PROJECT_TITLE}" | sed -E 's/^[Nn][Ee][Ww][[:space:]]+//')"
fi

PROJECT_TITLE="$(printf '%s' "${PROJECT_TITLE}" | sed -E 's/[[:space:]]+$//')"
CAND_SLUG="$(slugify "${PROJECT_TITLE}")"

if [[ -z "${CAND_SLUG}" ]]; then
  append_daily "CANDIDATE invalid — empty slug"
  echo "STATUS=OK action=candidate reason=empty_slug"
  exit 0
fi

# =========================
# CRITERIA CHECKS
# =========================

has_intent_deliverable() {
  printf '%s' "$TEXT_LC" | grep -Eq '\b(build|ship|publish|deploy|write|design|launch|create|implement|configure|fix)\b' || return 1
  printf '%s' "$TEXT_LC" | grep -Eq '\b(website|landing|page|funnel|automation|bot|script|system|offer|checkout|proposal|deck|doc)\b' || return 1
}

has_urgency() {
  printf '%s' "$TEXT_LC" | grep -Eq '\b(today|urgent|asap|this week|tomorrow|deadline)\b'
}

has_multistep() {
  printf '%s' "$TEXT_LC" | grep -Eq '\b(and|then|plus)\b' && return 0
  printf '%s' "$TEXT_LC" | grep -q ',' && return 0
  return 1
}

if ! has_intent_deliverable; then
  append_daily "CANDIDATE ${CAND_SLUG} — missing intent+deliverable"
  echo "STATUS=OK action=candidate reason=missing_intent"
  exit 0
fi

if ! has_urgency; then
  append_daily "CANDIDATE ${CAND_SLUG} — missing urgency"
  echo "STATUS=OK action=candidate reason=missing_urgency"
  exit 0
fi

if ! has_multistep; then
  append_daily "CANDIDATE ${CAND_SLUG} — missing multistep"
  echo "STATUS=OK action=candidate reason=missing_multistep"
  exit 0
fi

# =========================
# UPDATE CANDIDATE TRACKER
# =========================

python3 - <<PY
import json, os
path="${MENTIONS_JSON}"
slug="${CAND_SLUG}"
ts="${TS_UTC}"
title="${PROJECT_TITLE}"

if os.path.exists(path):
    data=json.load(open(path))
else:
    data={}

rec=data.get(slug, {"count_24h":0})
rec["count_24h"]=rec.get("count_24h",0)+1
rec["last_seen_ts"]=ts
rec["last_title"]=title
data[slug]=rec

json.dump(data, open(path,"w"), indent=2)
PY

COUNT_24H="$(python3 - <<PY
import json
data=json.load(open("${MENTIONS_JSON}"))
print(data.get("${CAND_SLUG}",{}).get("count_24h",0))
PY
)"

if [[ "${PROJECT_NEW}" -ne 1 && "${COUNT_24H}" -lt 2 ]]; then
  append_daily "CANDIDATE ${CAND_SLUG} — needs repeat within 24h"
  echo "STATUS=OK action=candidate reason=needs_repeat count=${COUNT_24H}"
  exit 0
fi

# =========================
# PROMOTION + UPDATE (v2.0 — STABLE)
# =========================

PROJ_DIR="${PROJECTS}/${CAND_SLUG}"
LOCK="${PROJ_DIR}/.lock"

mkdir -p "${PROJ_DIR}"

# Acquire lock
if ! ( set -o noclobber; : > "${LOCK}" ) 2>/dev/null; then
  append_daily "PROJECT ${CAND_SLUG} — lock exists"
  echo "STATUS=FAIL reason=lock_exists"
  exit 3
fi

trap 'rm -f "${LOCK}"' EXIT

SUMMARY="${PROJ_DIR}/summary.md"
ITEMS="${PROJ_DIR}/items.json"
BACKLOG="${PROJ_DIR}/backlog.md"
ASSETS="${PROJ_DIR}/assets.md"

# Ensure template files
if [[ ! -f "${SUMMARY}" ]]; then
cat > "${SUMMARY}" <<MD
Goal
${PROJECT_TITLE}

Definition of Done

Constraints

Current Status
- ${TS_UTC} Created

Decisions (dated)

Next Actions (max 10)

Open Questions

Links / Assets
MD
fi

[[ -f "${ITEMS}" ]] || printf '%s\n' '[]' > "${ITEMS}"
[[ -f "${BACKLOG}" ]] || printf '%s\n\n' '# Backlog' > "${BACKLOG}"

chmod 600 "${SUMMARY}" "${ITEMS}" "${BACKLOG}" || true

# Register project
python3 - <<PY
import json, os
idx=json.load(open("${INDEX_JSON}"))
act=json.load(open("${ACTIVE_JSON}"))

if not any(x.get("slug")=="${CAND_SLUG}" for x in idx):
    idx.append({"slug":"${CAND_SLUG}","title":"${PROJECT_TITLE}","created_at":"${TS_UTC}"})

if "${CAND_SLUG}" not in act:
    act.append("${CAND_SLUG}")

json.dump(idx, open("${INDEX_JSON}","w"), indent=2, sort_keys=True)
json.dump(act, open("${ACTIVE_JSON}","w"), indent=2, sort_keys=True)
PY

# DEDUPE by message_id
DEDUP=$(python3 - <<PY
import json
try:
    data=json.load(open("${ITEMS}"))
except:
    data=[]
for e in data:
    src=e.get("source",{})
    if str(src.get("chat_id"))=="${CHAT_ID}" and str(src.get("message_id"))=="${MESSAGE_ID}":
        print("yes"); break
else:
    print("no")
PY
)

if [[ "${DEDUP}" == "yes" ]]; then
  append_daily "PROJECT ${CAND_SLUG} — dedup"
  echo "STATUS=OK action=dedup"
  exit 0
fi

# Append atomic fact for update
python3 - <<PY
import json, secrets, string
path="${ITEMS}"
try:
    data=json.load(open(path))
except:
    data=[]

alphabet=string.ascii_lowercase+string.digits
rand="".join(secrets.choice(alphabet) for _ in range(6))
id=f"fx_${TS_UTC}_{rand}"

data.append({
    "id": id,
    "ts": "${TS_UTC}",
    "type": "fact",
    "subject": "${PROJECT_TITLE}",
    "predicate": "update",
    "object": "Updated via SPS",
    "status": "active",
    "supersedes": [],
    "source": {"channel":"telegram","chat_id":"${CHAT_ID}","message_id":"${MESSAGE_ID}"},
    "confidence": 1.0
})

json.dump(data, open(path,"w"), indent=2, sort_keys=True)
PY

chmod 600 "${ITEMS}" || true

append_daily "PROJECT ${CAND_SLUG} — updated"
echo "STATUS=OK action=updated slug=${CAND_SLUG}"
