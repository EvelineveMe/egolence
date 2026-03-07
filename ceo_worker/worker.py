import json
import os
from datetime import datetime, timezone

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TASKS_FILE = os.path.join(BASE_DIR, "tasks.json")
STATE_FILE = os.path.join(BASE_DIR, "state.json")
LOG_DIR = os.path.join(BASE_DIR, "logs")

os.makedirs(LOG_DIR, exist_ok=True)


def load_json(path, default):
    if not os.path.exists(path):
        return default
    with open(path, "r") as f:
        return json.load(f)


def save_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2)


def log(message):
    ts = datetime.now(timezone.utc).isoformat()
    line = f"[{ts}] {message}\n"
    logfile = os.path.join(LOG_DIR, "worker.log")
    with open(logfile, "a") as f:
        f.write(line)


def run_once():
    tasks = load_json(TASKS_FILE, [])
    state = load_json(STATE_FILE, {"last_run": None, "completed_tasks": []})

    now = datetime.now(timezone.utc).isoformat()
    state["last_run"] = now

    for task in tasks:
        task_id = task.get("id")
        if task_id in state["completed_tasks"]:
            continue

        # Placeholder execution hook
        log(f"Executing task: {task_id}")

        state["completed_tasks"].append(task_id)

    save_json(STATE_FILE, state)
    log("Run complete")


if __name__ == "__main__":
    run_once()
