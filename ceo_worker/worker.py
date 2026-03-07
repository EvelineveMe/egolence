#!/usr/bin/env python3
"""
Standalone CEO Worker v0.1
Single-loop execution engine.
"""

import time
import datetime

class CEOWorker:
    def __init__(self, interval_seconds=60):
        self.interval = interval_seconds
        self.running = False

    def heartbeat(self):
        return {
            "ts": datetime.datetime.utcnow().isoformat() + "Z",
            "status": "alive"
        }

    def execute_cycle(self):
        hb = self.heartbeat()
        print(f"[CEO_WORKER] {hb['ts']} :: {hb['status']}")

    def run(self):
        self.running = True
        while self.running:
            self.execute_cycle()
            time.sleep(self.interval)

if __name__ == "__main__":
    worker = CEOWorker()
    worker.run()
