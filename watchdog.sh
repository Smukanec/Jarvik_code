#!/bin/bash
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"
MODEL_NAME=${MODEL_NAME:-jarvik-mistral}
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

check_mistral() {
  if ! pgrep -f "ollama run $MODEL_NAME" > /dev/null; then
    echo -e "${RED}⚠️  Model $MODEL_NAME neběží. Restartuji...${NC}"
    nohup ollama run "$MODEL_NAME" >> "$MODEL_LOG" 2>&1 &
  fi
}

check_flask() {
  if ! (ss -tuln 2>/dev/null | grep -q ":8010" || nc -z localhost 8010 >/dev/null 2>&1); then
    echo -e "${RED}⚠️  Flask neběží. Restartuji...${NC}"
    nohup python3 main.py >> flask.log 2>&1 &
  fi
}

while true; do
  check_ollama
  check_mistral
  check_flask
  sleep 5
done
