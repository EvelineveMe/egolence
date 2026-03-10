# Executor Autonomy

## Goal
Consolidate infrastructure + control layer into a single autonomous, approval-gated deployment system running under isolated executor user.

## Definition of Done
- Running worker daemon
- Structured mutation engine
- AWAITING_APPROVAL state
- Telegram approval callback
- Serialized merge queue
- Conflict detection + auto-rebase
- Execution logging layer
- Fully documented access + architecture

## Constraints
- Must evolve existing runner.py
- Must preserve VPS isolation model
- No password-based SSH

## Current Status
Worker running.
SSH key access stabilized.
Approval + merge layer pending.

## Decisions
2026-03-10 — Merge executor-infrastructure + executor-control-layer into single canonical project: executor-autonomy.

## Next Actions
1. Register project in index + active registry
2. Archive partial projects
3. Implement state machine
4. Implement approval gate
5. Implement merge phase
6. Install execution logging

## Open Questions
- Telegram integration path (direct bot vs relay)

## Links / Assets
- VPS: 209.38.208.21
- Runner: /home/executor/executor/runner.py
