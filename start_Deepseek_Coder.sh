#!/bin/bash

# Wrapper to start Jarvik with the deepseek-coder model
DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/switch_model.sh" "deepseek-coder"
