#!/bin/bash
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

cd "$(dirname "$0")" || exit

# Model name can be overridden with the MODEL_NAME environment variable
MODEL_NAME=${MODEL_NAME:-mistral}
# Log file for the model output
MODEL_LOG="${MODEL_NAME}.log"

# Aktivovat venv, pokud ještě není aktivní
if [ -z "$VIRTUAL_ENV" ]; then
  if [ -f venv/bin/activate ]; then
    source venv/bin/activate
    echo -e "${GREEN}✅ Aktivováno virtuální prostředí${NC}"
  else
    echo -e "${RED}❌ Chybí virtuální prostředí venv/. Spusťte install_jarvik.sh.${NC}"
    exit 1
  fi
fi

# Zkontrolovat dostupnost příkazů
for cmd in ollama python3 curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo -e "${RED}❌ Chybí příkaz $cmd. Nainstalujte jej a spusťte znovu.${NC}"
    exit 1
  fi
done

# Potřebujeme také 'ss' nebo 'nc' pro kontrolu běžících portů
if ! command -v ss >/dev/null 2>&1 && ! command -v nc >/dev/null 2>&1; then
  echo -e "${RED}❌ Chybí příkazy 'ss' i 'nc'. Nainstalujte balíček iproute2 nebo netcat.${NC}"
  exit 1
fi

# Spustit Ollama, pokud neběží
if ! pgrep -f "ollama serve" > /dev/null; then
  echo -e "${GREEN}🚀 Spouštím Ollama...${NC}"
  nohup ollama serve > ollama.log 2>&1 &
  # Počkej na zpřístupnění API
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

# Ověřit dostupnost modelu $MODEL_NAME a případně jej stáhnout
if ! ollama list 2>/dev/null | grep -q "^${MODEL_NAME}"; then
  echo -e "${GREEN}⬇️  Stahuji model $MODEL_NAME...${NC}"
  if ! ollama pull "$MODEL_NAME" >> ollama.log 2>&1; then
    echo -e "${RED}❌ Stažení modelu selhalo, zkontrolujte připojení${NC}"
    exit 1
  fi
fi

# Spustit $MODEL_NAME, pokud neběží
if ! pgrep -f -x "ollama run $MODEL_NAME" > /dev/null; then
  echo -e "${GREEN}🧠 Spouštím model $MODEL_NAME...${NC}"
  nohup ollama run "$MODEL_NAME" > "$MODEL_LOG" 2>&1 &
  sleep 2
  if ! pgrep -f -x "ollama run $MODEL_NAME" > /dev/null; then
    echo -e "${RED}❌ Model $MODEL_NAME se nespustil, zkontrolujte $MODEL_LOG${NC}"
    exit 1
  fi
fi

# Spustit Flask
echo -e "${GREEN}🌐 Spouštím Flask server...${NC}"
nohup python3 main.py > flask.log 2>&1 &
sleep 2
if ! (ss -tuln 2>/dev/null | grep -q ":8010" || nc -z localhost 8010 >/dev/null 2>&1); then
  echo -e "${RED}❌ Flask se nespustil, zkontrolujte flask.log${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Jarvik běží na http://localhost:8010${NC}"
