#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR" || exit
set -e
MODEL_NAME=${MODEL_NAME:-jarvik-mistral}

echo "🗑️ Odinstalace Jarvika..."

# Kill running processes
pkill -f "ollama serve" 2>/dev/null && echo "Zastaven ollama serve" || true
pkill -f "ollama run $MODEL_NAME" 2>/dev/null && echo "Zastaven $MODEL_NAME" || true
pkill -f "python3 main.py" 2>/dev/null && echo "Zastaven Flask" || true

# Remove directories and logs
rm -rf venv memory
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
rm -f *.log

# Remove aliases from ~/.bashrc
sed -i '/# 🚀 Alias příkazy pro JARVIK/,+6d' ~/.bashrc

echo "✅ Jarvik odstraněn."
