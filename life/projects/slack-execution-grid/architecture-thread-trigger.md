# Automatic Thread-Trigger Architecture

## Objective
On first message in a new Slack thread:
- Spawn a persistent sub-agent session
- Bind that session to the thread
- Route all future thread messages to that session

## Flow
1. Detect Slack message with thread_ts
2. If no existing session bound to thread_ts:
   - Spawn sub-agent (mode=session, thread=true)
   - Store thread_ts -> session_key mapping
3. Route subsequent messages via mapping

## Guardrails
- Only trigger in allowed channels (eve8-build, eve8-growth, etc.)
- Only trigger when founder posts first message in thread
- Limit concurrent active thread agents to 8

## Next Implementation Steps
1. Add thread mapping registry (in-memory or file-based)
2. Add Slack event hook logic
3. Add spawn logic via sessions_spawn
4. Add cleanup / archive policy
\nGenerated at 2026-03-10T21:53Z
