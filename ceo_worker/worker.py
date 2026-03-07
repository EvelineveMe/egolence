import json
import time
import os

TASK_POINTER = 'life/_ceo_active_task.json'

print('[CEO WORKER] Starting...')

while True:
    if not os.path.exists(TASK_POINTER):
        time.sleep(5)
        continue

    with open(TASK_POINTER, 'r') as f:
        try:
            data = json.load(f)
        except:
            time.sleep(5)
            continue

    if not data.get('active'):
        time.sleep(5)
        continue

    project = data.get('project')
    task = data.get('task')

    print(f"[CEO WORKER] Active task detected: {task} (project: {project})")

    # Placeholder execution loop
    # Real implementation will:
    # 1. Load project state
    # 2. Plan next atomic step via model
    # 3. Execute
    # 4. Commit
    # 5. Update state

    time.sleep(5)
