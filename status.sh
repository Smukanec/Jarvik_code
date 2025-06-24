#!/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo "🔍 Kontrola systému JARVIK..."

# Ollama
if pgrep -f "ollama serve" > /dev/null; then
  echo -e "✅ Ollama běží"
else
  echo -e "❌ Ollama neběží"
fi

# Mistral
if pgrep -f "ollama run mistral" > /dev/null; then
  echo -e "✅ Model Mistral běží"
else
  echo -e "❌ Model Mistral NEběží"
  if command -v ollama >/dev/null 2>&1; then
    echo "   Spusťte jej příkazem 'ollama run mistral &' nebo 'jarvik-start'."
  else
    echo "   Chybí program 'ollama'."
  fi
fi

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
