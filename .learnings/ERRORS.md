# ERRORS.md

## [ERR-20260309-001] standalone_continuous_worker

**Logged**: 2026-03-09T00:39:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Standalone continuous worker does not run reliably and conflicts with cron-based heartbeat system.

### Error
Non-deterministic behavior: worker either not executing, duplicating execution, or being superseded by cron-triggered jobs.

### Context
Attempted to introduce a persistent autonomous worker while cron-based scheduled agents were still active. No mutual exclusion, no single state controller, no execution contract.

### Suggested Fix
- Disable experimental worker completely until architectural decision is made.
- Audit active cron jobs and background agents.
- Create documented execution model before reintroducing persistent worker.

### Metadata
- Reproducible: yes
- Tags: autonomy, scheduler, conflict

---
