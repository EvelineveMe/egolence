#!/usr/bin/env python3

import json
import os
import subprocess
import time
from datetime import datetime

TASK_POINTER = 'life/_ceo_active_task.json'
LOG_FILE = 'ceo_worker/logs/worker.log'
INTERVAL = 3


def log(message):
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    with open(LOG_FILE, 'a') as f:
        f.write(f"{datetime.utcnow().isoformat()} | {message}\n")


def load_task():
    if not os.path.exists(TASK_POINTER):
        return None
    with open(TASK_POINTER, 'r') as f:
        return json.load(f)


def save_task(data):
    with open(TASK_POINTER, 'w') as f:
        json.dump(data, f, indent=2)


def execute_shell(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.returncode, result.stdout, result.stderr


def process_once():
    task_data = load_task()

    if not task_data or not task_data.get('active'):
        log('Idle - no active task.')
        return

    command = task_data.get('shell_command')

    if not command:
        log('Active task but no shell_command defined.')
        return

    log(f'Executing: {command}')
    code, out, err = execute_shell(command)

    log(f'Exit code: {code}')
    if out:
        log(f'STDOUT: {out.strip()}')
    if err:
        log(f'STDERR: {err.strip()}')

    if code == 0:
        task_data['active'] = False
        task_data['completed_at'] = datetime.utcnow().isoformat()
        save_task(task_data)
        log('Task completed successfully.')
    else:
        log('Task failed.')


def main():
    log('Worker started.')
    while True:
        process_once()
        time.sleep(INTERVAL)


if __name__ == '__main__':
    main()
