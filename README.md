# Qwen Agent

A local AI agent powered by Qwen (via Ollama) with persistent markdown memory files.

## File Structure

```
~/projects/qwen-agent/
├── agent.py            ← main entry point
├── config.py           ← model & path settings
├── memory_manager.py   ← reads/writes .md files
├── tools.py            ← all agent tools
├── requirements.txt
├── detect_hardware.sh  ← run this first!
│
├── memory.md           ← Qwen's memory about you  (auto-updated)
├── tasks.md            ← ongoing tasks            (auto-updated)
└── qwen.md             ← Qwen's self-notes        (auto-updated)
```

## Setup

### 1. Detect your hardware & pick a model
```bash
chmod +x detect_hardware.sh
./detect_hardware.sh
```
This recommends the best Qwen model for your RAM/GPU and optionally pulls it.

### 2. Update config (if needed)
Edit `config.py` and set `MODEL` to match what you pulled:
```python
MODEL = "qwen3:8b"   # or whichever was recommended
```

### 3. Create a virtual environment
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 4. Make sure Ollama is running
```bash
ollama serve &   # if not already running as a service
```

### 5. Start the agent
```bash
python agent.py
```

## How Memory Works

| File | Purpose |
|------|---------|
| `memory.md` | Facts Qwen learns about you — preferences, context, key info |
| `tasks.md`  | Active tasks, todos, follow-ups between sessions |
| `qwen.md`   | Qwen's own style notes and reasoning reminders |

These files are:
- **Read at startup** — injected into the system prompt so Qwen starts with full context
- **Written at session end** — when you say `exit`, `quit`, or `bye`, Qwen reviews the session and updates all three files automatically

You can also edit them manually at any time — they're just markdown.

## Tools Available

| Tool | What it does |
|------|-------------|
| `update_memory_files` | Writes to memory.md / tasks.md / qwen.md |
| `read_file` | Read any file from disk |
| `write_file` | Write/create a file |
| `list_directory` | List directory contents |
| `shell` | Run shell commands |
| `web_search` | DuckDuckGo search (requires `duckduckgo-search`) |

## Customising

- **Add tools**: Add a `@tool` function in `tools.py` and append it to `ALL_TOOLS`
- **Change personality**: Edit `BASE_PROMPT` in `agent.py`
- **Quiet mode**: Set `verbose=False` in the `AgentExecutor` in `agent.py`
- **Override model at runtime**: `QWEN_MODEL=qwen3:14b python agent.py`
