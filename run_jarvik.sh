#!/bin/bash

GREEN='\033[1;32m'
NC='\033[0m'

cd "$(dirname "$0")" || exit

# Aktivuj venv
if [[ -z "$VIRTUAL_ENV" ]]; then
  source venv/bin/activate
  echo -e "${GREEN}✅ Aktivováno virtuální prostředí JARVIK (venv)${NC}"
fi

# Spustit Ollama
if ! pgrep -f "ollama serve" > /dev/null; then
  echo -e "${GREEN}🚀 Spouštím Ollama...${NC}"
  nohup ollama serve > /dev/null 2>&1 &
  sleep 3
fi

# Spustit model mistral, pokud neběží
if ! curl -s http://localhost:11434/api/tags | grep -q '"name":"mistral"'; then
  echo -e "${GREEN}🧠 Spouštím model mistral...${NC}"
  nohup ollama run mistral > /dev/null 2>&1 &
  sleep 2
fi

# Spustit Flask server
if ! lsof -i :8010 | grep -q LISTEN; then
  echo -e "${GREEN}🌐 Spouštím Flask server na http://localhost:8010 ...${NC}"
  nohup python3 main.py > flask.log 2>&1 &
  sleep 3
fi
