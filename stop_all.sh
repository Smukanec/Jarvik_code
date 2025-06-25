#!/bin/bash
# Stop all Jarvik-related processes
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR" || exit

echo "⛔ Stopping running Jarvik processes..."

pkill -f "ollama serve" 2>/dev/null && echo "Stopped ollama serve" || true
pkill -f "ollama run" 2>/dev/null && echo "Stopped running Ollama models" || true
pkill -f "python3 main.py" 2>/dev/null && echo "Stopped Flask" || true

