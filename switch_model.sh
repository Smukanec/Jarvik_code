#!/bin/bash
# Helper to switch models by restarting all components

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR" || exit

NEW_MODEL="$1"
if [ -z "$NEW_MODEL" ]; then
  echo "Usage: $0 <model_name>" >&2
  exit 1
fi

echo "🔄 Switching to model $NEW_MODEL..."

# Stop running services
pkill -f "python3 main.py" 2>/dev/null
pkill -f "ollama run" 2>/dev/null
pkill -f "ollama serve" 2>/dev/null
sleep 2

MODEL_NAME="$NEW_MODEL" bash "$DIR/start_jarvik_mistral.sh"
