#!/bin/bash
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

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

# Verify port 8010 is listening
if command -v ss >/dev/null 2>&1; then
  ss -tuln | grep -q ":8010"
  running=$?
elif command -v nc >/dev/null 2>&1; then
  nc -z localhost 8010 >/dev/null 2>&1
  running=$?
else
  running=1
fi

if [ "$running" = 0 ]; then
  echo -e "${GREEN}✅ Flask běží na http://localhost:8010${NC}"
else
  echo -e "${RED}❌ Flask se nespustil, zkontrolujte flask.log${NC}"
  exit 1
fi
