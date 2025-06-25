#!/bin/bash

# Wrapper to start Jarvik with the Jarvik Q4 quantized model
DIR="$(cd "$(dirname "$0")" && pwd)"
# Stop any running instance before starting a new one
bash "$DIR/stop_all.sh"
MODEL_NAME="jarvik-q4" bash "$DIR/start_jarvik.sh" "$@"

