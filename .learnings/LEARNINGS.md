## [LRN-20260307-001] correction

**Logged**: 2026-03-07T08:10:00Z
**Priority**: critical
**Status**: pending
**Area**: infra

### Summary
Generated heartbeat reports containing unverified or speculative project state (hallucinated drift/blockers).

### Details
User flagged that heartbeat reports were "wrong" and expressed frustration about hallucination and misalignment with actual execution state. The assistant produced structural and project integrity claims without performing corresponding filesystem verification in-session. This violates execution integrity and trust expectations.

### Suggested Action
1. Heartbeat reports must only reference:
   - Direct filesystem reads performed in the same cycle, OR
   - Explicit state confirmed via tool calls.
2. If no verification step is executed, default to silence (no speculative reporting).
3. Add rule: "No narrative state claims without tool-backed verification."
4. Reduce proactive speculation in strategic summaries.

### Metadata
- Source: user_feedback
- Tags: hallucination, heartbeat, verification, trust
- Pattern-Key: harden.no_speculative_state_claims
- Recurrence-Count: 1
- First-Seen: 2026-03-07
- Last-Seen: 2026-03-07

---
## [LRN-20260307-002] correction

**Logged**: 2026-03-07T08:15:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Founder clarified autonomy scope (A,B,C only), reporting style (factual + concise analysis), and escalation thresholds (all defined critical cases).

### Details
Autonomy is limited to:
- Infrastructure maintenance
- Code refactors
- Project file updates

Reporting must be factual with concise analysis (no speculative strategy framing).
Escalation required for revenue risk, infra failure, data loss risk, hard blockers, or major strategic opportunities.

### Suggested Action
Harden operational layer to enforce scope restrictions and adjust reporting tone.

### Metadata
- Source: user_feedback
- Tags: autonomy, reporting, escalation
- Pattern-Key: governance.autonomy_scope_lock
- Recurrence-Count: 1
- First-Seen: 2026-03-07
- Last-Seen: 2026-03-07

---
## [LRN-20260307-003] best_practice

**Logged**: 2026-03-07T13:20:00Z
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Autonomous cron-spawned agentTurn loops can create false sense of continuous execution if not fully wired to deterministic task engine and proper delivery controls.

### Details
CEO Mode Option A was installed with a 1-minute cron job spawning isolated agentTurn runs. However:
- The execution logic inside the burst is still scaffold-level.
- No deterministic atomic step executor exists yet.
- delivery.mode="announce" may spam channel if active tasks produce output each minute.
- No explicit git-state validation or lock mechanism to prevent overlapping bursts.

This means system is architecturally closer to "periodic autonomous trigger" than full employee-grade execution engine.

### Suggested Action
1. Add task-lock file to prevent overlapping bursts.
2. Switch delivery to silent unless milestone.
3. Implement deterministic atomic executor.
4. Add git clean-state check before each burst.

### Metadata
- Source: self-audit
- Tags: autonomy, cron, hardening
- Pattern-Key: harden.autonomous_burst_engine
- Recurrence-Count: 1
- First-Seen: 2026-03-07
- Last-Seen: 2026-03-07

---
