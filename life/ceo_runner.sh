#!/bin/bash
TASK_FILE="life/_ceo_active_task.json"
if grep -q '"active": true' "$TASK_FILE" 2>/dev/null; then
  echo "[CEO MODE] Active task detected at $(date -u)"
  # Placeholder for execution engine hook
  # In full implementation, this would trigger build steps
fi
