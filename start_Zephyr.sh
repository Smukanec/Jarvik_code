#!/bin/bash

# Wrapper to start Jarvik with the zephyr model
DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/switch_model.sh" "zephyr"
