#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR" || exit

GREEN='\033[1;32m'
NC='\033[0m'

# Download latest version if possible
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -n "$(git remote)" ]; then
    echo -e "${GREEN}🔄 Stahuji nejnovější verzi...${NC}"
    git pull
  else
    echo -e "${GREEN}⚠️  Git remote není nastaven, stahování vynecháno.${NC}"
  fi
else
  echo -e "${GREEN}⚠️  Adresář není git repozitář, stahování vynecháno.${NC}"
fi

# Reinstall
bash uninstall_jarvik.sh
bash install_jarvik.sh

# Start automatically
bash start.sh

echo -e "${GREEN}✅ Upgrade dokončen.${NC}"
