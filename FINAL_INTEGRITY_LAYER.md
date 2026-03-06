# FINAL_INTEGRITY_LAYER.md

## 1. Strategy Integrity Validator

Before any execution:
- strategy.md must NOT contain "TBD".
- Audience Lock must be filled.
- Positioning Lock must be filled.
- Current Phase must be defined.

If any condition fails → abort execution.

---

## 2. Canonical Artifact Gate

Before modifying landing page or strategic assets:
- At least one approved artifact must exist in:
  life/projects/<slug>/assets/canonical_versions/

If empty → abort build execution.

---

## 3. Weekly Journal Compaction

Every 7 days:
- Summarize previous week from _live_journal.md
- Extract durable decisions to strategy.md and items.json
- Archive raw weekly journal to life/archives/

Prevents long-term drift and context noise.
