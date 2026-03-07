import json
import subprocess
import time
from pathlib import Path

TASK_FILE = Path(__file__).parent / 'tasks.json'
LOG_DIR = Path(__file__).parent / 'logs'
LOG_DIR.mkdir(exist_ok=True)


def load_tasks():
    if not TASK_FILE.exists():
        return []
    with open(TASK_FILE, 'r') as f:
        return json.load(f)


def save_tasks(tasks):
    with open(TASK_FILE, 'w') as f:
        json.dump(tasks, f, indent=2)


def execute_task(task):
    ts = int(time.time())
    log_file = LOG_DIR / ftask_{ts}.log
    with open(log_file, 'w') as log:
        process = subprocess.Popen(task['command'], shell=True, stdout=log, stderr=log)
        process.wait()
    return process.returncode


def main():
    tasks = load_tasks()
    updated = []
    for task in tasks:
        if task.get('status') == 'pending':
            rc = execute_task(task)
            task['status'] = 'done' if rc == 0 else 'failed'
            task['exit_code'] = rc
        updated.append(task)
    save_tasks(updated)


if __name__ == '__main__':
    main()
