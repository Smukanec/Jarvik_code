#!/bin/bash
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"
# Allow overriding the Flask port
FLASK_PORT=${FLASK_PORT:-8010}
# Determine if we can perform port checks
if command -v ss >/dev/null 2>&1 || command -v nc >/dev/null 2>&1; then
  PORT_CHECK_AVAILABLE=true
else
  echo -e "${RED}⚠️  Příkazy 'ss' ani 'nc' nebyly nalezeny. Kontrola portu Flask bude přeskočena.${NC}"
  PORT_CHECK_AVAILABLE=false
fi
# Default model name can be overridden via MODEL_NAME
MODEL_NAME=${MODEL_NAME:-"gemma:2b"}
MODEL_LOG="${MODEL_NAME}.log"

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR" || exit

# Activate virtual environment if available
if [ -z "$VIRTUAL_ENV" ] && [ -f venv/bin/activate ]; then
  source venv/bin/activate
fi

echo -e "${GREEN}🔄 Watchdog spuštěn. Kontroluji služby každých 5 sekund...${NC}"

check_ollama() {
  if ! pgrep -f "ollama serve" > /dev/null; then
    echo -e "${RED}⚠️  Ollama neběží. Restartuji...${NC}"
    nohup ollama serve >> ollama.log 2>&1 &
  fi
}

check_model() {
  if ! pgrep -f -x "ollama run $MODEL_NAME" > /dev/null; then
    echo -e "${RED}⚠️  Model $MODEL_NAME neběží. Restartuji...${NC}"
    nohup ollama run "$MODEL_NAME" >> "$MODEL_LOG" 2>&1 &
  fi
}

check_flask() {
  if [ "$PORT_CHECK_AVAILABLE" = false ]; then
    return
  fi
  if ! (ss -tuln 2>/dev/null | grep -q ":$FLASK_PORT" || nc -z localhost $FLASK_PORT >/dev/null 2>&1); then
    echo -e "${RED}⚠️  Flask neběží. Restartuji...${NC}"
    nohup python3 main.py >> flask.log 2>&1 &
  fi
}

while true; do
  check_ollama
  check_model
  check_flask
  sleep 5
done
