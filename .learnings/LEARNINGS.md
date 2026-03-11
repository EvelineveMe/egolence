# LEARNINGS.md

## [LRN-20260311-001] correction

**Logged**: 2026-03-11T07:37:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Claimed enforcement without mechanical coupling; journaling gaps exposed by founder.

### Details
Multiple instances where structural rule changes were committed but not immediately logged in the daily journal. Founder identified mismatch between declared protocol and actual logging behavior.

### Suggested Action
Enforce Mutation Coupling Sequence strictly and add daily reconciliation check.

### Metadata
- Source: user_feedback
- Related Files: SYSTEM_ARCHITECTURE_RULES.md, memory/2026-03-11.md
- Tags: integrity, journaling, enforcement

---

## [LRN-20260311-002] best_practice

**Logged**: 2026-03-11T07:37:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Daily summary cannot function without continuous journal bootstrap.

### Details
Cron-based daily summary failed after session reset because no daily journal existed. Reconstruction is lossy and undermines system trust.

### Suggested Action
Mandatory daily bootstrap + heartbeat verification + reconciliation against git.

### Metadata
- Source: conversation
- Related Files: memory/YYYY-MM-DD.md, SYSTEM_ARCHITECTURE_RULES.md
- Tags: journaling, automation, reliability

---
