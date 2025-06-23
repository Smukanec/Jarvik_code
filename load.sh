#!/bin/bash
# Kontrola a přidání aliasů pro JARVIK
# Add comment and alias definitions if not already present.
if ! grep -q "alias jarvik=" ~/.bashrc; then
  echo "# 🚀 Alias příkazy pro JARVIK" >> ~/.bashrc
  echo "alias jarvik='bash ~/Jarvik_RAG/activate.sh'" >> ~/.bashrc
fi

if ! grep -q "alias jarvik-start=" ~/.bashrc; then
  echo "alias jarvik-start='bash ~/Jarvik_RAG/start.sh'" >> ~/.bashrc
fi

if ! grep -q "alias jarvik-status=" ~/.bashrc; then
  echo "alias jarvik-status='bash ~/Jarvik_RAG/status.sh'" >> ~/.bashrc
fi

if ! grep -q "alias jarvik-install=" ~/.bashrc; then
  echo "alias jarvik-install='bash ~/Jarvik_RAG/install_jarvik.sh'" >> ~/.bashrc
fi

if ! grep -q "alias jarvik-flask=" ~/.bashrc; then
  echo "alias jarvik-flask='source ~/Jarvik_RAG/venv/bin/activate && python ~/Jarvik_RAG/main.py'" >> ~/.bashrc
fi

# Načtení změn
source ~/.bashrc
