#!/bin/bash
# Wrapper to start Jarvik with the Gemma 2B model
DIR="$(cd "$(dirname "$0")" && pwd)"
# Stop any running instance before launching a new model
bash "$DIR/stop_all.sh"
MODEL_NAME="gemma:2b" bash "$DIR/start_jarvik_mistral.sh" "$@"
