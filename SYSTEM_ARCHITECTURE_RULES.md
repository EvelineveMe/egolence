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
