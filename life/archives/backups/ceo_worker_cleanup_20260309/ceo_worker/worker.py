#!/usr/bin/env python3

import json
import os
import subprocess
import time
from datetime import datetime

TASK_POINTER = 'life/_ceo_active_task.json'
LOG_FILE = 'ceo_worker/logs/worker.log'
LOCK_FILE = 'ceo_worker/worker.lock'

IDLE_INTERVAL = 3
ACTIVE_INTERVAL = 0.5

last_idle_state = False


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


def acquire_lock():
    if os.path.exists(LOCK_FILE):
        return False
    with open(LOCK_FILE, 'w') as f:
        f.write(str(datetime.utcnow()))
    return True


def release_lock():
    if os.path.exists(LOCK_FILE):
        os.remove(LOCK_FILE)


def process_once():
    global last_idle_state

    if not acquire_lock():
        return False

    try:
        task_data = load_task()

        if not task_data or not task_data.get('active'):
            if not last_idle_state:
                log('Idle - no active task.')
                last_idle_state = True
            return False

        last_idle_state = False

        commands = task_data.get('commands')
        single_command = task_data.get('shell_command')

        if commands and isinstance(commands, list) and len(commands) > 0:
            command = commands.pop(0)
            log(f'Executing (chain): {command}')
        elif single_command:
            command = single_command
            log(f'Executing: {command}')
        else:
            log('Active task but no command defined.')
            return False

        code, out, err = execute_shell(command)

        log(f'Exit code: {code}')
        if out:
            log(f'STDOUT: {out.strip()}')
        if err:
            log(f'STDERR: {err.strip()}')

        if code != 0:
            log('Task failed.')
            return False

        # Save updated command list
        if commands and isinstance(commands, list):
            task_data['commands'] = commands
            if len(commands) == 0:
                task_data['active'] = False
                task_data['completed_at'] = datetime.utcnow().isoformat()
                log('Multi-chain task completed.')
        else:
            task_data['active'] = False
            task_data['completed_at'] = datetime.utcnow().isoformat()
            log('Task completed successfully.')

        save_task(task_data)
        return True

    except Exception as e:
        log(f'Unhandled exception: {str(e)}')
        return False
    finally:
        release_lock()


def startup_cleanup():
    if os.path.exists(LOCK_FILE):
        log('Stale lock detected on startup. Removing.')
        os.remove(LOCK_FILE)


def main():
    startup_cleanup()
    log('Worker started.')

    while True:
        executed = False
        try:
            executed = process_once()
        except Exception as loop_error:
            log(f'Loop-level exception: {str(loop_error)}')

        if executed:
            time.sleep(ACTIVE_INTERVAL)
        else:
            time.sleep(IDLE_INTERVAL)


if __name__ == '__main__':
    main()
