#!/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# Allow overriding the Flask port
FLASK_PORT=${FLASK_PORT:-8010}

# Determine which model(s) to check
if [ "$#" -gt 0 ]; then
  MODEL_NAMES="$*"
else
  if [ -n "$MODEL_NAMES" ]; then
    :
  elif [ -n "$MODEL_NAME" ]; then
    MODEL_NAMES="$MODEL_NAME"
  else
    DETECTED_MODELS=$(ps -eo args | awk '/^ollama run /{print $3}' | tr '\n' ' ' | sed 's/ *$//')
    if [ -n "$DETECTED_MODELS" ]; then
      MODEL_NAMES="$DETECTED_MODELS"
      if [[ "$DETECTED_MODELS" == *" "* ]]; then
        ACTIVE_MSG="Active models: $DETECTED_MODELS"
      else
        ACTIVE_MSG="Active model: $DETECTED_MODELS"
      fi
    else
      MODEL_NAMES="gemma:2b"
    fi
  fi
fi

echo "🔍 Kontrola systému JARVIK..."
[ -n "$ACTIVE_MSG" ] && echo "$ACTIVE_MSG"

# Ollama
if pgrep -f "ollama serve" > /dev/null; then
  echo -e "✅ Ollama běží"
else
  echo -e "❌ Ollama neběží"
fi

# Model process for each requested model
for MODEL_NAME in $MODEL_NAMES; do
  if pgrep -f -x "ollama run $MODEL_NAME" > /dev/null; then
    echo -e "✅ Model $MODEL_NAME běží"
  else
    echo -e "❌ Model $MODEL_NAME NEběží"
    if command -v ollama >/dev/null 2>&1; then
      # Pokud běží Ollama, ale proces modelu chybí, zkus ověřit port 11434
      if ss -tuln 2>/dev/null | grep -q ":11434" || nc -z localhost 11434 >/dev/null 2>&1; then
        echo "   Ollama běží, ale proces $MODEL_NAME nebyl nalezen."
      fi
      echo "   Spusťte jej příkazem 'ollama run $MODEL_NAME &' nebo 'jarvik-start'."
    else
      echo "   Chybí program 'ollama'."
    fi
  fi
done

# Flask port
if command -v ss >/dev/null 2>&1; then
  ss -tuln | grep -q ":$FLASK_PORT"
  port_check=$?
elif command -v nc >/dev/null 2>&1; then
  nc -z localhost $FLASK_PORT >/dev/null 2>&1
  port_check=$?
else
  port_check=1
fi
if [ "$port_check" = 0 ]; then
  echo -e "✅ Flask běží (port $FLASK_PORT)"
else
  echo -e "❌ Flask (port $FLASK_PORT) neběží"
fi

# Paměť
if [ -f memory/public.jsonl ]; then
  echo -e "✅ Veřejná paměť existuje"
else
  echo -e "❌ Veřejná paměť chybí"
fi

# Znalostní soubory
FILES=$(find knowledge -type f \( -name "*.txt" -o -name "*.pdf" -o -name "*.docx" \))
if [ -n "$FILES" ]; then
  echo -e "✅ Znalostní soubory nalezeny:"
  echo "$FILES" | sed 's/^/   📄 /'
else
  echo -e "❌ Žádné znalostní soubory nenalezeny"
fi
