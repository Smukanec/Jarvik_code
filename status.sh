#!/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# Determine which model(s) to check
if [ "$#" -gt 0 ]; then
  MODEL_NAMES="$*"
else
  if [ -z "$MODEL_NAMES" ] && [ -z "$MODEL_NAME" ]; then
    DETECTED_MODEL=$(pgrep -fa "ollama run" | head -n1 | awk '{for(i=1;i<=NF;i++){if($i=="run"){print $(i+1); exit}}}')
    if [ -n "$DETECTED_MODEL" ]; then
      MODEL_NAMES="$DETECTED_MODEL"
      echo "Active model: $DETECTED_MODEL"
    else
      MODEL_NAMES="gemma:2b"
    fi
  else
    MODEL_NAMES="${MODEL_NAMES:-${MODEL_NAME}}"
  fi
fi

echo "🔍 Kontrola systému JARVIK..."

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

# Flask port 8010
if command -v ss >/dev/null 2>&1; then
  ss -tuln | grep -q ":8010"
  port_check=$?
elif command -v nc >/dev/null 2>&1; then
  nc -z localhost 8010 >/dev/null 2>&1
  port_check=$?
else
  port_check=1
fi
if [ "$port_check" = 0 ]; then
  echo -e "✅ Flask běží (port 8010)"
else
  echo -e "❌ Flask (port 8010) neběží"
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
