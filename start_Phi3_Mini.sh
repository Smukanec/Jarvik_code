#!/bin/bash

# Wrapper to start Jarvik with the phi3:mini model
DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/switch_model.sh" "phi3:mini"
