#!/bin/bash

# Wrapper to start Jarvik with the Jarvik Q4 quantized model
DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_NAME="jarvik-q4" bash "$DIR/start_jarvik_mistral.sh" "$@"

