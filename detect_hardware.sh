#!/bin/bash
# ============================================================
#  detect_hardware.sh — recommends the best Qwen model for
#  your machine, then optionally pulls it via Ollama
# ============================================================

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     Qwen Agent — Hardware Detector       ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── GPU ─────────────────────────────────────────────────────
GPU_NAME=""
GPU_VRAM_MB=0

if command -v nvidia-smi &>/dev/null; then
  GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
  GPU_VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
  echo "🎮 GPU : $GPU_NAME"
  echo "   VRAM: ${GPU_VRAM_MB} MiB ($(( GPU_VRAM_MB / 1024 )) GB)"
else
  echo "🎮 GPU : None detected (CPU-only mode)"
fi

# ── RAM ─────────────────────────────────────────────────────
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_GB=$(( TOTAL_RAM_KB / 1024 / 1024 ))
echo "🧠 RAM : ${TOTAL_RAM_GB} GB"

# ── CPU ─────────────────────────────────────────────────────
CPU_NAME=$(lscpu | grep "Model name" | sed 's/Model name:[ ]*//')
CPU_CORES=$(nproc)
echo "⚙️  CPU : $CPU_NAME"
echo "   Cores: $CPU_CORES"

# ── Ollama models already pulled ────────────────────────────
echo ""
echo "📦 Ollama models already on disk:"
ollama list 2>/dev/null || echo "   (Ollama not running — start with: ollama serve)"

# ── Recommendation logic ─────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║           Model Recommendation           ║"
echo "╚══════════════════════════════════════════╝"

RECOMMENDED=""
REASON=""

if [ "$GPU_VRAM_MB" -ge 20000 ] 2>/dev/null; then
  RECOMMENDED="qwen3:32b"
  REASON="32 GB+ VRAM — runs 32B fully on GPU, fast"
elif [ "$GPU_VRAM_MB" -ge 12000 ] 2>/dev/null; then
  RECOMMENDED="qwen3:14b"
  REASON="12–20 GB VRAM — 14B fits comfortably on GPU"
elif [ "$GPU_VRAM_MB" -ge 6000 ] 2>/dev/null; then
  RECOMMENDED="qwen3:8b"
  REASON="6–12 GB VRAM — 8B fits on GPU with room to spare"
elif [ "$TOTAL_RAM_GB" -ge 32 ]; then
  RECOMMENDED="qwen3:14b"
  REASON="32+ GB RAM — 14B runs well CPU-only (will be slower)"
elif [ "$TOTAL_RAM_GB" -ge 16 ]; then
  RECOMMENDED="qwen3:8b"
  REASON="16–32 GB RAM — 8B is the sweet spot for CPU-only"
elif [ "$TOTAL_RAM_GB" -ge 8 ]; then
  RECOMMENDED="qwen3:4b"
  REASON="8–16 GB RAM — 4B keeps headroom for other processes"
else
  RECOMMENDED="qwen2.5:1.5b"
  REASON="<8 GB RAM — lightweight model, limited capability"
fi

echo ""
echo "  ✅ Recommended : $RECOMMENDED"
echo "  💡 Reason      : $REASON"
echo ""

# ── Offer to pull ────────────────────────────────────────────
read -p "Pull $RECOMMENDED now? (y/n): " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Pulling $RECOMMENDED ..."
  ollama pull "$RECOMMENDED"
  echo ""
  echo "Done! Update MODEL in config.py:"
  echo "  MODEL = \"$RECOMMENDED\""
else
  echo ""
  echo "When ready, run:  ollama pull $RECOMMENDED"
  echo "Then set in config.py:  MODEL = \"$RECOMMENDED\""
fi

echo ""
