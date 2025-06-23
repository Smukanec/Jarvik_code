cat << 'EOF' >> ~/.bashrc

# 🚀 Alias příkazy pro JARVIK
alias jarvik='bash ~/Jarvik_RAG/activate.sh'
alias jarvik-start='bash ~/Jarvik_RAG/start.sh'
alias jarvik-status='bash ~/Jarvik_RAG/status.sh'
alias jarvik-install='bash ~/Jarvik_RAG/install_jarvik.sh'
alias jarvik-flask='source ~/Jarvik_RAG/venv/bin/activate && python ~/Jarvik_RAG/main.py'

EOF

# Načtení změn
source ~/.bashrc
