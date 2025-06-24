#!/bin/bash
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

cd "$(dirname "$0")" || exit

# Default model name can be overridden via MODEL_NAME
MODEL_NAME=${MODEL_NAME:-mistral}
MODEL_LOG="${MODEL_NAME}.log"

# Ensure ollama is available
if ! command -v ollama >/dev/null 2>&1; then
  echo -e "${RED}❌ Chybí program 'ollama'. Nainstalujte jej a spusťte znovu.${NC}"
  exit 1
fi

# Start Ollama if not running
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

# Pull the requested model if missing
if ! ollama list 2>/dev/null | grep -q "^$MODEL_NAME"; then
  echo -e "${GREEN}⬇️  Stahuji model $MODEL_NAME...${NC}"
  if ! ollama pull "$MODEL_NAME" >> ollama.log 2>&1; then
    echo -e "${RED}❌ Stažení modelu selhalo, zkontrolujte připojení${NC}"
    exit 1
  fi
fi

# Start the model
if ! pgrep -f "ollama run $MODEL_NAME" > /dev/null; then
  echo -e "${GREEN}🧠 Spouštím model $MODEL_NAME...${NC}"
  nohup ollama run "$MODEL_NAME" > "$MODEL_LOG" 2>&1 &
  sleep 2
  if ! pgrep -f "ollama run $MODEL_NAME" > /dev/null; then
    echo -e "${RED}❌ Model $MODEL_NAME se nespustil, zkontrolujte $MODEL_LOG${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}✅ Model $MODEL_NAME již běží${NC}"
fi
