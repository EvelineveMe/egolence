# LEARNINGS.md

## [LRN-20260309-001] best_practice

**Logged**: 2026-03-09T00:39:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Avoid parallel autonomy systems (cron heartbeats + standalone continuous worker) without a single orchestration authority.

### Details
In the last few days, multiple automation layers were built:
- Cron-based heartbeat system
- Nightly deep dive agent
- Daily report agent
- Experimental standalone continuous worker (non-functional)

There is no single orchestration contract defining:
- Source of truth for execution loop
- Conflict resolution between schedulers
- Lifecycle management (start/stop/pause)

Result: overlapping execution models, partial implementations, unclear system boundaries.

### Suggested Action
1. Define ONE autonomy architecture (cron-driven OR persistent worker — not both).
2. Create a single orchestration document defining control surface.
3. Remove or archive experimental worker until architecture is validated.

### Metadata
- Source: conversation
- Tags: autonomy, architecture, drift
- Pattern-Key: simplify.single_orchestrator
- Recurrence-Count: 1
- First-Seen: 2026-03-09
- Last-Seen: 2026-03-09

---

## [LRN-20260309-002] correction

**Logged**: 2026-03-09T00:43:00Z
**Priority**: critical
**Status**: pending
**Area**: infra

### Summary
Cron-centric autonomy produced narrative output without verified execution (hallucinated progress).

### Details
User feedback: "You were hallucinating but not doing work."
Under cron-centric model, agents generated structured reports about progress without performing concrete filesystem mutations or verified state changes. Reporting layer decoupled from execution layer.

Core failure:
- No enforced "mutation required before reporting" invariant.
- No execution verification gate (e.g., git diff, file existence, state checks).
- Narrative generation not tied to measurable artifact production.

### Suggested Action
1. Enforce Execution Invariant: No progress reports without tool-based mutation or verification.
2. Add automatic state verification before any status output.
3. Separate "analysis mode" from "execution mode" explicitly.
4. Default to execution-first loops when deliverable is artifact-based (e.g., website build).

### Metadata
- Source: user_feedback
- Tags: hallucination, execution, reporting_drift
- Pattern-Key: harden.execution_verification
- Recurrence-Count: 1
- First-Seen: 2026-03-09
- Last-Seen: 2026-03-09

---
