#!/bin/bash
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

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
  if ! pgrep -f "ollama run mistral" > /dev/null; then
    echo -e "${RED}⚠️  Mistral neběží. Restartuji...${NC}"
    nohup ollama run mistral >> mistral.log 2>&1 &
  fi
}

check_flask() {
  # Port might still be bound even if the process crashed, so verify the
  # Python process as well as the listening socket.
  local flask_running=false
  if pgrep -f "python3 main.py" >/dev/null; then
    if ss -tuln 2>/dev/null | grep -q ":8010" || nc -z localhost 8010 >/dev/null 2>&1; then
      flask_running=true
    fi
  fi
  if [ "$flask_running" = false ]; then
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
