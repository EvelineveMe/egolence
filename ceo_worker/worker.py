#!/usr/bin/env python3
"""
Standalone CEO Worker
Heartbeat-driven execution loop.
"""

import time
import subprocess
import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOG_DIR = ROOT / "ceo_worker" / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

HEARTBEAT_INTERVAL = 60  # seconds


def utc_now():
    return datetime.datetime.utcnow().isoformat() + "Z"


def log(message: str):
    log_file = LOG_DIR / f"{datetime.date.today().isoformat()}.log"
    with open(log_file, "a") as f:
        f.write(f"[{utc_now()}] {message}\n")


def run_cycle():
    log("Cycle start")
    try:
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
