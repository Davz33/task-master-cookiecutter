#!/usr/bin/env python3
"""
Real-time taskmaster list watcher - only refreshes when tasks.json changes.
Provides smooth, streaming-like updates without flicker.
"""
import os
import sys
import time
import subprocess
import signal
from pathlib import Path

TASKS_FILE = Path(os.getenv("TASKMASTER_TASKS_FILE", ".taskmaster/tasks/tasks.json"))

def get_mtime():
    """Get file modification time."""
    try:
        return TASKS_FILE.stat().st_mtime
    except (OSError, FileNotFoundError):
        return 0

def run_taskmaster_list():
    """Run task-master list and return output."""
    try:
        result = subprocess.run(
            ["task-master", "list"],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        return f"Error: {e}\n"

def main():
    import shutil
    
    # Check if task-master is available
    if not shutil.which("task-master"):
        print("Error: task-master command not found", file=sys.stderr)
        sys.exit(1)
    
    # Check if tasks file exists
    if not TASKS_FILE.exists():
        print(f"Error: Tasks file not found at {TASKS_FILE}", file=sys.stderr)
        print("Make sure taskmaster is initialized in this directory", file=sys.stderr)
        sys.exit(1)
    
    # Handle Ctrl+C gracefully
    def signal_handler(sig, frame):
        print("\n\nStopped watching taskmaster list.")
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    
    # Print header once
    print("=== Taskmaster List (watching for changes, Ctrl+C to stop) ===")
    print("")
    
    last_mtime = get_mtime()
    first_run = True
    
    while True:
        current_mtime = get_mtime()
        
        # Only refresh if file has changed or it's the first run
        if current_mtime != last_mtime or first_run:
            # Clear screen and move to top for smooth update
            sys.stdout.write("\033[2J\033[H")
            sys.stdout.flush()
            
            # Print header
            print("=== Taskmaster List (watching for changes, Ctrl+C to stop) ===")
            timestamp = time.strftime("%H:%M:%S")
            print(f"Last updated: {timestamp}")
            print("")
            
            # Get and display task list
            output = run_taskmaster_list()
            sys.stdout.write(output)
            sys.stdout.flush()
            
            last_mtime = current_mtime
            first_run = False
        
        # Check every 0.05 seconds for very responsive updates
        time.sleep(0.05)

if __name__ == "__main__":
    main()

