#!/bin/bash

# Continuous status and log viewer for Jarvik

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR" || exit

while true; do
  clear
  echo "===== Stav Jarvika ====="
  bash status.sh
  echo

  if [ -f flask.log ]; then
    echo "--- Poslední logy Flasku ---"
    tail -n 5 flask.log
    echo
  else
    echo "(Žádný flask.log)"
    echo
  fi

  if [ -f mistral.log ]; then
    echo "--- Poslední logy Mistralu ---"
    tail -n 5 mistral.log
    echo
  else
    echo "(Žádný mistral.log)"
    echo
  fi

  if [ -f ollama.log ]; then
    echo "--- Poslední logy Ollamy ---"
    tail -n 5 ollama.log
    echo
  else
    echo "(Žádný ollama.log)"
    echo
  fi

  sleep 2
done
