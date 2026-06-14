from __future__ import annotations
import json
import os
import uuid
from datetime import datetime
from typing import List, Optional
from models import Task

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
TASKS_FILE = os.path.join(DATA_DIR, "tasks.json")


def _ensure_data_dir():
    os.makedirs(DATA_DIR, exist_ok=True)


def _load_raw() -> list:
    _ensure_data_dir()
    if not os.path.exists(TASKS_FILE):
        return []
    try:
        with open(TASKS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError):
        return []


def _save_raw(tasks: list):
    _ensure_data_dir()
    with open(TASKS_FILE, "w", encoding="utf-8") as f:
        json.dump(tasks, f, ensure_ascii=False, indent=2)


def load_tasks() -> List[Task]:
    return [Task.from_dict(item) for item in _load_raw()]


def save_tasks(tasks: List[Task]):
    _save_raw([t.to_dict() for t in tasks])


def create_task(task: Task) -> Task:
    tasks = load_tasks()
    task.id = str(uuid.uuid4())[:8]
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    task.created_at = now
    task.updated_at = now
    tasks.append(task)
    save_tasks(tasks)
    return task


def update_task(updated: Task) -> Optional[Task]:
    tasks = load_tasks()
    for i, t in enumerate(tasks):
        if t.id == updated.id:
            updated.updated_at = datetime.now().strftime("%Y-%m-%d %H:%M")
            tasks[i] = updated
            save_tasks(tasks)
            return updated
    return None


def delete_task(task_id: str) -> bool:
    tasks = load_tasks()
    new_tasks = [t for t in tasks if t.id != task_id]
    if len(new_tasks) == len(tasks):
        return False
    save_tasks(new_tasks)
    return True


def get_task(task_id: str) -> Optional[Task]:
    tasks = load_tasks()
    for t in tasks:
        if t.id == task_id:
            return t
    return None
