# Telegram Approval Loop — Architecture v1

## Overview
Implements parallel preview branches with serialized production merges.

## State Machine
CREATED
PREVIEW_DEPLOYED
AWAITING_APPROVAL
APPROVED
REJECTED
MERGED
DONE
FAILED
CONFLICT

## Phases
1. phase1_buildPreview(task)
2. phase3_finalize(task)

## Parallelism
- Multiple tasks may reach AWAITING_APPROVAL
- Single serialized merge worker processes APPROVED tasks

## Merge Logic
- Auto-rebase onto latest main
- On clean rebase → merge → deploy → DONE
- On conflict → abort → CONFLICT + notify

## Telegram Integration
- Send screenshot + preview URL
- Inline buttons: approve:<task_id> / reject:<task_id>
- Callback handler transitions state and enqueues merge or cleanup

## Constraints
- Restart-safe (state-driven)
- Idempotent transitions
- No silent failure
