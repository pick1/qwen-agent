# ============================================================
#  memory_manager.py — reads and writes the persistent .md files
# ============================================================

import os
from datetime import datetime
from config import MEMORY_FILE, TASKS_FILE, QWEN_FILE, AGENT_DIR


def _ensure_files_exist():
    os.makedirs(AGENT_DIR, exist_ok=True)
    for path, default in [
        (MEMORY_FILE,  "# Memory\n\n## About the User\n- (nothing recorded yet)\n"),
        (TASKS_FILE,   "# Tasks\n\n## Active Tasks\n- (none yet)\n\n## Completed\n- (none yet)\n"),
        (QWEN_FILE,    "# Qwen's Self-Notes\n\n## Reasoning Style\n- Think step by step\n"),
    ]:
        if not os.path.exists(path):
            with open(path, "w") as f:
                f.write(default)


def load_all() -> dict[str, str]:
    """Return the contents of all three .md files."""
    _ensure_files_exist()
    result = {}
    for name, path in [("memory", MEMORY_FILE), ("tasks", TASKS_FILE), ("qwen", QWEN_FILE)]:
        with open(path, "r") as f:
            result[name] = f.read()
    return result


def build_system_prompt(base_prompt: str) -> str:
    """Inject the .md files into a system prompt."""
    files = load_all()
    return f"""{base_prompt}

---

## Your Persistent Memory Files

Below are your three state files. Read them carefully at the start of every session.

### memory.md (facts about the user)
{files['memory']}

### tasks.md (ongoing tasks & follow-ups)
{files['tasks']}

### qwen.md (your own notes & style reminders)
{files['qwen']}

---

At the END of every session (when the user says goodbye, exit, or quit), you MUST:
1. Output updated versions of all three files — only what changed.
2. Use the `update_memory_files` tool to write them to disk.
Do NOT wait to be asked. Always do this before the session closes.
"""


def write_files(memory: str | None = None,
                tasks: str | None = None,
                qwen: str | None = None) -> str:
    """Write updated content to one or more .md files."""
    _ensure_files_exist()
    updated = []
    for name, content, path in [
        ("memory", memory, MEMORY_FILE),
        ("tasks",  tasks,  TASKS_FILE),
        ("qwen",   qwen,   QWEN_FILE),
    ]:
        if content is not None:
            with open(path, "w") as f:
                # Stamp the update time at the top
                stamp = f"<!-- Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M')} -->\n"
                f.write(stamp + content.lstrip())
            updated.append(name)
    return f"Updated: {', '.join(updated)}" if updated else "Nothing to update."
