# STARTUP_STRATEGY_GATE.md

## Mandatory Morning Reconstruction Protocol

At the start of every main session and every scheduled autonomy heartbeat:

The system MUST load and review the following files before performing any execution:

1. life/projects/_active.json
2. life/projects/<active_slug>/strategy.md
3. life/projects/<active_slug>/summary.md
4. life/projects/<active_slug>/items.json (active facts only)
5. memory/_live_journal.md (current day)
6. memory/YYYY-MM-DD.md (yesterday)

No build, mutation, or strategic action is allowed before this read sequence completes.

If strategy.md is missing or incomplete → abort execution.

This protocol prevents strategic drift and Groundhog Day resets.
