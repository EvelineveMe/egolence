# LEARNINGS.md

## [LRN-20260311-003] knowledge_gap

**Logged**: 2026-03-11T07:59:00Z
**Priority**: critical
**Status**: pending
**Area**: infra

### Summary
Raw transcript logging is rule-based, not infrastructure-hook based.

### Details
Current implementation appends to raw log via assistant behavior. There is no guaranteed automatic interception at message-handler level. If assistant logic fails, raw logging can silently stop.

### Suggested Action
Implement logging at transport layer (Telegram inbound/outbound hook) instead of conversational layer.

### Metadata
- Source: audit
- Related Files: memory/YYYY-MM-DD.raw.md
- Tags: logging, integrity, automation

---

## [LRN-20260311-004] best_practice

**Logged**: 2026-03-11T07:59:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Daily reconciliation rule exists but reconciliation logic not implemented.

### Details
SYSTEM_ARCHITECTURE_RULES.md defines reconciliation between git commits and journal entries. DAILY_CLOSE cron does not yet perform actual commit hash verification.

### Suggested Action
Modify DAILY_CLOSE routine to programmatically compare `git log --since=today` with journal commit references.

### Metadata
- Source: audit
- Related Files: SYSTEM_ARCHITECTURE_RULES.md
- Tags: reconciliation, audit

---

## [LRN-20260311-005] best_practice

**Logged**: 2026-03-11T07:59:00Z
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
Raw log has no integrity checksum or external backup.

### Details
If workspace is corrupted or deleted, raw transcript layer is lost. No offsite or append-only guarantee beyond git.

### Suggested Action
Implement periodic hash snapshot or remote mirror backup.

### Metadata
- Source: audit
- Related Files: memory/YYYY-MM-DD.raw.md
- Tags: backup, resilience

---
