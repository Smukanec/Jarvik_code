#!/bin/bash

# Wrapper to start Jarvik with the nous-hermes2 model
DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/switch_model.sh" "nous-hermes2"
