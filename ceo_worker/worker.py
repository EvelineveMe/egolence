#!/usr/bin/env python3
"""
Standalone CEO Worker
Heartbeat-driven execution loop with task runner.
"""

import time
import subprocess
import datetime
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOG_DIR = ROOT / "ceo_worker" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

HEARTBEAT_INTERVAL = 60  # seconds
TASK_FILE = ROOT / "ceo_worker" / "tasks.json"


def utc_now():
    return datetime.datetime.utcnow().isoformat() + "Z"


def log(message: str):
    log_file = LOG_DIR / f"{datetime.date.today().isoformat()}.log"
    with open(log_file, "a") as f:
        f.write(f"[{utc_now()}] {message}\n")


def execute_tasks():
    if not TASK_FILE.exists():
        return

    try:
        with open(TASK_FILE, "r") as f:
            data = json.load(f)
    except Exception as e:
        log(f"Task load error: {e}")
        return

    tasks = data.get("tasks", [])
    updated = False

    for task in tasks:
        if task.get("status") == "pending":
            cmd = task.get("command")
            if not cmd:
                continue
            log(f"Executing task: {cmd}")
            try:
                subprocess.run(cmd, shell=True, cwd=ROOT)
                task["status"] = "done"
                task["completed_at"] = utc_now()
                updated = True
            except Exception as e:
                log(f"Task execution error: {e}")

    if updated:
        with open(TASK_FILE, "w") as f:
            json.dump(data, f, indent=2)


def run_cycle():
    log("Cycle start")
    try:
        execute_tasks()
        subprocess.run(["git", "add", "-A"], cwd=ROOT)
        subprocess.run(
            ["git", "commit", "-m", f"ceo_worker: auto-commit {utc_now()}"],
            cwd=ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception as e:
        log(f"Error: {e}")
    log("Cycle end")


def main():
    log("CEO worker boot")
    while True:
        run_cycle()
        time.sleep(HEARTBEAT_INTERVAL)


if __name__ == "__main__":
    main()
