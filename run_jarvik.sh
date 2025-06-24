#!/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

cd "$(dirname "$0")" || exit

# Aktivuj venv
if [[ -z "$VIRTUAL_ENV" ]]; then
  if [ -f venv/bin/activate ]; then
    source venv/bin/activate
    echo -e "${GREEN}✅ Aktivováno virtuální prostředí JARVIK (venv)${NC}"
  else
    echo -e "${RED}❌ Chybí virtuální prostředí venv/. Spusťte install_jarvik.sh.${NC}"
    exit 1
  fi
fi

# Kontrola potřebných příkazů
for cmd in ollama python3 curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo -e "${RED}❌ Chybí příkaz $cmd. Nainstalujte jej a spusťte znovu.${NC}"
    exit 1
  fi
done

# Spustit Ollama
if ! pgrep -f "ollama serve" > /dev/null; then
  echo -e "${GREEN}🚀 Spouštím Ollama...${NC}"
  nohup ollama serve > ollama.log 2>&1 &
  for i in {1..10}; do
    if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
fi

# Zajistit stažení modelu mistral
if ! ollama list 2>/dev/null | grep -q '^mistral'; then
  echo -e "${GREEN}⬇️  Stahuji model mistral...${NC}"
  ollama pull mistral >> ollama.log 2>&1
fi

# Spustit model mistral, pokud neběží
if ! pgrep -f "ollama run mistral" > /dev/null; then
  echo -e "${GREEN}🧠 Spouštím model mistral...${NC}"
  nohup ollama run mistral > mistral.log 2>&1 &
  sleep 2
fi

# Spustit Flask server
if ! lsof -i :8010 | grep -q LISTEN; then
  echo -e "${GREEN}🌐 Spouštím Flask server na http://localhost:8010 ...${NC}"
  nohup python3 main.py > flask.log 2>&1 &
  sleep 3
fi
