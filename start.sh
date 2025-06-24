#!/bin/bash
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

cd "$(dirname "$0")" || exit

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

# Spustit Ollama, pokud neběží
if ! pgrep -f "ollama serve" > /dev/null; then
  echo -e "${GREEN}🚀 Spouštím Ollama...${NC}"
  nohup ollama serve > ollama.log 2>&1 &
  sleep 2
fi

# Spustit mistral, pokud neběží
if ! curl -s http://localhost:11434/api/tags | grep -q '"name": "mistral"'; then
  echo -e "${GREEN}🧠 Spouštím model mistral...${NC}"
  nohup ollama run mistral > mistral.log 2>&1 &
  sleep 2
fi

# Spustit Flask
echo -e "${GREEN}🌐 Spouštím Flask server...${NC}"
nohup python3 main.py > flask.log 2>&1 &
