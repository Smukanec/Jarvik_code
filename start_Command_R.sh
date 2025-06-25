#!/bin/bash

# Wrapper to start Jarvik with the command-r model
DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/switch_model.sh" "command-r"
