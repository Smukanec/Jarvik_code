#!/bin/bash

# Wrapper to start Jarvik with the Gemma 2B model
DIR="$(cd "$(dirname "$0")" && pwd)"
# Stop any running instance before starting a new one
bash "$DIR/stop_all.sh"
MODEL_NAME="gemma:2b" bash "$DIR/start_jarvik.sh" "$@"

