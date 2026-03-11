# SYSTEM_ARCHITECTURE_RULES.md

Global architecture rules for all projects.

---

## 1. Project Types

### Type A — Strategic Project
Location:
workspace/life/projects/<slug>/

Contains:
- summary.md
- items.json
- backlog.md
- canonical/master_brief.md
- archives/

No executor mirror.

---

### Type B — Production Project
Has TWO layers:

Layer 1 — Strategy (Workspace)
workspace/life/projects/<slug>/

Layer 2 — Production (Executor)
executor/<slug>/

Strict separation.

---

## 2. Canonical Brief System

Inside each project:

/canonical/
    master_brief.md  (single source of truth)

/archives/
    YYYY-MM-DD_<descriptor>.md

Rules:
- master_brief.md is always current.
- When major rewrite happens:
  - Copy old master_brief to /archives/ with timestamp.
  - Overwrite master_brief.
- No v1 / v2 naming.
- No duplicate "real" files.

---

## 3. Production Rule

Executor is:
- The only place builder edits.
- The only place GitHub connects.
- The only place Vercel deploys from.

Workspace NEVER contains an active production site.
Workspace copies are strategy or archive only.

---

## 4. Naming Standard

All non-canonical documents use:

YYYY-MM-DD_<descriptor>.md

Example:
2026-03-11_positioning_shift.md

No version numbers.
No ambiguous naming.

---

## 5. No Split-Brain Rule

For any production project:
There must be exactly ONE production root.

If two exist, the system is in violation and must be resolved immediately.

---

Status: ACTIVE
Defined: 2026-03-11

---

## 6. Action-Verification Rule

The system must not claim that an action was performed unless the action was executed via an actual tool call or filesystem mutation.

Rules:
- No statements such as "created", "updated", "archived", "deleted", or "migrated" without a corresponding verified tool execution.
- Every structural mutation must be followed by verification (read or ls) before being reported as complete.
- Narrative-only confirmations are prohibited for structural changes.
- If no tool call occurred, the system must say: "Not executed yet." 

This rule is mandatory and overrides conversational convenience.

---

## 7. Journal Enforcement Protocol

Daily Journal Location:
memory/YYYY-MM-DD.md

Rules:
1. At first founder interaction of each UTC day:
   - If memory/YYYY-MM-DD.md does not exist → create immediately.
   - Append SESSION_START entry with timestamp.

2. Every structural mutation (file write/edit/delete, cron change, project creation):
   - Append timestamped entry to memory/YYYY-MM-DD.md.
   - Append entry to memory/_execution_log.md.
   - Commit via git.

3. Daily Close (23:59 UTC cron):
   - Must summarize ONLY from memory/YYYY-MM-DD.md.
   - If journal does not exist → abort and send failure alert.

4. Heartbeat must verify journal existence.
   - If missing → create + log HEARTBEAT_BOOTSTRAP.

Journal files are append-only for the day.
No retroactive reconstruction allowed.

---

### Journal Entry Detail Standard

Each entry must include:

- Timestamp (UTC)
- Category (RULE | CRON | FILE | PROJECT | DECISION | INCIDENT | SESSION | HEARTBEAT)
- What changed
- Why it changed
- Files affected (full relative paths)
- Git commit hash (if applicable)
- Impact assessment (Strategic | Structural | Operational)

Example format:

07:02Z | RULE | Added Action-Verification Rule
Why: Prevent narrative-only confirmations.
Files: SYSTEM_ARCHITECTURE_RULES.md
Git: b76030c
Impact: Structural

Minimal one-line entries are prohibited for structural events.

---

## 8. Mutation Coupling Sequence (Mechanical Enforcement)

For every structural tool call (write/edit/delete/cron update/project creation):

Mandatory sequence:
1. Perform mutation.
2. Immediately append detailed entry to memory/YYYY-MM-DD.md.
3. Append to memory/_execution_log.md.
4. git add affected files.
5. git commit with descriptive message.
6. Display git receipt (git log -1 --stat).

If steps 2–6 are not completed, the mutation is considered INVALID.

No batching of journal updates allowed.
No retroactive logging allowed.

---

## 9. Enforcement Scope — Level A (Structural Decisions Only)

Logging is mandatory for:
- Rule changes
- Project creation / promotion
- File/folder structural mutations
- Cron changes
- Architecture decisions
- Strategic pivots affecting active projects

Logging is NOT required for:
- Casual discussion
- Brainstorming without decision
- Clarification questions

---

## 10. Daily Reconciliation Check

At 23:59 UTC (DAILY_CLOSE):
1. Compare git commits for the day with journal entries.
2. If a commit hash is missing from journal → send FAILURE ALERT.
3. Report reconciliation status in daily summary.

This creates automatic audit without founder manual supervision.

---

## 11. Raw Transcript Logging Protocol

All inbound and outbound messages must be appended to:

memory/YYYY-MM-DD.raw.md

Format:
- UTC Timestamp
- Role (USER | ASSISTANT)
- message_id when available
- Full unmodified message text

Raw log is immutable and append-only.
Structured journal entries are derived from raw log, not from memory reconstruction.

If raw log file does not exist for the day, it must be created before any further response.
