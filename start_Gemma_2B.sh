#!/bin/bash

# Wrapper to start Jarvik with the Gemma 2B model
DIR="$(cd "$(dirname "$0")" && pwd)"
MODEL_NAME="gemma:2b" bash "$DIR/start_jarvik.sh" "$@"

