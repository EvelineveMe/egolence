# Executor Control Layer

## Goal
Upgrade existing VPS worker into approval-gated, merge-controlled autonomous deployment system.

## Definition of Done
- Structured mutation engine
- AWAITING_APPROVAL state
- Telegram approval callback
- Serialized merge queue
- Conflict detection + auto-rebase
- Execution logging layer

## Constraints
- Must evolve existing runner.py (no rebuild)
- Must not break current preview flow
- Must preserve isolation under /home/executor

## Current Status
Worker running and functional (preview + proof).
Approval + merge orchestration not implemented.

## Decisions
2026-03-10 — Evolve existing worker instead of rebuild.

## Next Actions
1. Introduce state machine into runner.py
2. Replace hardcoded mutation with structured payload
3. Add AWAITING_APPROVAL pause
4. Implement merge phase
5. Add execution logging

## Open Questions
- Telegram integration strategy (direct vs relay)

## Links / Assets
- VPS: 209.38.208.21
- Runner: /home/executor/executor/runner.py
