#!/bin/bash

# Wrapper to start Jarvik with the Mistral 7B quantized model
DIR="$(cd "$(dirname "$0")" && pwd)"
# Stop any running instance before launching a new model
bash "$DIR/stop_all.sh"
MODEL_NAME="mistral:7b-Q4_K_M" bash "$DIR/start_jarvik_mistral.sh" "$@"

