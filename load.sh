DIR="$(cd "$(dirname "$0")" && pwd)"

cat >> ~/.bashrc <<EOF

# 🚀 Alias příkazy pro JARVIK
alias jarvik='bash $DIR/activate.sh'
alias jarvik-start='bash $DIR/start.sh'
alias jarvik-status='bash $DIR/status.sh'
alias jarvik-install='bash $DIR/install_jarvik.sh'
alias jarvik-flask='source $DIR/venv/bin/activate && python $DIR/main.py'

EOF

# Načtení změn
source ~/.bashrc
