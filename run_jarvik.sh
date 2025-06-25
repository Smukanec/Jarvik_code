#!/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

cd "$(dirname "$0")" || exit

# Default model name can be overridden via MODEL_NAME
MODEL_NAME=${MODEL_NAME:-mistral}
# Log file for the running model
MODEL_LOG="${MODEL_NAME}.log"

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
for cmd in ollama python3 curl lsof; do
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
  if ! curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo -e "${RED}❌ Ollama se nespustila, zkontrolujte ollama.log${NC}"
    exit 1
  fi
fi

# Zajistit stažení modelu
if ! ollama list 2>/dev/null | grep -q "^$MODEL_NAME"; then
  echo -e "${GREEN}⬇️  Stahuji model $MODEL_NAME...${NC}"
  if ! ollama pull "$MODEL_NAME" >> ollama.log 2>&1; then
    echo -e "${RED}❌ Stažení modelu selhalo, zkontrolujte připojení${NC}"
    exit 1
  fi
fi

# Spustit model, pokud neběží
if ! pgrep -f "ollama run $MODEL_NAME" > /dev/null; then
  echo -e "${GREEN}🧠 Spouštím model $MODEL_NAME...${NC}"
  nohup ollama run "$MODEL_NAME" > "$MODEL_LOG" 2>&1 &
  sleep 2
  if ! pgrep -f "ollama run $MODEL_NAME" > /dev/null; then
    echo -e "${RED}❌ Model $MODEL_NAME se nespustil, zkontrolujte $MODEL_LOG${NC}"
    exit 1
  fi
fi

# Spustit Flask server
if ! lsof -i :8010 | grep -q LISTEN; then
  echo -e "${GREEN}🌐 Spouštím Flask server na http://localhost:8010 ...${NC}"
  nohup python3 main.py > flask.log 2>&1 &
  sleep 2
  if ! lsof -i :8010 | grep -q LISTEN; then
    echo -e "${RED}❌ Flask se nespustil, zkontrolujte flask.log${NC}"
    exit 1
  fi
  echo -e "${GREEN}✅ Jarvik běží na http://localhost:8010${NC}"
fi
