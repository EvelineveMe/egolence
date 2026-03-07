import json
import time
import os
from datetime import datetime

TASK_POINTER = 'life/_ceo_active_task.json'
LOCK_FILE = 'ceo_worker/worker.lock'
LOG_FILE = 'ceo_worker/logs/worker.log'

print('[CEO WORKER] Starting...')

while True:
    if os.path.exists(LOCK_FILE):
        time.sleep(2)
        continue

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

    # Acquire lock
    with open(LOCK_FILE, 'w') as lf:
        lf.write(str(datetime.utcnow()))

    project = data.get('project')
    task = data.get('task')

    print(f"[CEO WORKER] Executing task: {task} (project: {project})")

    # Deterministic execution stub
    result = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "project": project,
        "task": task,
        "status": "completed"
    }

    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    with open(LOG_FILE, 'a') as log:
        log.write(json.dumps(result) + "\n")

    # Mark task inactive
    data['active'] = False
    data['last_completed_at'] = result["timestamp"]

    with open(TASK_POINTER, 'w') as f:
        json.dump(data, f, indent=2)

    # Release lock
    if os.path.exists(LOCK_FILE):
        os.remove(LOCK_FILE)

    time.sleep(2)
