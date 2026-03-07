#!/usr/bin/env python3
"""
Standalone CEO Worker v0.2
Single-loop execution engine with persistent logging.
"""

import time
import datetime
import json
import os

class CEOWorker:
    def __init__(self, interval_seconds=60):
        self.interval = interval_seconds
        self.running = False
        self.log_dir = os.path.join(os.path.dirname(__file__), "logs")
        self.log_file = os.path.join(self.log_dir, "worker.log")
        os.makedirs(self.log_dir, exist_ok=True)

    def heartbeat(self):
        return {
            "ts": datetime.datetime.utcnow().isoformat() + "Z",
            "status": "alive"
        }

    def persist(self, payload: dict):
        with open(self.log_file, "a") as f:
            f.write(json.dumps(payload) + "\n")

    def execute_cycle(self):
        hb = self.heartbeat()
        print(f"[CEO_WORKER] {hb['ts']} :: {hb['status']}")
        self.persist(hb)

    def run(self):
        self.running = True
        while self.running:
            self.execute_cycle()
            time.sleep(self.interval)

if __name__ == "__main__":
    worker = CEOWorker()
    worker.run()
