#!/bin/bash
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# Allow overriding the Flask port
FLASK_PORT=${FLASK_PORT:-8010}

cd "$(dirname "$0")" || exit

# Activate virtual environment
if [ -f venv/bin/activate ]; then
  source venv/bin/activate
  echo -e "${GREEN}✅ Aktivováno virtuální prostředí${NC}"
else
  echo -e "${RED}❌ Chybí virtuální prostředí venv/. Spusťte install_jarvik.sh.${NC}"
  exit 1
fi

# Start Flask server
echo -e "${GREEN}🌐 Spouštím Flask server...${NC}"
nohup python3 main.py > flask.log 2>&1 &
sleep 2

# Verify the configured port is listening
if command -v ss >/dev/null 2>&1; then
  ss -tuln | grep -q ":$FLASK_PORT"
  running=$?
elif command -v nc >/dev/null 2>&1; then
  nc -z localhost $FLASK_PORT >/dev/null 2>&1
  running=$?
else
  running=1
fi

if [ "$running" = 0 ]; then
  echo -e "${GREEN}✅ Flask běží na http://localhost:$FLASK_PORT${NC}"
else
  echo -e "${RED}❌ Flask se nespustil, zkontrolujte flask.log${NC}"
  exit 1
fi
