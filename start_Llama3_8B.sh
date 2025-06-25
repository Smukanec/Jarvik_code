#!/bin/bash

# Wrapper to start Jarvik with the llama3:8b model
DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/switch_model.sh" "llama3:8b"
