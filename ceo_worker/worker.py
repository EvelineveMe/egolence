#!/usr/bin/env python3
"""
Standalone CEO Worker v0.3
Adds simple task queue execution with persistent state.
"""

import time
import datetime
import json
import os

class CEOWorker:
    def __init__(self, interval_seconds=60):
        self.interval = interval_seconds
        self.running = False
        base_dir = os.path.dirname(__file__)
        self.log_dir = os.path.join(base_dir, "logs")
        self.log_file = os.path.join(self.log_dir, "worker.log")
        self.task_file = os.path.join(base_dir, "tasks.json")
        os.makedirs(self.log_dir, exist_ok=True)

    def heartbeat(self):
        return {
            "ts": datetime.datetime.utcnow().isoformat() + "Z",
            "status": "alive"
        }

    def persist(self, payload: dict):
        with open(self.log_file, "a") as f:
            f.write(json.dumps(payload) + "\n")

    def load_tasks(self):
        if not os.path.exists(self.task_file):
            return []
        with open(self.task_file, "r") as f:
            return json.load(f)

    def save_tasks(self, tasks):
        with open(self.task_file, "w") as f:
            json.dump(tasks, f, indent=2)

    def get_next_task(self, tasks):
        for task in tasks:
            if not task.get("done"):
                return task
        return None

    def mark_task_done(self, tasks, task_id):
        for task in tasks:
            if task.get("id") == task_id:
                task["done"] = True
                break

    def execute_cycle(self):
        hb = self.heartbeat()
        tasks = self.load_tasks()
        next_task = self.get_next_task(tasks)

        payload = {
            "heartbeat": hb,
            "next_task": next_task.get("id") if next_task else None
        }

        print(f"[CEO_WORKER] {hb['ts']} :: alive :: next={payload['next_task']}")
        self.persist(payload)

        if next_task:
            self.mark_task_done(tasks, next_task.get("id"))
            self.save_tasks(tasks)

    def run(self):
        self.running = True
        while self.running:
            self.execute_cycle()
            time.sleep(self.interval)

if __name__ == "__main__":
    worker = CEOWorker()
    worker.run()
