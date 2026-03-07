---
name: ceo-mode
description: Persistent continuous execution mode. Executes defined tasks until completion or blocker without waiting for user prompts.
---

# CEO Mode

## Definition
When activated, the agent:
- Enters continuous execution loop
- Executes defined task step-by-step
- Commits progress incrementally
- Stops only on completion or real blocker
- Does not wait for additional user prompts

## Activation Phrase
"Lock CEO mode"

## Behavior
1. Require explicit task definition.
2. Define completion criteria.
3. Enter execution loop.
4. Execute atomic steps continuously.
5. Commit progress with git after milestones.
6. Report only when milestone reached or blocked.

## Persistence
If gateway restarts:
- Re-check for active CEO task marker file.
- Resume execution if task incomplete.

## Task Marker
Use file: life/_ceo_active_task.json
Contains:
- task description
- completion criteria
- last step completed

If file exists at startup → resume.

