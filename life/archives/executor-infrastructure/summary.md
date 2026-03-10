# Executor Infrastructure

## Goal
Build a deterministic, parallel-preview, human-gated production deployment system.

## Definition of Done
- Parallel preview branches
- Telegram approval loop
- Serialized production merges
- Auto-rebase with conflict detection
- Restart-safe state machine

## Constraints
- Executor runs on VPS (external to workspace)
- Must remain idempotent
- No silent failures

## Current Status
Infrastructure built on VPS.
Approval loop not yet implemented.

## Decisions
2026-03-09 — Executor runs on VPS, not inside workspace.
2026-03-09 — Parallel previews + serialized merge chosen.
2026-03-09 — Auto-rebase with conflict detection selected.

## Next Actions
1. Document VPS path + repo location
2. Audit executor code on VPS
3. Implement state machine
4. Implement Telegram callback handler
5. Implement serialized merge worker

## Open Questions
- Exact VPS repo path?
- Current mutation logic implementation details?

## Links / Assets
- VPS IP: 209.38.208.21
