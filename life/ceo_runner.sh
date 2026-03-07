#!/bin/bash
TASK_FILE="life/_ceo_active_task.json"

while true; do
  if grep -q '"active": true' "$TASK_FILE" 2>/dev/null; then
    echo "[CEO MODE] Active task detected at $(date -u)"
    # Continuous execution placeholder
    # Real implementation should:
    # 1. Read task
    # 2. Execute next atomic step
    # 3. Update progress
    # 4. Commit
    # 5. Repeat until completion
    sleep 5
  else
    sleep 10
  fi
done
